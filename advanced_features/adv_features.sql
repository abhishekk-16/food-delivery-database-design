-- VIEWS

-- View 1: Active Restaurants with Ratings and Order Count
CREATE OR REPLACE VIEW restaurant_performance AS
SELECT 
    r.restaurant_id,
    r.restaurant_name,
    r.cuisine_type,
    ra.city,
    r.rating,
    COUNT(DISTINCT o.order_id) as total_orders,
    COALESCE(ROUND(AVG(rv.rating), 2), 0) as avg_customer_rating,
    COALESCE(SUM(o.final_amount), 0) as total_revenue,
    COALESCE(ROUND(AVG(o.final_amount), 2), 0) as avg_order_value,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    r.is_operational
FROM restaurants r
LEFT JOIN restaurant_addresses ra ON r.restaurant_id = ra.restaurant_id
LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id 
    AND o.order_status = 'delivered'
    AND o.order_date >= CURRENT_DATE - INTERVAL '30 days'
LEFT JOIN reviews rv ON r.restaurant_id = rv.restaurant_id
    AND rv.review_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY r.restaurant_id, r.restaurant_name, r.cuisine_type, ra.city, r.rating, r.is_operational
ORDER BY total_revenue DESC;

-- View 2: Daily Revenue Dashboard
CREATE OR REPLACE VIEW daily_revenue_report AS
SELECT 
    DATE(o.order_date) as order_date,
    COUNT(o.order_id) as total_orders,
    COUNT(DISTINCT o.customer_id) as unique_customers,
    COUNT(DISTINCT o.restaurant_id) as active_restaurants,
    SUM(o.final_amount) as daily_revenue,
    ROUND(AVG(o.final_amount), 2) as avg_order_value,
    MIN(o.final_amount) as min_order_value,
    MAX(o.final_amount) as max_order_value,
    SUM(o.delivery_fee) as delivery_revenue,
    SUM(o.tax_amount) as tax_collected
FROM orders o
WHERE o.order_status = 'delivered'
GROUP BY DATE(o.order_date)
ORDER BY order_date DESC;

-- View 3: Top Delivery Agents Performance
CREATE OR REPLACE VIEW top_delivery_agents_view AS
SELECT 
    da.agent_id,
    u.first_name || ' ' || u.last_name as agent_name,
    u.phone_number,
    da.vehicle_type,
    da.total_deliveries,
    da.rating,
    COUNT(d.delivery_id) as completed_deliveries,
    ROUND(AVG(EXTRACT(EPOCH FROM (d.actual_delivery_time - d.pickup_time))/60)::numeric, 2) as avg_delivery_time_minutes,
    ROUND(AVG(d.delivery_rating), 2) as avg_delivery_rating,
    da.is_available
FROM delivery_agents da
JOIN users u ON da.user_id = u.user_id
LEFT JOIN deliveries d ON da.agent_id = d.delivery_agent_id 
    AND d.delivery_status = 'delivered'
    AND d.actual_delivery_time >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY da.agent_id, u.first_name, u.last_name, u.phone_number, 
         da.vehicle_type, da.total_deliveries, da.rating, da.is_available
ORDER BY completed_deliveries DESC, da.rating DESC;

-- View 4: Customer Activity
CREATE OR REPLACE VIEW customer_activity AS
SELECT 
    u.user_id,
    u.first_name || ' ' || u.last_name as customer_name,
    u.email,
    COUNT(o.order_id) as total_orders,
    SUM(o.final_amount) as total_spent,
    ROUND(AVG(o.final_amount), 2) as avg_order_value,
    MAX(o.order_date) as last_order_date,
    COUNT(DISTINCT o.restaurant_id) as unique_restaurants,
    ROUND(EXTRACT(EPOCH FROM (CURRENT_DATE - MAX(o.order_date))) / 86400) as days_since_last_order
FROM users u
LEFT JOIN orders o ON u.user_id = o.customer_id
WHERE u.user_type = 'customer'
GROUP BY u.user_id, u.first_name, u.last_name, u.email
ORDER BY total_spent DESC;

-- FUNCTIONS

-- Function 1: Calculate Distance Between Two Coordinates (Haversine Formula)
CREATE OR REPLACE FUNCTION calculate_distance(
    lat1 DECIMAL, lon1 DECIMAL,
    lat2 DECIMAL, lon2 DECIMAL
)
RETURNS DECIMAL AS $$
DECLARE
    r DECIMAL := 6371; -- Earth's radius in km
    dlat DECIMAL;
    dlon DECIMAL;
    a DECIMAL;
    c DECIMAL;
BEGIN
    dlat := RADIANS(lat2 - lat1);
    dlon := RADIANS(lon2 - lon1);
    
    a := SIN(dlat/2) * SIN(dlat/2) + 
         COS(RADIANS(lat1)) * COS(RADIANS(lat2)) * 
         SIN(dlon/2) * SIN(dlon/2);
    
    c := 2 * ATAN2(SQRT(a), SQRT(1-a));
    
    RETURN ROUND((r * c)::numeric, 2);
END;
$$ LANGUAGE plpgsql IMMUTABLE;

-- Function 2: Find Nearby Restaurants
CREATE OR REPLACE FUNCTION get_nearby_restaurants(
    p_customer_latitude DECIMAL,
    p_customer_longitude DECIMAL,
    p_radius_km INT DEFAULT 5
)
RETURNS TABLE (
    restaurant_id INT,
    restaurant_name VARCHAR,
    cuisine_type VARCHAR,
    rating DECIMAL,
    distance_km DECIMAL,
    is_operational BOOLEAN,
	address VARCHAR,
	main_branch BOOLEAN
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        r.restaurant_id,
        r.restaurant_name,
        r.cuisine_type,
        r.rating,
        calculate_distance(
            p_customer_latitude, p_customer_longitude,
            ra.latitude, ra.longitude
        ) AS distance_km,
        r.is_operational,
		ra.street_address,
		ra.is_primary AS main_branch
    FROM restaurants r
    JOIN restaurant_addresses ra ON r.restaurant_id = ra.restaurant_id
    WHERE r.is_operational = true
      AND calculate_distance(
            p_customer_latitude, p_customer_longitude,
            ra.latitude, ra.longitude
        ) <= p_radius_km
    ORDER BY distance_km ASC, r.rating DESC;
END;
$$ LANGUAGE plpgsql;

-- Function 3: Calculate Order Total (Subtotal + Tax + Delivery Fee)
CREATE OR REPLACE FUNCTION calculate_order_total(
    p_order_id INT
)
RETURNS TABLE (
    subtotal DECIMAL,
    tax_amount DECIMAL,
    delivery_charge DECIMAL,
    discount_amt DECIMAL,
    final_total DECIMAL
) AS $$
DECLARE
    v_subtotal DECIMAL;
    v_tax DECIMAL;
    v_delivery_fee DECIMAL;
    v_discount DECIMAL;
    v_tax_rate DECIMAL := 0.05; -- 5% tax
BEGIN
    -- Calculate subtotal from order items
    SELECT COALESCE(SUM(quantity * item_price), 0)
    INTO v_subtotal
    FROM order_items
    WHERE order_id = p_order_id;
    
    -- Get discount and delivery fee from order
    SELECT discount_amount, delivery_fee
    INTO v_discount, v_delivery_fee
    FROM orders
    WHERE order_id = p_order_id;
    
    -- Calculate tax on subtotal
    v_tax := ROUND((v_subtotal * v_tax_rate)::numeric, 2);
    
    RETURN QUERY
    SELECT 
        v_subtotal,
        v_tax,
        v_delivery_fee,
        COALESCE(v_discount, 0),
        v_subtotal + v_tax + v_delivery_fee - COALESCE(v_discount, 0);
END;
$$ LANGUAGE plpgsql;

-- Function 4: Get Available Delivery Agents
CREATE OR REPLACE FUNCTION get_available_delivery_agents(
    p_vehicle_type VARCHAR DEFAULT NULL
)
RETURNS TABLE (
    agent_id INT,
    first_name VARCHAR,
    last_name VARCHAR,
    vehicle_type VARCHAR,
    rating DECIMAL,
    total_deliveries INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        da.agent_id,
        u.first_name,
        u.last_name,
        da.vehicle_type,
        da.rating,
        da.total_deliveries
    FROM delivery_agents da
    JOIN users u ON da.user_id = u.user_id
    WHERE da.is_available = true
      AND (p_vehicle_type IS NULL OR da.vehicle_type ILIKE p_vehicle_type)
    ORDER BY da.rating DESC, da.total_deliveries DESC;
END;
$$ LANGUAGE plpgsql;

-- Function 5: Check Order Delivery Status
CREATE OR REPLACE FUNCTION get_order_delivery_status(
    p_order_id INT
)
RETURNS TABLE (
    order_id INT,
    customer_name TEXT,
    restaurant_name VARCHAR,
    order_status VARCHAR,
    delivery_status VARCHAR,
    estimated_delivery_time TIMESTAMP,
    actual_delivery_time TEXT,
    delivery_agent_name TEXT,
    delivery_rating INT
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.order_id,
        (u.first_name || ' ' || u.last_name),
        r.restaurant_name,
        o.order_status,
        COALESCE(d.delivery_status, 'Not Assigned'),
        d.estimated_delivery_time,
        CASE 
		  WHEN d.actual_delivery_time IS NULL THEN 'Not Delivered Yet'
		  ELSE TO_CHAR(d.actual_delivery_time, 'YYYY-MM-DD HH24:MI:SS')
		END AS actual_delivery_time,
        (u2.first_name || ' ' || u2.last_name),
        d.delivery_rating
    FROM orders o
    JOIN users u ON o.customer_id = u.user_id
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    LEFT JOIN deliveries d ON o.order_id = d.order_id
    LEFT JOIN delivery_agents da ON d.delivery_agent_id = da.agent_id
    LEFT JOIN users u2 ON da.user_id = u2.user_id
    WHERE o.order_id = p_order_id;
END;
$$ LANGUAGE plpgsql;

-- Function 6: Calculate Restaurant Rating Update
CREATE OR REPLACE FUNCTION update_restaurant_rating(
    p_restaurant_id INT
)
RETURNS DECIMAL AS $$
DECLARE
    v_new_rating DECIMAL;
BEGIN
    -- Calculate average rating from recent reviews (last 30 days)
    SELECT COALESCE(AVG(rating), 5.00)
    INTO v_new_rating
    FROM reviews
    WHERE restaurant_id = p_restaurant_id
      AND review_date >= CURRENT_TIMESTAMP - INTERVAL '30 days';
    
    -- Round to 2 decimal places
    v_new_rating := ROUND(v_new_rating::numeric, 2);
    
    -- Update restaurant rating
    UPDATE restaurants
    SET rating = v_new_rating,
        updated_at = CURRENT_TIMESTAMP
    WHERE restaurant_id = p_restaurant_id;
    
    RETURN v_new_rating;
END;
$$ LANGUAGE plpgsql;

-- Function 7: Get Customer Order History
CREATE OR REPLACE FUNCTION get_customer_order_history(
    p_customer_id INT,
    p_limit INT DEFAULT 10
)
RETURNS TABLE (
    order_id INT,
    restaurant_name VARCHAR,
    order_date TIMESTAMP,
    final_amount DECIMAL,
    order_status VARCHAR,
    restaurant_rating DECIMAL
) AS $$
BEGIN
    RETURN QUERY
    SELECT 
        o.order_id,
        r.restaurant_name,
        o.order_date,
        o.final_amount,
        o.order_status,
        r.rating
    FROM orders o
    JOIN restaurants r ON o.restaurant_id = r.restaurant_id
    WHERE o.customer_id = p_customer_id
    ORDER BY o.order_date DESC
    LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- Function 8: Validate Payment Before Order Confirmation
CREATE OR REPLACE FUNCTION validate_order_payment(
    p_order_id INT
)
RETURNS TABLE (
    is_valid BOOLEAN,
    message TEXT
) AS $$
DECLARE
    v_payment_status VARCHAR;
    v_order_status VARCHAR;
    v_final_amount DECIMAL;
    v_payment_amount DECIMAL;
BEGIN
    -- Get order details
    SELECT o.order_status, o.final_amount, p.payment_status, p.payment_amount
    INTO v_order_status, v_final_amount, v_payment_status, v_payment_amount
    FROM orders o
    LEFT JOIN payments p ON o.order_id = p.order_id
    WHERE o.order_id = p_order_id;
    
    -- Check if order exists
    IF v_order_status IS NULL THEN
        RETURN QUERY SELECT false, 'Order not found';
        RETURN;
    END IF;
    
    -- Check payment status
    IF v_payment_status IS NULL THEN
        RETURN QUERY SELECT false, 'Payment not found for order';
        RETURN;
    END IF;
    
    IF v_payment_status != 'completed' THEN
        RETURN QUERY SELECT false, 'Payment status is ' || v_payment_status || ', not completed';
        RETURN;
    END IF;
    
    -- Check payment amount matches
    IF v_payment_amount != v_final_amount THEN
        RETURN QUERY SELECT false, 'Payment amount does not match order total';
        RETURN;
    END IF;
    
    -- All checks passed
    RETURN QUERY SELECT true, 'Payment validated successfully';
END;
$$ LANGUAGE plpgsql;

-- Function 9: Manage Order Items (INSERT/UPDATE) 
CREATE OR REPLACE FUNCTION manage_order_item(
    p_order_id INT,
    p_item_id INT,
    p_quantity INT,
    p_item_price DECIMAL,
    p_operation VARCHAR DEFAULT 'INSERT' -- 'INSERT' or 'UPDATE'
)
RETURNS TABLE(
    success BOOLEAN,
    message VARCHAR,
    order_itm_id INT
) AS $$
DECLARE
    v_order_status VARCHAR;
    v_order_exists BOOLEAN;
    v_item_exists BOOLEAN;
    v_order_item_id INT;
BEGIN
    -- Check if order exists
    SELECT EXISTS(SELECT 1 FROM orders WHERE order_id = p_order_id)
    INTO v_order_exists;
    
    IF NOT v_order_exists THEN
        RETURN QUERY SELECT FALSE, 'Order not found'::VARCHAR, NULL::INT;
        RETURN;
    END IF;
    
    -- Get order status
    SELECT order_status INTO v_order_status
    FROM orders
    WHERE order_id = p_order_id;
    
    -- Validate order status (only pending or confirmed allowed)
    IF v_order_status NOT IN ('pending', 'confirmed') THEN
        RETURN QUERY SELECT 
            FALSE, 
            format('Cannot modify order items. Order status is %s. Items can only be modified for orders in pending or confirmed status.', v_order_status)::VARCHAR,
            NULL::INT;
        RETURN;
    END IF;
    
    -- Validate quantity
    IF p_quantity <= 0 THEN
        RETURN QUERY SELECT FALSE, 'Quantity must be greater than 0'::VARCHAR, NULL::INT;
        RETURN;
    END IF;
    
    -- Validate item price
    IF p_item_price <= 0 THEN
        RETURN QUERY SELECT FALSE, 'Item price must be greater than 0'::VARCHAR, NULL::INT;
        RETURN;
    END IF;
    
    -- Handle INSERT operation
    IF UPPER(p_operation) = 'INSERT' THEN
        -- Check if item already exists for this order
        SELECT EXISTS(
            SELECT 1 FROM order_items 
            WHERE order_id = p_order_id AND menu_item_id = p_item_id
        ) INTO v_item_exists;
        
        IF v_item_exists THEN
            RETURN QUERY SELECT FALSE, 'Item already exists in this order. Use UPDATE operation instead.'::VARCHAR, NULL::INT;
            RETURN;
        END IF;
        
        -- Insert new order item
        INSERT INTO order_items (order_id, menu_item_id, quantity, item_price)
        VALUES (p_order_id, p_item_id, p_quantity, p_item_price)
        RETURNING order_item_id INTO v_order_item_id;
        
        RETURN QUERY SELECT TRUE, 'Order item inserted successfully'::VARCHAR, v_order_item_id;
        
    -- Handle UPDATE operation
    ELSIF UPPER(p_operation) = 'UPDATE' THEN
        -- Check if item exists for this order
        SELECT order_item_id INTO v_order_item_id
        FROM order_items 
        WHERE order_id = p_order_id AND menu_item_id = p_item_id;
        
        IF v_order_item_id IS NULL THEN
            RETURN QUERY SELECT FALSE, 'Item not found in this order. Use INSERT operation instead.'::VARCHAR, NULL::INT;
            RETURN;
        END IF;
        
        -- Update existing order item
        UPDATE order_items
        SET quantity = p_quantity,
            item_price = p_item_price
        WHERE order_id = p_order_id AND item_id = p_item_id;
        
        RETURN QUERY SELECT TRUE, 'Order item updated successfully'::VARCHAR, v_order_item_id;
        
    ELSE
        RETURN QUERY SELECT FALSE, 'Invalid operation. Use INSERT or UPDATE.'::VARCHAR, NULL::INT;
        RETURN;
    END IF;
    
EXCEPTION WHEN OTHERS THEN
    RETURN QUERY SELECT FALSE, format('Error: %s', SQLERRM)::VARCHAR, NULL::INT;
END;
$$ LANGUAGE plpgsql;

-- Function 10: Get top menu items
CREATE OR REPLACE FUNCTION get_top_menu_items(
    p_limit INT DEFAULT 10
)
RETURNS TABLE (
    name VARCHAR,
	restaurant VARCHAR,
	item_category VARCHAR,
	item_price DECIMAL,
	times_ordered BIGINT,
	total_quantity_ordered BIGINT,
	total_revenue DECIMAl
) AS $$
BEGIN
    RETURN QUERY
	SELECT
		mi.item_name,
		r.restaurant_name,
		mi.category,
		mi.price,
		COUNT(oi.order_item_id) AS times_ordered,
		SUM(oi.quantity) AS total_quantity_ordered,
		SUM(oi.item_price * oi.quantity) AS total_revenue
	FROM order_items oi
	JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
	JOIN orders o ON oi.order_id = o.order_id
	JOIN restaurants r ON mi.restaurant_id = r.restaurant_id
	WHERE o.order_status != 'cancelled'
	    AND o.order_date >= CURRENT_DATE - INTERVAL '90 days'
	GROUP BY oi.menu_item_id,
	         mi.item_name,
		     r.restaurant_name,
		     mi.category,
		     mi.price
	ORDER BY times_ordered DESC, total_quantity_ordered DESC
	LIMIT p_limit;
END;
$$ LANGUAGE plpgsql;

-- STORED PROCEDURES

-- Procedure 1: Place a New Order
CREATE OR REPLACE PROCEDURE place_order(
    OUT p_order_id INT,
    OUT p_error_message VARCHAR,
	p_customer_id INT,
    p_restaurant_id INT,
    p_address_id INT,
    p_delivery_time TIMESTAMP,
	p_items JSONB,              -- item list
    p_discount_rate NUMERIC DEFAULT 0,   -- e.g. 0.10 = 10%
    p_special_instructions TEXT DEFAULT NULL
    )
LANGUAGE plpgsql
AS $$
DECLARE
    v_customer_exists BOOLEAN;
    v_restaurant_operational BOOLEAN;
	v_total_amount NUMERIC := 0;
    v_discount_amount NUMERIC := 0;
    v_tax_amount NUMERIC := 0;
    v_delivery_fee DECIMAL := 50.00;
    v_tax_rate DECIMAL := 0.05;
	v_price NUMERIC;
    v_quantity INT;
    v_menu_item_id INT;
    v_item_count INT;
BEGIN
    -- Validate customer exists
    SELECT EXISTS(SELECT 1 FROM users WHERE user_id = p_customer_id AND user_type = 'customer')
    INTO v_customer_exists;
    
    IF NOT v_customer_exists THEN
        p_error_message := 'Customer not found';
        RETURN;
    END IF;
    
    -- Validate restaurant is operational
    SELECT is_operational INTO v_restaurant_operational 
    FROM restaurants WHERE restaurant_id = p_restaurant_id;

	IF v_restaurant_operational IS NULL THEN
	    p_error_message := 'Restaurant not found';
		RETURN;
    END IF;
	
    IF NOT v_restaurant_operational THEN
        p_error_message := 'Restaurant is not operational';
        RETURN;
    END IF;

	-- Discount bound validtion
	IF p_discount_rate < 0 OR p_discount_rate > 0.50 THEN 
	   p_error_message := 'Invalid discount rate';
	   RETURN;
	END IF;

	-- Empty item list validation
	IF p_items IS NULL
	   OR jsonb_typeof(p_items) <> 'array'
	   OR jsonb_array_length(p_items) = 0 THEN

	   p_error_message := 'Order must contain atleast one item';
	   RETURN;
	 END IF;
	 
    -- Start transaction
    BEGIN
        INSERT INTO orders (
            customer_id, restaurant_id, delivery_address_id, 
            requested_delivery_time, special_instructions,
            total_amount, discount_amount, delivery_fee, tax_amount,
            order_status, payment_status
        )
        VALUES (
            p_customer_id, p_restaurant_id, p_address_id,
            p_delivery_time, p_special_instructions,
            0, 0, v_delivery_fee, 0,
            'pending', 'pending'
        )
        RETURNING order_id INTO p_order_id;

		-- Update restaurant order count
        UPDATE restaurants 
        SET total_orders = total_orders + 1
        WHERE restaurant_id = p_restaurant_id;

		-- Loop through items
    FOR v_menu_item_id, v_quantity IN
        SELECT
            (item ->> 'menu_item_id')::INT,
            (item ->> 'quantity')::INT
        FROM jsonb_array_elements(p_items) AS item
    LOOP
	    -- Quantity validation
		IF v_quantity IS NULL OR v_quantity <= 0 THEN
		   RAISE EXCEPTION 'Invalid quantity for item-%', v_menu_item_id;
		END IF;
		
        -- Fetch price
        SELECT price
        INTO v_price
        FROM menu_items
        WHERE menu_item_id = v_menu_item_id
          AND restaurant_id = p_restaurant_id;

        -- Insert order item
        INSERT INTO order_items (
            order_id,
            menu_item_id,
            quantity,
            item_price
        )
        VALUES (
            p_order_id,
            v_menu_item_id,
            v_quantity,
            v_price
        );

        -- Accumulate total
        v_total_amount := v_total_amount + (v_price * v_quantity);
    END LOOP;

	 -- Calculate discount
    v_discount_amount := v_total_amount * p_discount_rate;

    -- Calculate tax
    v_tax_amount := (v_total_amount - v_discount_amount) * v_tax_rate;

    -- Update order totals
    UPDATE orders
    SET
        total_amount = v_total_amount,
        discount_amount = v_discount_amount,
        tax_amount = v_tax_amount
    WHERE order_id = p_order_id;
       
        p_error_message := NULL;
        
    EXCEPTION WHEN OTHERS THEN
        p_error_message := SQLERRM;
        RAISE NOTICE 'Error creating order: %', SQLERRM;
    END;
    
END;
$$;

-- Procedure 2: Confirm an Order
CREATE OR REPLACE PROCEDURE confirm_order(
    p_order_id INT,
    p_delivery_agent_id INT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_delivery_id INT;
    v_agent_available BOOLEAN;
BEGIN
    -- Check if agent is available
    SELECT is_available INTO v_agent_available
    FROM delivery_agents
    WHERE agent_id = p_delivery_agent_id;
    
    IF NOT v_agent_available THEN
        p_success := FALSE;
        p_message := 'Delivery agent not available';
        RETURN;
    END IF;
    
    BEGIN
        -- Update order status
        UPDATE orders
        SET order_status = 'confirmed',
            updated_at = CURRENT_TIMESTAMP
        WHERE order_id = p_order_id;
        
        -- Create delivery record
        INSERT INTO deliveries (
            order_id, delivery_agent_id, 
            delivery_status, pickup_time
        )
        VALUES (p_order_id, p_delivery_agent_id, 'pickup_pending', CURRENT_TIMESTAMP)
        RETURNING delivery_id INTO v_delivery_id;
        
        -- Mark agent as unavailable
        UPDATE delivery_agents
        SET is_available = FALSE
        WHERE agent_id = p_delivery_agent_id;
        
        p_success := TRUE;
        p_message := 'Order confirmed and assigned to delivery agent';
        
    EXCEPTION WHEN OTHERS THEN
        p_success := FALSE;
        p_message := SQLERRM;
    END;
    
END;
$$;

-- Procedure 3: Update Order Status with Validation
CREATE OR REPLACE PROCEDURE update_order_status(
    p_order_id INT,
    p_new_status VARCHAR,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_current_status VARCHAR;
    v_order_exists BOOLEAN;
BEGIN
    -- Check if order exists
    SELECT EXISTS(SELECT 1 FROM orders WHERE order_id = p_order_id)
    INTO v_order_exists;
    
    IF NOT v_order_exists THEN
        p_success := FALSE;
        p_message := 'Order not found';
        RETURN;
    END IF;
    
    -- Get current status
    SELECT order_status INTO v_current_status
    FROM orders WHERE order_id = p_order_id;
    
    -- Enforce valid status transitions
    CASE
        WHEN v_current_status = 'pending' THEN
            IF p_new_status NOT IN ('confirmed', 'cancelled') THEN
                p_success := FALSE;
                p_message := 'From pending, can only go to confirmed or cancelled';
                RETURN;
            END IF;
            
        WHEN v_current_status = 'confirmed' THEN
            IF p_new_status NOT IN ('preparing', 'cancelled') THEN
                p_success := FALSE;
                p_message := 'From confirmed, can only go to preparing or cancelled';
                RETURN;
            END IF;
            
        WHEN v_current_status = 'preparing' THEN
            IF p_new_status NOT IN ('ready', 'cancelled') THEN
                p_success := FALSE;
                p_message := 'From preparing, can only go to ready or cancelled';
                RETURN;
            END IF;
            
        WHEN v_current_status = 'ready' THEN
            IF p_new_status NOT IN ('out_for_delivery', 'cancelled') THEN
                p_success := FALSE;
                p_message := 'From ready, can only go to out_for_delivery or cancelled';
                RETURN;
            END IF;
            
        WHEN v_current_status = 'out_for_delivery' THEN
            IF p_new_status NOT IN ('delivered', 'cancelled') THEN
                p_success := FALSE;
                p_message := 'From out_for_delivery, can only go to delivered or cancelled';
                RETURN;
            END IF;
            
        WHEN v_current_status IN ('delivered', 'cancelled') THEN
            p_success := FALSE;
            p_message := 'Cannot change status of delivered or cancelled order';
            RETURN;
    END CASE;
    
    -- Update order
    UPDATE orders
    SET order_status = p_new_status,
        updated_at = CURRENT_TIMESTAMP
    WHERE order_id = p_order_id;
    
    p_success := TRUE;
    p_message := 'Order status updated successfully from ' || v_current_status || 
                 ' to ' || p_new_status;
    
EXCEPTION WHEN OTHERS THEN
    p_success := FALSE;
    p_message := SQLERRM;
END;
$$;

-- Procedure 4: Procedure for CUSTOMERS (cancel order) via mobile app
CREATE OR REPLACE PROCEDURE customer_cancel_order(
    p_order_id INT,
    p_customer_id INT,  -- To verify customer owns the order
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_status VARCHAR;
    v_order_customer_id INT;
BEGIN
    -- Verify order belongs to customer
    SELECT customer_id, order_status INTO v_order_customer_id, v_order_status
    FROM orders WHERE order_id = p_order_id;
    
    IF v_order_customer_id != p_customer_id THEN
        p_success := FALSE;
        p_message := 'Order does not belong to this customer';
        RETURN;
    END IF;
    
    -- Customer can only cancel pending or confirmed orders
    IF v_order_status NOT IN ('pending', 'confirmed') THEN
        p_success := FALSE;
        p_message := format('Cannot cancel order in %s status. Orders can only be cancelled before kitchen starts preparing.', v_order_status);
        RETURN;
    END IF;
    
    -- Update status
    UPDATE orders SET order_status = 'cancelled' WHERE order_id = p_order_id;
    
    p_success := TRUE;
    p_message := 'Order cancelled successfully';
    
EXCEPTION WHEN OTHERS THEN
    p_success := FALSE;
    p_message := SQLERRM;
END;
$$;

-- Procedure 5: Procedure for Admin to cancel order
CREATE OR REPLACE PROCEDURE admin_cancel_order(
    p_order_id INT,
    p_admin_id INT,
    p_cancel_reason TEXT,
    OUT p_success BOOLEAN,
    OUT p_message VARCHAR
)
LANGUAGE plpgsql
AS $$
DECLARE
    v_order_status VARCHAR;
BEGIN
    
	--Verify order exists
    SELECT order_status
    INTO v_order_status
    FROM orders
    WHERE order_id = p_order_id;

    IF v_order_status IS NULL THEN
        p_success := FALSE;
        p_message := 'Order not found';
        RETURN;
    END IF;

    
    --Check if already cancelled
    IF v_order_status = 'cancelled' THEN
        p_success := FALSE;
        p_message := 'Order is already cancelled';
        RETURN;
    END IF;

    
    --Perform cancellation
    UPDATE orders
    SET
        order_status = 'cancelled',
        updated_at = CURRENT_TIMESTAMP
    WHERE order_id = p_order_id;

    p_success := TRUE;
    p_message := 'Order cancelled successfully by admin';

EXCEPTION WHEN OTHERS THEN
    p_success := FALSE;
    p_message := SQLERRM;
END;
$$;

-- TRIGGERS

-- Trigger 1: Automatically Set updated_at Timestamp
CREATE OR REPLACE FUNCTION update_timestamp()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = CURRENT_TIMESTAMP;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply trigger to multiple tables
CREATE TRIGGER trg_update_users_timestamp
BEFORE UPDATE ON users
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_update_restaurants_timestamp
BEFORE UPDATE ON restaurants
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_update_orders_timestamp
BEFORE UPDATE ON orders
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_update_deliveries_timestamp
BEFORE UPDATE ON deliveries
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_update_payments_timestamp
BEFORE UPDATE ON payments
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_update_delivery_agents_timestamp
BEFORE UPDATE ON delivery_agents
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_update_menu_items_timestamp
BEFORE UPDATE ON menu_items
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

CREATE TRIGGER trg_update_reviews_timestamp
BEFORE UPDATE ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_timestamp();

-- Trigger 2: Validate Order Status Transitions
CREATE OR REPLACE FUNCTION validate_order_status_transition()
RETURNS TRIGGER AS $$
DECLARE
    v_valid_transitions VARCHAR[][] := ARRAY[
        ARRAY['pending', 'confirmed'],
        ARRAY['confirmed', 'preparing'],
        ARRAY['preparing', 'ready'],
        ARRAY['ready', 'out_for_delivery'],
        ARRAY['out_for_delivery', 'delivered'],
        ARRAY['pending', 'cancelled'],
        ARRAY['confirmed', 'cancelled'],
        ARRAY['preparing', 'cancelled']
    ];
    v_transition_exists BOOLEAN;
BEGIN
    -- Allow NULL status transitions (if needed)
    IF NEW.order_status IS NULL THEN
        RETURN NEW;
    END IF;
    
    -- Check if transition is valid
    SELECT EXISTS(
        SELECT 1 FROM UNNEST(v_valid_transitions) AS transitions(from_status, to_status)
        WHERE transitions.from_status = OLD.order_status
          AND transitions.to_status = NEW.order_status
    ) INTO v_transition_exists;
    
    IF NOT v_transition_exists THEN
        RAISE EXCEPTION 'Invalid order status transition from % to %', OLD.order_status, NEW.order_status;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_order_status
BEFORE UPDATE ON orders
FOR EACH ROW
WHEN (OLD.order_status IS DISTINCT FROM NEW.order_status)
EXECUTE FUNCTION validate_order_status_transition();

-- Trigger 3: Update Delivery Agent Total Deliveries
CREATE OR REPLACE FUNCTION update_agent_delivery_count()
RETURNS TRIGGER AS $$
BEGIN
    -- When delivery is marked as delivered, increment agent's total_deliveries
    IF NEW.delivery_status = 'delivered' AND OLD.delivery_status != 'delivered' THEN
        UPDATE delivery_agents
        SET total_deliveries = total_deliveries + 1
        WHERE agent_id = NEW.delivery_agent_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_agent_delivery_count
AFTER UPDATE ON deliveries
FOR EACH ROW
WHEN (OLD.delivery_status IS DISTINCT FROM NEW.delivery_status)
EXECUTE FUNCTION update_agent_delivery_count();

-- Trigger 4: Validate Payment Amount Against Order Total
CREATE OR REPLACE FUNCTION validate_payment_amount()
RETURNS TRIGGER AS $$
DECLARE
    v_order_total DECIMAL;
BEGIN
    -- Get order final amount
    SELECT final_amount INTO v_order_total
    FROM orders
    WHERE order_id = NEW.order_id;
    
    -- Check if payment amount matches order total (or is 0 for failed payments)
    IF NEW.payment_status = 'completed' AND NEW.payment_amount != v_order_total THEN
        RAISE EXCEPTION 'Payment amount % does not match order total %', NEW.payment_amount, v_order_total;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_payment_amount
BEFORE INSERT OR UPDATE ON payments
FOR EACH ROW
EXECUTE FUNCTION validate_payment_amount();

-- Trigger 5: Update Restaurant Order Count
CREATE OR REPLACE FUNCTION update_restaurant_order_count()
RETURNS TRIGGER AS $$
BEGIN
    -- When order is delivered, increment restaurant's total_orders
    IF NEW.order_status = 'delivered' AND OLD.order_status != 'delivered' THEN
        UPDATE restaurants
        SET total_orders = total_orders + 1
        WHERE restaurant_id = NEW.restaurant_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_restaurant_order_count
AFTER UPDATE ON orders
FOR EACH ROW
WHEN (OLD.order_status IS DISTINCT FROM NEW.order_status)
EXECUTE FUNCTION update_restaurant_order_count();

-- Trigger 6: Prevent Duplicate Primary Restaurant Address
CREATE OR REPLACE FUNCTION check_duplicate_primary_address()
RETURNS TRIGGER AS $$
DECLARE
    v_existing_primary INT;
BEGIN
    -- If this address is being marked as primary
    IF NEW.is_primary = true THEN
        -- Check if another primary address exists for this restaurant
        SELECT COUNT(*) INTO v_existing_primary
        FROM restaurant_addresses
        WHERE restaurant_id = NEW.restaurant_id
          AND is_primary = true
          AND address_id != NEW.address_id;
        
        IF v_existing_primary > 0 THEN
            RAISE EXCEPTION 'Restaurant % already has a primary address', NEW.restaurant_id;
        END IF;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_check_duplicate_primary_address
BEFORE INSERT OR UPDATE ON restaurant_addresses
FOR EACH ROW
EXECUTE FUNCTION check_duplicate_primary_address();

-- Trigger 7: Log Order Status Changes (Audit Trail)
CREATE OR REPLACE FUNCTION log_order_status_change()
RETURNS TRIGGER AS $$
BEGIN
    -- Log only if order status actually changes
    IF OLD.order_status IS DISTINCT FROM NEW.order_status THEN
        INSERT INTO order_status_audit_log (
            order_id,
            old_status,
            new_status,
            changed_at
        )
        VALUES (
            OLD.order_id,
            OLD.order_status,
            NEW.order_status,
            CURRENT_TIMESTAMP
        );
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_log_order_status_change
AFTER UPDATE OF order_status
ON orders
FOR EACH ROW
EXECUTE FUNCTION log_order_status_change();

-- Trigger 8: Prevent Delivery Agent Assignment to Pending Orders
CREATE OR REPLACE FUNCTION validate_delivery_assignment()
RETURNS TRIGGER AS $$
DECLARE
    v_order_status VARCHAR;
BEGIN
    -- Get order status
    SELECT order_status INTO v_order_status
    FROM orders
    WHERE order_id = NEW.order_id;
    
    -- Delivery agent can only be assigned when order is ready
    IF v_order_status NOT IN ('confirmed', 'ready', 'out_for_delivery') THEN
        RAISE EXCEPTION 'Cannot assign delivery agent: Order status is %, must be confirmed or ready or out_for_delivery', v_order_status;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_validate_delivery_assignment
BEFORE INSERT OR UPDATE ON deliveries
FOR EACH ROW
WHEN (NEW.delivery_agent_id IS NOT NULL)
EXECUTE FUNCTION validate_delivery_assignment();

-- Trigger 9: Update Delivery Agent Rating After Review
CREATE OR REPLACE FUNCTION update_agent_rating_on_review()
RETURNS TRIGGER AS $$
DECLARE
    v_new_rating DECIMAL;
    v_delivery_agent_id INT;
BEGIN
    -- Get delivery agent ID from delivery record
    SELECT delivery_agent_id INTO v_delivery_agent_id
    FROM deliveries
    WHERE order_id = NEW.order_id;
    
    IF v_delivery_agent_id IS NOT NULL THEN
        -- Calculate new agent rating from recent deliveries
        SELECT COALESCE(AVG(d.delivery_rating), 5.00)
        INTO v_new_rating
        FROM deliveries d
        WHERE d.delivery_agent_id = v_delivery_agent_id
          AND d.delivery_rating IS NOT NULL
          AND d.actual_delivery_time >= CURRENT_TIMESTAMP - INTERVAL '30 days';
        
        -- Update agent rating
        UPDATE delivery_agents
        SET rating = ROUND(v_new_rating::numeric, 2)
        WHERE agent_id = v_delivery_agent_id;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER trg_update_agent_rating_on_review
AFTER INSERT OR UPDATE ON reviews
FOR EACH ROW
EXECUTE FUNCTION update_agent_rating_on_review();

-- Trigger 10: Update order total
CREATE OR REPLACE FUNCTION update_order_total()
RETURNS TRIGGER AS $$
DECLARE
    v_subtotal DECIMAL;
    v_tax_amount DECIMAL;
    v_delivery_fee DECIMAL;
    v_discount_amount DECIMAL;
    v_tax_rate DECIMAL := 0.05; -- 5% tax rate
    v_order_status VARCHAR;
BEGIN
    -- Get the current order status
    SELECT order_status INTO v_order_status
    FROM orders
    WHERE order_id = NEW.order_id;
    
    -- Only update totals if order is in editable states
    -- Allow changes ONLY for: pending, confirmed
    IF v_order_status IN ('pending', 'confirmed') THEN
        
        -- Calculate subtotal from all order items for this order
        SELECT COALESCE(SUM(quantity * item_price), 0)
        INTO v_subtotal
        FROM order_items
        WHERE order_id = NEW.order_id;
        
        -- Get delivery fee and discount from orders table
        SELECT delivery_fee, discount_amount
        INTO v_delivery_fee, v_discount_amount
        FROM orders
        WHERE order_id = NEW.order_id;
        
        -- Calculate tax (5% of subtotal)
        v_tax_amount := ROUND((v_subtotal * v_tax_rate)::numeric, 2);
        
        -- Update the orders table with calculated values
        UPDATE orders
        SET 
            total_amount = v_subtotal,
            tax_amount = v_tax_amount,
            updated_at = CURRENT_TIMESTAMP
        WHERE order_id = NEW.order_id;
        
    ELSE
        -- Order is NOT in editable state, prevent any changes to order_items
        RAISE EXCEPTION 'Cannot modify order items for order_id % with status %. Items can only be modified for orders in pending or confirmed status.', 
            NEW.order_id, v_order_status;
    END IF;
    
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger on INSERT
CREATE TRIGGER trg_update_order_total_on_insert_item
AFTER INSERT ON order_items
FOR EACH ROW
EXECUTE FUNCTION update_order_total();

-- Trigger on UPDATE
CREATE TRIGGER trg_update_order_total_on_update_item
AFTER UPDATE ON order_items
FOR EACH ROW
WHEN (OLD.quantity IS DISTINCT FROM NEW.quantity 
      OR
	  OLD.item_price IS DISTINCT FROM NEW.item_price)
EXECUTE FUNCTION update_order_total();

-- Trigger on DELETE
CREATE TRIGGER trg_update_order_total_on_delete_item
AFTER DELETE ON order_items
FOR EACH ROW 
EXECUTE FUNCTION update_order_total();

-- 11: Trigger function to log order status changes
