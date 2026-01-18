-- ============================================
-- Food Delivery Database - SQL Queries

-- 64 Business-Oriented SQL Queries
-- ============================================

-- ==========================================
-- PART 1: BASIC QUERIES (1-10)
-- ==========================================

-- 1. List All Active Restaurants
-- Business Use: Restaurant directory for customer browsing
SELECT 
    restaurant_id,
    restaurant_name,
    cuisine_type,
    rating,
    phone_number
FROM restaurants
WHERE is_operational = true
ORDER BY rating DESC;

-- ==========================================

-- 2. Find All Menu Items Under ₹200
-- Business Use: Budget-friendly menu options for price-conscious customers
SELECT 
    mi.item_name,
    r.restaurant_name,
    mi.price,
    mi.category
FROM menu_items mi
JOIN restaurants r ON mi.restaurant_id = r.restaurant_id
WHERE mi.price < 200 AND mi.is_available = true
ORDER BY mi.price ASC;

-- ==========================================

-- 3. Customer Order History
-- Business Use: View recent orders for a specific customer
SELECT 
    o.order_id,
	CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
    r.restaurant_name,
	o.order_date,
    o.final_amount,
    o.order_status
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
JOIN users u ON o.customer_id = u.user_id
WHERE o.customer_id = 46
ORDER BY o.order_date DESC;

-- ==========================================

-- 4. Available Delivery Agents
-- Business Use: Real-time agent availability for order assignment
SELECT 
    u.first_name || ' ' || u.last_name AS agent_name,
    da.vehicle_type,
    da.rating,
    da.total_deliveries
FROM delivery_agents da
JOIN users u ON da.user_id = u.user_id
WHERE da.is_available = true
ORDER BY da.rating DESC;

-- ==========================================

-- 5. Today's Orders
-- Business Use: Daily operational monitoring
SELECT 
    o.order_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    r.restaurant_name,
    o.final_amount,
    o.order_status
FROM orders o
JOIN users u ON o.customer_id = u.user_id
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE DATE(o.order_date) = CURRENT_DATE
ORDER BY o.order_date DESC;

-- ==========================================

-- 6. Pending Payments
-- Business Use: Payment reconciliation and follow-up
SELECT 
    p.payment_id,
    o.order_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    o.final_amount,
    p.payment_status
FROM payments p
JOIN orders o ON p.order_id = o.order_id
JOIN users u ON o.customer_id = u.user_id
WHERE p.payment_status IN ('pending', 'processing')
ORDER BY o.order_date DESC;

-- ==========================================

-- 7. Restaurant Menu by Category
-- Business Use: Organized menu display for customer app
SELECT 
    category,
    item_name,
    description,
    price,
    preparation_time
FROM menu_items
WHERE restaurant_id = 21 AND is_available = true
ORDER BY category, price;

-- ==========================================

-- 8. Customer Addresses
-- Business Use: Delivery address selection for order placement
SELECT 
    ca.address_id,
    ca.address_type,
	CONCAT(u.first_name, ' ', u.last_name) AS customer_name,
    ca.street_address,
    ca.city,
    ca.postal_code,
    ca.is_default
FROM customer_addresses ca
JOIN users u ON ca.customer_id = u.user_id
WHERE customer_id = 46
ORDER BY is_default DESC;

-- ==========================================

-- 9. High-Rated Restaurants
-- Business Use: Featured restaurants for marketing campaigns
SELECT 
    restaurant_name,
    cuisine_type,
    rating,
    total_orders
FROM restaurants
WHERE rating >= 4.5 AND is_operational = true
ORDER BY rating DESC, total_orders DESC
LIMIT 10;

-- ==========================================

-- 10. Orders Awaiting Delivery
-- Business Use: Operations dashboard for dispatch coordination
SELECT 
    o.order_id,
    r.restaurant_name,
    o.order_status,
    o.requested_delivery_time,
    EXTRACT(EPOCH FROM (o.requested_delivery_time - CURRENT_TIMESTAMP))/60 AS minutes_until_delivery
FROM orders o
JOIN restaurants r ON o.restaurant_id = r.restaurant_id
WHERE o.order_status IN ('ready', 'out_for_delivery')
ORDER BY o.requested_delivery_time ASC;

-- ==========================================
-- PART 2: INTERMEDIATE QUERIES (11-20)
-- ==========================================

-- 11. Total Orders and Revenue by Restaurant
-- Business Use: Restaurant performance analytics
SELECT 
    r.restaurant_name,
    r.cuisine_type,
    COUNT(o.order_id) AS total_orders,
    SUM(o.final_amount) AS total_revenue,
    ROUND(AVG(o.final_amount), 2) AS avg_order_value
FROM restaurants r
LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id
    AND o.order_status = 'delivered'
GROUP BY r.restaurant_id, r.restaurant_name, r.cuisine_type
ORDER BY total_revenue DESC NULLS LAST;

-- ==========================================

-- 12. Popular Menu Items
-- Business Use: Inventory planning and promotional targeting
SELECT 
    mi.item_name,
    r.restaurant_name,
    COUNT(oi.order_item_id) AS times_ordered,
    SUM(oi.quantity) AS total_quantity_sold,
    SUM(oi.quantity * oi.item_price) AS revenue_generated
FROM order_items oi
JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
JOIN restaurants r ON mi.restaurant_id = r.restaurant_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
GROUP BY mi.menu_item_id, mi.item_name, r.restaurant_name
ORDER BY times_ordered DESC
LIMIT 20;

-- ==========================================

-- 13. Delivery Agent Performance
-- Business Use: Agent compensation and quality management
SELECT 
    u.first_name || ' ' || u.last_name AS agent_name,
    da.vehicle_type,
    COUNT(d.delivery_id) AS deliveries_completed,
    ROUND(AVG(d.delivery_rating), 2) AS avg_rating,
    ROUND(AVG(EXTRACT(EPOCH FROM (d.actual_delivery_time - d.pickup_time))/60), 2) AS avg_delivery_minutes
FROM delivery_agents da
JOIN users u ON da.user_id = u.user_id
LEFT JOIN deliveries d ON da.agent_id = d.delivery_agent_id
    AND d.delivery_status = 'delivered'
    AND d.actual_delivery_time >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY da.agent_id, u.first_name, u.last_name, da.vehicle_type
HAVING COUNT(d.delivery_id) > 0
ORDER BY deliveries_completed DESC;

-- ==========================================

-- 14. Order Status Distribution
-- Business Use: Real-time operations monitoring
SELECT 
    order_status,
    COUNT(*) AS order_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 2) AS percentage
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '7 days'
GROUP BY order_status
ORDER BY order_count DESC;

-- ==========================================

-- 15. Payment Method Preferences
-- Business Use: Payment gateway optimization and partnerships
SELECT 
    payment_method,
    COUNT(*) AS transaction_count,
    SUM(payment_amount) AS total_amount,
    ROUND(AVG(payment_amount), 2) AS avg_transaction_value
FROM payments
WHERE payment_status = 'completed'
    AND payment_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY payment_method
ORDER BY transaction_count DESC;

-- ==========================================

-- 16. Customer Lifetime Value (CLV)
-- Business Use: Customer segmentation and loyalty programs
SELECT 
    u.user_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    COUNT(o.order_id) AS total_orders,
    SUM(o.final_amount) AS lifetime_value,
    ROUND(AVG(o.final_amount), 2) AS avg_order_value,
    MIN(o.order_date) AS first_order_date,
    MAX(o.order_date) AS last_order_date
FROM users u
JOIN orders o ON u.user_id = o.customer_id
WHERE o.order_status = 'delivered'
GROUP BY u.user_id, u.first_name, u.last_name
--HAVING COUNT(o.order_id) >= 3
ORDER BY lifetime_value DESC
LIMIT 50;

-- ==========================================

-- 17. Restaurant Rating Analysis
-- Business Use: Quality assurance and restaurant partnerships
SELECT 
    r.restaurant_name,
    r.rating AS restaurant_rating,
    COUNT(rv.review_id) AS review_count,
    ROUND(AVG(rv.rating), 2) AS avg_customer_rating,
    ROUND(AVG(rv.food_quality_rating), 2) AS avg_food_rating,
    ROUND(AVG(rv.delivery_rating), 2) AS avg_delivery_rating
FROM restaurants r
LEFT JOIN reviews rv ON r.restaurant_id = rv.restaurant_id
    AND rv.review_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY r.restaurant_id, r.restaurant_name, r.rating
HAVING COUNT(rv.review_id) >= 5
ORDER BY avg_customer_rating DESC;

-- ==========================================

-- 18. Peak Order Times
-- Business Use: Demand forecasting and resource allocation
SELECT 
    EXTRACT(HOUR FROM order_date) AS hour_of_day,
    COUNT(*) AS order_count,
    ROUND(AVG(final_amount), 2) AS avg_order_value
FROM orders
WHERE order_date >= CURRENT_DATE - INTERVAL '30 days'
    AND order_status = 'delivered'
GROUP BY EXTRACT(HOUR FROM order_date)
ORDER BY hour_of_day;

-- ==========================================

-- 19. Cuisine Type Popularity
-- Business Use: Market trend analysis for expansion strategy
SELECT 
    r.cuisine_type,
    COUNT(DISTINCT r.restaurant_id) AS restaurant_count,
    COUNT(o.order_id) AS total_orders,
    SUM(o.final_amount) AS total_revenue,
    ROUND(AVG(o.final_amount), 2) AS avg_order_value
FROM restaurants r
LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id
    AND o.order_status = 'delivered'
    AND o.order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY r.cuisine_type
ORDER BY total_revenue DESC NULLS LAST;

-- ==========================================

-- 20. Failed Deliveries Analysis
-- Business Use: Service quality improvement and issue resolution
SELECT 
    DATE(o.order_date) AS order_date,
    COUNT(*) AS cancelled_orders,
    ROUND(AVG(o.final_amount), 2) AS avg_lost_revenue
FROM orders o
WHERE o.order_status = 'cancelled'
    AND o.order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY DATE(o.order_date)
ORDER BY order_date DESC;

-- ==========================================
-- PART 3: ADVANCED QUERIES (21-35)
-- ==========================================

-- 21. Customer Retention Rate
-- Business Use: Measure customer loyalty and retention effectiveness
WITH customer_months AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', order_date) AS order_month
    FROM orders
    WHERE order_status = 'delivered'
        AND order_date >= CURRENT_DATE - INTERVAL '6 months'
    GROUP BY customer_id, DATE_TRUNC('month', order_date)
),
customer_months_with_retention_check AS (
    SELECT 
	    customer_id,
		order_month,
		LAG(order_month) OVER ( PARTITION BY customer_id ORDER BY order_month)
		    AS prev_order_month
	FROM customer_months
),
retention_calc AS (
    SELECT 
        order_month,
        COUNT(DISTINCT customer_id) AS active_customers,
        COUNT(DISTINCT CASE 
            WHEN prev_order_month IS NOT NULL 
            THEN customer_id 
        END) AS retained_customers
    FROM customer_months_with_retention_check
    GROUP BY order_month
)
SELECT 
    order_month,
    active_customers,
    retained_customers,
    ROUND(retained_customers * 100.0 / NULLIF(active_customers, 0), 2) AS retention_rate_pct
FROM retention_calc
ORDER BY order_month DESC;

-- ==========================================

-- 22. Restaurant Revenue Ranking with Running Total
-- Business Use: Performance dashboards and competitive analysis
SELECT 
    restaurant_name,
    total_revenue,
    RANK() OVER (ORDER BY total_revenue DESC) AS revenue_rank,
    SUM(total_revenue) OVER (ORDER BY total_revenue DESC ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS cumulative_revenue,
    ROUND(total_revenue * 100.0 / SUM(total_revenue) OVER(), 2) AS pct_of_total_revenue
FROM (
    SELECT 
        r.restaurant_name,
        COALESCE(SUM(o.final_amount), 0) AS total_revenue
    FROM restaurants r
    LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id
        AND o.order_status = 'delivered'
        AND o.order_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY r.restaurant_id, r.restaurant_name
) revenue_data
ORDER BY revenue_rank;

-- ==========================================

-- 23. Customer Segmentation (RFM Analysis) (Recency, Frequency, Monetary)
-- Business Use: Targeted marketing campaigns based on customer behavior
WITH rfm_base AS (
    SELECT 
        customer_id,
        MAX(order_date) AS last_order_date,
        COUNT(order_id) AS frequency,
        SUM(final_amount) AS monetary_value
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY customer_id
),
rfm_scores AS (
    SELECT 
        customer_id,
        EXTRACT(DAY FROM CURRENT_DATE - last_order_date) AS recency_days,
        frequency,
        monetary_value,
        NTILE(5) OVER (ORDER BY EXTRACT(DAY FROM CURRENT_DATE - last_order_date) DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary_value) AS monetary_score
    FROM rfm_base
)
SELECT 
    u.first_name || ' ' || u.last_name AS customer_name,
    u.email,
    r.recency_days,
    r.frequency AS total_orders,
    r.monetary_value AS total_spent,
    r.recency_score,
    r.frequency_score,
    r.monetary_score,
    CASE 
        WHEN r.recency_score >= 4 AND r.frequency_score >= 4 THEN 'Champions'
        WHEN r.recency_score >= 3 AND r.frequency_score >= 3 THEN 'Loyal Customers'
        WHEN r.monetary_score >= 4 THEN 'Big Spenders'
        WHEN r.recency_score >= 4 THEN 'Recent Customers'
        WHEN r.recency_score <= 2 AND r.frequency_score >= 3 THEN 'At Risk'
        WHEN r.recency_score <= 2 THEN 'Lost Customers'
        ELSE 'Regular Customers'
    END AS customer_segment
FROM rfm_scores r
JOIN users u ON r.customer_id = u.user_id
ORDER BY r.monetary_value DESC;

-- ==========================================

-- 24. Day-over-Day Growth Analysis
-- Business Use: Monitor business growth trends
WITH daily_metrics AS (
    SELECT 
        DATE(order_date) AS order_date,
        COUNT(order_id) AS orders,
        SUM(final_amount) AS revenue
    FROM orders
    WHERE order_status = 'delivered'
        AND order_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY DATE(order_date)
)
SELECT 
    order_date,
    orders,
    revenue,
    LAG(orders) OVER (ORDER BY order_date) AS prev_day_orders,
    orders - LAG(orders) OVER (ORDER BY order_date) AS order_change,
    ROUND((orders - LAG(orders) OVER (ORDER BY order_date)) * 100.0 / 
        NULLIF(LAG(orders) OVER (ORDER BY order_date), 0), 2) AS order_growth_pct,
    LAG(revenue) OVER (ORDER BY order_date) AS prev_day_revenue,
    revenue - LAG(revenue) OVER (ORDER BY order_date) AS revenue_change,
    ROUND((revenue - LAG(revenue) OVER (ORDER BY order_date)) * 100.0 / 
        NULLIF(LAG(revenue) OVER (ORDER BY order_date), 0), 2) AS revenue_growth_pct
FROM daily_metrics
ORDER BY order_date DESC;

-- ==========================================

-- 25. Average Delivery Time by City
-- Business Use: Logistics optimization and service level agreements
SELECT 
    ca.city,
    COUNT(d.delivery_id) AS total_deliveries,
    ROUND(AVG(EXTRACT(EPOCH FROM (d.actual_delivery_time - d.pickup_time))/60), 2) AS avg_delivery_minutes,
    ROUND(AVG(d.distance_km), 2) AS avg_distance_km,
    ROUND(AVG(d.delivery_rating), 2) AS avg_rating,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY EXTRACT(EPOCH FROM (d.actual_delivery_time - d.pickup_time))/60)::NUMERIC, 2) AS median_delivery_minutes
FROM deliveries d
JOIN orders o ON d.order_id = o.order_id
JOIN customer_addresses ca ON o.delivery_address_id = ca.address_id
WHERE d.delivery_status = 'delivered'
    AND d.actual_delivery_time >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY ca.city
--HAVING COUNT(d.delivery_id) >= 10
ORDER BY total_deliveries DESC;

-- ==========================================

-- 26. Menu Item Performance by Time of Day
-- Business Use: Dynamic pricing and inventory management
SELECT 
    mi.item_name,
    mi.category,
    CASE 
        WHEN EXTRACT(HOUR FROM o.order_date) BETWEEN 6 AND 11 THEN 'Breakfast'
        WHEN EXTRACT(HOUR FROM o.order_date) BETWEEN 12 AND 16 THEN 'Lunch'
        WHEN EXTRACT(HOUR FROM o.order_date) BETWEEN 17 AND 21 THEN 'Dinner'
        ELSE 'Late Night'
    END AS meal_period,
    COUNT(oi.order_item_id) AS times_ordered,
    SUM(oi.quantity) AS total_quantity,
    SUM(oi.quantity * oi.item_price) AS revenue
FROM order_items oi
JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
JOIN orders o ON oi.order_id = o.order_id
WHERE o.order_status = 'delivered'
    --AND o.order_date >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY mi.menu_item_id, mi.item_name, mi.category, meal_period
ORDER BY meal_period, times_ordered DESC;

-- ==========================================

-- 27. Customer Churn Prediction Dataset
-- Business Use: Identify customers at risk of churning
WITH customer_activity AS (
    SELECT 
        customer_id,
        MAX(order_date) AS last_order_date,
        COUNT(order_id) AS total_orders,
        SUM(final_amount) AS total_spent,
        ROUND(AVG(final_amount), 2) AS avg_order_value,
        COUNT(DISTINCT restaurant_id) AS unique_restaurants,
        ROUND(EXTRACT(EPOCH FROM (MAX(order_date) - MIN(order_date)))/86400, 0) AS customer_lifespan_days
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY customer_id
)
SELECT 
    u.user_id,
    u.first_name || ' ' || u.last_name AS customer_name,
    u.email,
    ca.last_order_date,
    EXTRACT(DAY FROM CURRENT_DATE - ca.last_order_date) AS days_since_last_order,
    ca.total_orders,
    ca.total_spent,
    ca.avg_order_value,
    ca.unique_restaurants,
    ca.customer_lifespan_days,
    ROUND(ca.total_orders::NUMERIC / NULLIF(ca.customer_lifespan_days, 0) * 30, 2) AS avg_orders_per_month,
    CASE 
        WHEN EXTRACT(DAY FROM CURRENT_DATE - ca.last_order_date) > 60 THEN 'High Risk'
        WHEN EXTRACT(DAY FROM CURRENT_DATE - ca.last_order_date) > 30 THEN 'Medium Risk'
        ELSE 'Active'
    END AS churn_risk
FROM users u
JOIN customer_activity ca ON u.user_id = ca.customer_id
WHERE u.user_type = 'customer'
ORDER BY days_since_last_order DESC;

-- ==========================================

-- 28. Restaurant Performance Comparison
-- Business Use: Benchmarking and competitive analysis
WITH restaurant_metrics AS (
    SELECT 
        r.restaurant_id,
        r.restaurant_name,
        r.cuisine_type,
        r.rating AS restaurant_rating,
        COUNT(o.order_id) AS total_orders,
        SUM(o.final_amount) AS revenue,
        ROUND(AVG(o.final_amount), 2) AS avg_order_value,
        COUNT(DISTINCT o.customer_id) AS unique_customers,
        ROUND(AVG(rv.rating), 2) AS avg_review_rating
    FROM restaurants r
    LEFT JOIN orders o ON r.restaurant_id = o.restaurant_id
        AND o.order_status = 'delivered'
        --AND o.order_date >= CURRENT_DATE - INTERVAL '30 days'
    LEFT JOIN reviews rv ON r.restaurant_id = rv.restaurant_id
        --AND rv.review_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY r.restaurant_id, r.restaurant_name, r.cuisine_type, r.rating
)
SELECT 
    restaurant_name,
    cuisine_type,
    total_orders,
    revenue,
    avg_order_value,
    unique_customers,
    avg_review_rating,
    ROUND(AVG(total_orders) OVER (PARTITION BY cuisine_type), 2) AS cuisine_avg_orders,
    ROUND(AVG(revenue) OVER (PARTITION BY cuisine_type), 2) AS cuisine_avg_revenue,
    ROUND((total_orders - AVG(total_orders) OVER (PARTITION BY cuisine_type)) * 100.0 / 
        NULLIF(AVG(total_orders) OVER (PARTITION BY cuisine_type), 0), 2) AS vs_cuisine_avg_pct
FROM restaurant_metrics
WHERE total_orders > 0
ORDER BY revenue DESC;

-- ==========================================

-- 29. Order Fulfillment Time Analysis
-- Business Use: Operations efficiency and SLA(Service Level Agreement) monitoring
WITH fulfillment_times AS (
    SELECT 
        o.order_id,
        o.order_date,
        o.requested_delivery_time,
        d.pickup_time,
        d.actual_delivery_time,
        EXTRACT(EPOCH FROM (d.pickup_time - o.order_date))/60 AS prep_time_minutes,
        EXTRACT(EPOCH FROM (d.actual_delivery_time - d.pickup_time))/60 AS delivery_time_minutes,
        EXTRACT(EPOCH FROM (d.actual_delivery_time - o.order_date))/60 AS total_time_minutes,
        EXTRACT(EPOCH FROM (o.requested_delivery_time - d.actual_delivery_time))/60 AS time_vs_estimate_minutes
    FROM orders o
    JOIN deliveries d ON o.order_id = d.order_id
    WHERE d.delivery_status = 'delivered'
        --AND d.actual_delivery_time >= CURRENT_DATE - INTERVAL '7 days'
)
SELECT 
    DATE(order_date) AS order_date,
    COUNT(*) AS total_deliveries,
    ROUND(AVG(prep_time_minutes), 2) AS avg_prep_time,
    ROUND(AVG(delivery_time_minutes), 2) AS avg_delivery_time,
    ROUND(AVG(total_time_minutes), 2) AS avg_total_time,
    ROUND(PERCENTILE_CONT(0.5) WITHIN GROUP (ORDER BY total_time_minutes)::NUMERIC, 2) AS median_total_time,
    COUNT(CASE WHEN time_vs_estimate_minutes >= 0 THEN 1 END) AS on_time_deliveries,
    ROUND(COUNT(CASE WHEN time_vs_estimate_minutes >= 0 THEN 1 END) * 100.0 / COUNT(*), 2) AS on_time_pct
FROM fulfillment_times
GROUP BY DATE(order_date)
ORDER BY order_date DESC;

-- ==========================================

-- 30. Top Customers by Restaurant
-- Business Use: Restaurant-specific loyalty programs
WITH customer_restaurant_orders AS (
    SELECT 
        o.customer_id,
        o.restaurant_id,
        COUNT(o.order_id) AS order_count,
        SUM(o.final_amount) AS total_spent,
        MAX(o.order_date) AS last_order_date
    FROM orders o
    WHERE o.order_status = 'delivered'
    GROUP BY o.customer_id, o.restaurant_id
),
ranked_customers AS (
    SELECT 
        restaurant_id,
        customer_id,
        order_count,
        total_spent,
        last_order_date,
        ROW_NUMBER() OVER (PARTITION BY restaurant_id ORDER BY total_spent DESC) AS customer_rank
    FROM customer_restaurant_orders
)
SELECT 
    r.restaurant_name,
    u.first_name || ' ' || u.last_name AS customer_name,
    u.email,
    rc.order_count,
    rc.total_spent,
    rc.last_order_date,
    rc.customer_rank
FROM ranked_customers rc
JOIN restaurants r ON rc.restaurant_id = r.restaurant_id
JOIN users u ON rc.customer_id = u.user_id
WHERE rc.customer_rank <= 5
ORDER BY r.restaurant_name, rc.customer_rank;

-- ==========================================

-- 31. Revenue Attribution by Day of Week
-- Business Use: Marketing campaign scheduling and staffing decisions
SELECT 
    TO_CHAR(order_date, 'Day') AS day_of_week,
    EXTRACT(DOW FROM order_date) AS day_num,
    COUNT(order_id) AS total_orders,
    SUM(final_amount) AS revenue,
    ROUND(AVG(final_amount), 2) AS avg_order_value,
    COUNT(DISTINCT customer_id) AS unique_customers,
    ROUND(SUM(final_amount) * 100.0 / SUM(SUM(final_amount)) OVER(), 2) AS pct_of_weekly_revenue
FROM orders
WHERE order_status = 'delivered'
    AND order_date >= CURRENT_DATE - INTERVAL '90 days'
GROUP BY TO_CHAR(order_date, 'Day'), EXTRACT(DOW FROM order_date)
ORDER BY day_num;

-- ==========================================

-- 32. Cross-Sell Analysis (Items Ordered Together)
-- Business Use: Recommendation engine and upselling
WITH item_pairs AS (
    SELECT 
        oi1.menu_item_id AS item1_id,
        oi2.menu_item_id AS item2_id,
        COUNT(*) AS times_ordered_together
    FROM order_items oi1
    JOIN order_items oi2 ON oi1.order_id = oi2.order_id
        AND oi1.menu_item_id < oi2.menu_item_id
    JOIN orders o ON oi1.order_id = o.order_id
    WHERE o.order_status = 'delivered'
        --AND o.order_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY oi1.menu_item_id, oi2.menu_item_id
    --HAVING COUNT(*) >= 3
)
SELECT 
    mi1.item_name AS item1,
    mi2.item_name AS item2,
    r.restaurant_name,
    ip.times_ordered_together,
    ROUND(ip.times_ordered_together * 100.0 / 
        (SELECT COUNT(DISTINCT order_id) FROM order_items WHERE menu_item_id = ip.item1_id), 2) AS support_pct
FROM item_pairs ip
JOIN menu_items mi1 ON ip.item1_id = mi1.menu_item_id
JOIN menu_items mi2 ON ip.item2_id = mi2.menu_item_id
JOIN restaurants r ON mi1.restaurant_id = r.restaurant_id
ORDER BY times_ordered_together DESC
LIMIT 20;

-- ==========================================

-- 33. Delivery Agent Efficiency Scorecard
-- Business Use: Performance evaluation and bonus calculation
WITH agent_stats AS (
    SELECT 
        da.agent_id,
        COUNT(d.delivery_id) AS total_deliveries,
        ROUND(AVG(EXTRACT(EPOCH FROM (d.actual_delivery_time - d.pickup_time))/60), 2) AS avg_delivery_time,
        ROUND(AVG(d.distance_km), 2) AS avg_distance,
        ROUND(AVG(d.delivery_rating), 2) AS avg_rating,
        COUNT(CASE WHEN EXTRACT(EPOCH FROM (d.actual_delivery_time - d.estimated_delivery_time))/60 <= 0 THEN 1 END) AS on_time_deliveries,
        SUM(o.delivery_fee) AS total_delivery_fees
    FROM delivery_agents da
    JOIN deliveries d ON da.agent_id = d.delivery_agent_id
    JOIN orders o ON d.order_id = o.order_id
    WHERE d.delivery_status = 'delivered'
        --AND d.actual_delivery_time >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY da.agent_id
)
SELECT 
    u.first_name || ' ' || u.last_name AS agent_name,
    da.vehicle_type,
    ast.total_deliveries,
    ast.avg_delivery_time,
    ast.avg_distance,
    ast.avg_rating,
    ROUND(ast.on_time_deliveries * 100.0 / ast.total_deliveries, 2) AS on_time_pct,
    ast.total_delivery_fees,
    ROUND(ast.total_delivery_fees / ast.total_deliveries, 2) AS avg_fee_per_delivery,
    CASE 
        WHEN ast.avg_rating >= 4.5 AND ast.on_time_deliveries * 100.0 / ast.total_deliveries >= 90 THEN 'Excellent'
        WHEN ast.avg_rating >= 4.0 AND ast.on_time_deliveries * 100.0 / ast.total_deliveries >= 80 THEN 'Good'
        WHEN ast.avg_rating >= 3.5 THEN 'Average'
        ELSE 'Needs Improvement'
    END AS performance_grade
FROM agent_stats ast
JOIN delivery_agents da ON ast.agent_id = da.agent_id
JOIN users u ON da.user_id = u.user_id
ORDER BY ast.total_deliveries DESC;

-- ==========================================

-- 34. Monthly Cohort(group) Analysis
-- Groups customers by their first order month and tracks down how many returns in subsequent months
-- Business Use: Long-term customer behavior and retention insights
WITH first_orders AS (
    SELECT 
        customer_id,
        DATE_TRUNC('month', MIN(order_date)) AS cohort_month
    FROM orders
    WHERE order_status = 'delivered'
    GROUP BY customer_id
),
customer_orders AS (
    SELECT 
        o.customer_id,
        fo.cohort_month,
        DATE_TRUNC('month', o.order_date) AS order_month,
        EXTRACT(MONTH FROM AGE(DATE_TRUNC('month', o.order_date), fo.cohort_month)) AS months_since_first_order
    FROM orders o
    JOIN first_orders fo ON o.customer_id = fo.customer_id
    WHERE o.order_status = 'delivered'
)
SELECT 
    cohort_month,
    COUNT(DISTINCT CASE WHEN months_since_first_order = 0 THEN customer_id END) AS month_0,
    COUNT(DISTINCT CASE WHEN months_since_first_order = 1 THEN customer_id END) AS month_1,
    COUNT(DISTINCT CASE WHEN months_since_first_order = 2 THEN customer_id END) AS month_2,
    COUNT(DISTINCT CASE WHEN months_since_first_order = 3 THEN customer_id END) AS month_3,
    ROUND(COUNT(DISTINCT CASE WHEN months_since_first_order = 1 THEN customer_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT CASE WHEN months_since_first_order = 0 THEN customer_id END), 0), 2) AS retention_month_1,
    ROUND(COUNT(DISTINCT CASE WHEN months_since_first_order = 2 THEN customer_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT CASE WHEN months_since_first_order = 0 THEN customer_id END), 0), 2) AS retention_month_2,
    ROUND(COUNT(DISTINCT CASE WHEN months_since_first_order = 3 THEN customer_id END) * 100.0 / 
        NULLIF(COUNT(DISTINCT CASE WHEN months_since_first_order = 0 THEN customer_id END), 0), 2) AS retention_month_3
FROM customer_orders
WHERE cohort_month >= DATE_TRUNC('month', CURRENT_DATE - INTERVAL '6 months')
GROUP BY cohort_month
ORDER BY cohort_month DESC;

-- ==========================================

-- 35. Order Status Transition Timeline
-- Business Use: Process mining and bottleneck identification
SELECT 
    order_id,
    order_status AS current_status,
    created_at,
    ROUND(EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - created_at))/3600, 2) AS hours_in_current_status,
    CASE 
        WHEN order_status = 'pending' AND EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - created_at))/3600 > 1 THEN 'Warning - Long Pending'
		WHEN order_status = 'confirmed' AND EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - created_at))/3600 > 1 THEN 'Warning - Long Confirmed'
        WHEN order_status = 'preparing' AND EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - created_at))/3600 > 2 THEN 'Warning - Long Preparation'
		WHEN order_status = 'ready' AND EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - created_at))/3600 > 1 THEN 'Warning - Long Ready'
        WHEN order_status = 'out_for_delivery' AND EXTRACT(EPOCH FROM (CURRENT_TIMESTAMP - created_at))/3600 > 1.5 THEN 'Warning - Long Delivery'
        ELSE 'On Track'
    END AS status_alert
FROM orders
WHERE order_status NOT IN ('delivered', 'cancelled')
    --AND created_at >= CURRENT_TIMESTAMP - INTERVAL '1 day'
ORDER BY hours_in_current_status DESC;

-- ==========================================
-- PART 4: EXTREMELY ADVANCED QUERIES (36-50)
-- ==========================================

-- 36. Advanced Time-Series Forecasting Data
-- Business Use: Machine learning preparation for demand forecasting
WITH daily_orders AS (
    SELECT 
        order_date,
        EXTRACT(DOW FROM order_date) AS day_of_week,
        EXTRACT(MONTH FROM order_date) AS month,
        COUNT(order_id) AS order_count,
        SUM(final_amount) AS revenue
    FROM(
	    SELECT
		    DATE(order_date) AS order_date,
			order_id,
			final_amount
		FROM orders
        WHERE order_status = 'delivered'
        AND order_date >= CURRENT_DATE - INTERVAL '90 days'
		) t
    GROUP BY order_date
),
moving_averages AS (
    SELECT 
        order_date,
        day_of_week,
        month,
        order_count,
        revenue,
        ROUND(AVG(order_count) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS ma_7day_orders,
        ROUND(AVG(order_count) OVER (ORDER BY order_date ROWS BETWEEN 29 PRECEDING AND CURRENT ROW), 2) AS ma_30day_orders,
        ROUND(AVG(revenue) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS ma_7day_revenue,
        ROUND(STDDEV(order_count) OVER (ORDER BY order_date ROWS BETWEEN 6 PRECEDING AND CURRENT ROW), 2) AS stddev_7day_orders -- volatility(order fluctuation)
    FROM daily_orders
)
SELECT 
    order_date,
    day_of_week,
    month,
    order_count,
    revenue,
    ma_7day_orders,
    ma_30day_orders,
    ma_7day_revenue,
    stddev_7day_orders,
    ROUND((order_count - ma_7day_orders) / NULLIF(stddev_7day_orders, 0), 2) AS z_score, -- anomaly detection
    LAG(order_count, 7) OVER (ORDER BY order_date) AS orders_same_day_last_week,
    ROUND((order_count - LAG(order_count, 7) OVER (ORDER BY order_date)) * 100.0 / 
        NULLIF(LAG(order_count, 7) OVER (ORDER BY order_date), 0), 2) AS wow_growth_pct
FROM moving_averages
ORDER BY order_date DESC;

-- ==========================================

-- 37. Customer Segmentation (Advanced RFM(Recency Frequency Monetary) with Additional Dimensions)
-- Business Use: Advanced marketing automation and personalization
WITH customer_dimensions AS (
    SELECT 
        o.customer_id,
        -- Recency dimension
        EXTRACT(DAY FROM CURRENT_DATE - MAX(o.order_date)) AS recency_days,
        -- Frequency dimension
        COUNT(o.order_id) AS frequency,
        -- Monetary dimension
        SUM(o.final_amount) AS monetary,
        -- Diversity dimension
        COUNT(DISTINCT o.restaurant_id) AS restaurant_diversity,
        COUNT(DISTINCT mi.category) AS category_diversity,
        -- Time-based dimension
        COUNT(CASE WHEN EXTRACT(HOUR FROM o.order_date) BETWEEN 6 AND 11 THEN 1 END) AS breakfast_orders,
        COUNT(CASE WHEN EXTRACT(HOUR FROM o.order_date) BETWEEN 12 AND 16 THEN 1 END) AS lunch_orders,
        COUNT(CASE WHEN EXTRACT(HOUR FROM o.order_date) BETWEEN 17 AND 21 THEN 1 END) AS dinner_orders,
        -- Price sensitivity
        ROUND(AVG(o.discount_amount), 2) AS avg_discount_used,
        -- Average order value
        ROUND(AVG(o.final_amount), 2) AS avg_order_value
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
    WHERE o.order_status = 'delivered'
    GROUP BY o.customer_id
),
scored_dimensions AS (
    SELECT 
        customer_id,
        recency_days,
        frequency,
        monetary,
        NTILE(5) OVER (ORDER BY recency_days DESC) AS recency_score,
        NTILE(5) OVER (ORDER BY frequency) AS frequency_score,
        NTILE(5) OVER (ORDER BY monetary) AS monetary_score,
        NTILE(3) OVER (ORDER BY restaurant_diversity) AS diversity_score,
        CASE 
            WHEN breakfast_orders > lunch_orders AND breakfast_orders > dinner_orders THEN 'Breakfast'
            WHEN lunch_orders > dinner_orders THEN 'Lunch'
            ELSE 'Dinner'
        END AS preferred_meal_time,
        avg_discount_used,
        avg_order_value,
        restaurant_diversity,
        category_diversity
    FROM customer_dimensions
)
SELECT 
    u.first_name || ' ' || u.last_name AS customer_name,
    u.email,
    sd.recency_days,
    sd.frequency,
    sd.monetary,
    sd.recency_score,
    sd.frequency_score,
    sd.monetary_score,
    sd.diversity_score,
    sd.preferred_meal_time,
    sd.avg_order_value,
    CASE 
        WHEN sd.recency_score >= 4 AND sd.frequency_score >= 4 AND sd.monetary_score >= 4 THEN 'VIP Champions'
        WHEN sd.monetary_score >= 4 THEN 'High Value'
        WHEN sd.frequency_score >= 4 THEN 'Frequent Buyers'
        WHEN sd.recency_score >= 4 THEN 'Recent Customers'
        WHEN sd.diversity_score >= 2 THEN 'Explorers'
        WHEN sd.recency_score <= 2 AND sd.frequency_score >= 3 THEN 'At Risk Loyalists'
        WHEN sd.recency_score <= 2 THEN 'Churned'
        ELSE 'Casual'
    END AS segment,
    CASE 
        WHEN sd.recency_score >= 4 AND sd.frequency_score >= 4 THEN 'Loyalty rewards'
        WHEN sd.monetary_score >= 4 THEN 'Premium offerings'
        WHEN sd.recency_score <= 2 AND sd.frequency_score >= 3 THEN 'Win-back campaign'
        WHEN sd.diversity_score <= 1 THEN 'New restaurant discovery'
        ELSE 'Standard engagement'
    END AS recommended_action
FROM scored_dimensions sd
JOIN users u ON sd.customer_id = u.user_id
ORDER BY sd.monetary DESC;

-- ==========================================

-- 38. Real-Time Anomaly Detection
-- Business Use: System health monitoring and incident response
WITH recent_metrics AS (
    SELECT 
        DATE_TRUNC('minute', order_date) AS minute_slot,
        COUNT(*) AS order_count,
        SUM(final_amount) AS revenue,
        COUNT(DISTINCT customer_id) AS unique_customers,
        COUNT(CASE WHEN order_status = 'cancelled' THEN 1 END) AS cancelled_count
    FROM orders
    WHERE order_date >= CURRENT_TIMESTAMP - INTERVAL '2 hours'
    GROUP BY DATE_TRUNC('minute', order_date)
),
baseline_metrics AS (
    SELECT 
        hour_of_day,
        ROUND(AVG(order_count_per_minute), 2) AS baseline_avg_orders,
        ROUND(STDDEV(order_count_per_minute), 2) AS baseline_stddev_orders
    FROM (
        SELECT 
            DATE_TRUNC('minute', order_date) AS minute_slot,
            EXTRACT(HOUR FROM order_date) AS hour_of_day,
            COUNT(*) AS order_count_per_minute
        FROM orders
        WHERE order_status = 'delivered'
            AND order_date >= CURRENT_DATE - INTERVAL '30 days'
            AND order_date < CURRENT_DATE - INTERVAL '2 hours'
        GROUP BY DATE_TRUNC('minute', order_date), EXTRACT(HOUR FROM order_date)
    ) historical
    GROUP BY hour_of_day
),
anomaly_detection AS (
    SELECT 
        rm.minute_slot,
        rm.order_count,
        bm.baseline_avg_orders,
        CASE 
            WHEN bm.baseline_stddev_orders > 0 
            THEN ROUND((rm.order_count - bm.baseline_avg_orders) / bm.baseline_stddev_orders, 2)
            ELSE 0
        END AS order_zscore,
        rm.cancelled_count
    FROM recent_metrics rm
    LEFT JOIN baseline_metrics bm ON EXTRACT(HOUR FROM rm.minute_slot) = bm.hour_of_day
)
SELECT 
    minute_slot,
    order_count,
    baseline_avg_orders,
    order_zscore,
    cancelled_count,
    CASE 
        WHEN order_zscore < -2 THEN 'Critical Low - Order Volume Drop'
        WHEN order_zscore > 3 THEN 'Critical High - Unusual Spike'
        WHEN cancelled_count > 10 THEN 'Warning - High Cancellations'
        ELSE 'Normal'
    END AS anomaly_alert
FROM anomaly_detection
WHERE minute_slot >= CURRENT_TIMESTAMP - INTERVAL '30 minutes'
ORDER BY minute_slot DESC;

-- ==========================================

-- 39. Comprehensive Business Intelligence Dashboard Query
-- Business Use: Executive-level KPI(Key Performance Indicator) dashboard
WITH date_range AS (
    SELECT 
        CURRENT_DATE - INTERVAL '30 days' AS start_date,
        CURRENT_DATE AS end_date
),
current_period_metrics AS (
    SELECT 
        COUNT(DISTINCT o.order_id) AS total_orders,
        COUNT(DISTINCT o.customer_id) AS active_customers,
        COUNT(DISTINCT o.restaurant_id) AS active_restaurants,
        SUM(o.final_amount) AS total_revenue,
        ROUND(AVG(o.final_amount), 2) AS avg_order_value,
        COUNT(CASE WHEN o.order_status = 'delivered' THEN 1 END) AS delivered_orders,
        COUNT(CASE WHEN o.order_status = 'cancelled' THEN 1 END) AS cancelled_orders,
        SUM(o.delivery_fee) AS delivery_revenue,
        SUM(o.tax_amount) AS tax_collected
    FROM orders o
    CROSS JOIN date_range dr
    WHERE o.order_date >= dr.start_date AND o.order_date < dr.end_date
),
operational_metrics AS (
    SELECT 
        ROUND(AVG(EXTRACT(EPOCH FROM (d.actual_delivery_time - o.order_date))/60), 2) AS avg_fulfillment_minutes,
        ROUND(AVG(d.delivery_rating), 2) AS avg_delivery_rating
    FROM orders o
    JOIN deliveries d ON o.order_id = d.order_id
    CROSS JOIN date_range dr
    WHERE d.delivery_status = 'delivered'
        AND o.order_date >= dr.start_date AND o.order_date < dr.end_date
)
SELECT 
    'KPI_Dashboard' AS dashboard_section,
    cpm.total_revenue AS revenue_30d,
    cpm.avg_order_value,
    cpm.total_orders,
    cpm.delivered_orders,
    ROUND(cpm.cancelled_orders * 100.0 / cpm.total_orders, 2) AS cancellation_rate_pct,
    cpm.active_customers,
    cpm.active_restaurants,
    om.avg_fulfillment_minutes,
    om.avg_delivery_rating,
    cpm.delivery_revenue,
    cpm.tax_collected
FROM current_period_metrics cpm
CROSS JOIN operational_metrics om;

-- ==========================================

-- 40. Peak Load Forecasting with Historical Patterns
-- Business Use: Resource allocation and predictive staffing
WITH historical_patterns AS (
    SELECT 
        EXTRACT(DOW FROM order_date) AS day_of_week,
        EXTRACT(HOUR FROM order_date) AS hour_of_day,
        COUNT(order_id) AS order_count,
        SUM(final_amount) AS revenue
    FROM orders
    WHERE order_status = 'delivered'
        AND order_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY EXTRACT(DOW FROM order_date), EXTRACT(HOUR FROM order_date)
),
pattern_aggregates AS (
    SELECT 
        day_of_week,
        hour_of_day,
        ROUND(AVG(order_count), 2) AS avg_orders,
        ROUND(PERCENTILE_CONT(0.9) WITHIN GROUP (ORDER BY order_count)::numeric, 2) AS p90_orders,
        ROUND(AVG(revenue), 2) AS avg_revenue,
        MAX(order_count) AS historical_max_orders
    FROM historical_patterns
    GROUP BY day_of_week, hour_of_day
)
SELECT 
    TO_CHAR(CURRENT_DATE + INTERVAL '1 day', 'Day') AS forecast_day,
    pa.hour_of_day,
    pa.avg_orders AS forecasted_orders,
    pa.p90_orders AS peak_orders,
    pa.avg_revenue AS forecasted_revenue,
    pa.historical_max_orders,
    CASE 
        WHEN pa.avg_orders >= 50 THEN 'High Load - 5+ staff'
        WHEN pa.avg_orders >= 30 THEN 'Medium Load - 3-4 staff'
        WHEN pa.avg_orders >= 15 THEN 'Low-Medium Load - 2-3 staff'
        ELSE 'Low Load - 1-2 staff'
    END AS staffing_recommendation,
    CEIL(pa.p90_orders / 5) AS recommended_delivery_agents
FROM pattern_aggregates pa
--WHERE pa.day_of_week = EXTRACT(DOW FROM CURRENT_DATE + INTERVAL '1 day')
ORDER BY pa.hour_of_day;

-- ==========================================

-- 41. Fraud Detection - Suspicious Order Patterns
-- Business Use: Risk management and fraud prevention
WITH customer_behavior AS (
    SELECT 
        o.customer_id,
        COUNT(o.order_id) AS total_orders,
        COUNT(CASE WHEN o.order_status = 'cancelled' THEN 1 END) AS cancelled_orders,
        COUNT(DISTINCT o.delivery_address_id) AS unique_addresses,
        MAX(o.final_amount) AS max_order_value,
        ROUND(AVG(o.final_amount), 2) AS avg_order_value
    FROM orders o
	WHERE o.order_status IN ('delivered','cancelled')
	  AND o.order_date >= CURRENT_DATE - INTERVAl '90 days'
    GROUP BY o.customer_id
)
SELECT 
    u.first_name || ' ' || u.last_name AS customer_name,
    u.email,
    u.phone_number,
    cb.total_orders,
    cb.cancelled_orders,
    cb.unique_addresses,
    cb.max_order_value,
    cb.avg_order_value,
    CASE 
        WHEN cb.cancelled_orders * 100.0 / NULLIF(cb.total_orders, 0) > 50 THEN 'High Risk - Excessive Cancellations'
        WHEN cb.max_order_value > cb.avg_order_value * 3 AND cb.total_orders < 3 THEN 'High Risk - Large Order New Account'
        WHEN cb.unique_addresses > cb.total_orders / 2 THEN 'High Risk - Multiple Addresses'
		WHEN cb.cancelled_orders * 100.0 / NULLIF(cb.total_orders, 0) BETWEEN 30 AND 50 THEN 'Medium Risk - Elevated Cancellations'
        ELSE 'Low Risk'
    END AS risk_category
FROM customer_behavior cb
JOIN users u ON cb.customer_id = u.user_id
WHERE cb.cancelled_orders * 100.0 / cb.total_orders > 30
    OR (cb.max_order_value > cb.avg_order_value * 3 AND cb.total_orders < 3)
ORDER BY cb.cancelled_orders DESC;

-- ==========================================

-- 42. Dynamic Pricing Recommendation Engine
-- Business Use: Optimize prices based on demand and competition
WITH item_performance AS (
    SELECT 
        mi.menu_item_id,
        mi.item_name,
        mi.restaurant_id,
        mi.price AS current_price,
        mi.category,
        COUNT(
		   CASE 
		     WHEN o.order_id IS NOT NULL THEN oi.order_item_id
		   END
			 ) AS times_ordered_30d,
        SUM(oi.quantity) AS total_quantity_30d,
        ROUND(AVG(oi.item_price), 2) AS avg_selling_price
    FROM menu_items mi
    LEFT JOIN order_items oi ON mi.menu_item_id = oi.menu_item_id
    LEFT JOIN orders o ON oi.order_id = o.order_id
        AND o.order_status = 'delivered'
        --AND o.order_date >= CURRENT_DATE - INTERVAL '30 days'
    GROUP BY mi.menu_item_id, mi.item_name, mi.restaurant_id, mi.price, mi.category
),
category_benchmarks AS (
    SELECT 
        category,
        ROUND(AVG(current_price), 2) AS category_avg_price,
        ROUND(AVG(times_ordered_30d), 2) AS category_avg_orders
    FROM item_performance
    GROUP BY category
)
SELECT 
    ip.item_name,
    r.restaurant_name,
    ip.category,
    ip.current_price,
    cb.category_avg_price,
    ip.times_ordered_30d,
    cb.category_avg_orders,
    CASE 
        WHEN ip.times_ordered_30d > cb.category_avg_orders * 1.5 
            AND ip.current_price < cb.category_avg_price 
            THEN ROUND(ip.current_price * 1.10, 2)
        WHEN ip.times_ordered_30d < cb.category_avg_orders * 0.5 THEN ROUND(ip.current_price * 0.90, 2)
        ELSE ip.current_price
    END AS recommended_price,
    CASE 
        WHEN ip.times_ordered_30d > cb.category_avg_orders * 1.5 THEN 'High Demand - Increase'
        WHEN ip.times_ordered_30d < cb.category_avg_orders * 0.5 THEN 'Low Demand - Decrease'
        ELSE 'Stable'
    END AS pricing_action
FROM item_performance ip
JOIN category_benchmarks cb ON ip.category = cb.category
JOIN restaurants r ON ip.restaurant_id = r.restaurant_id
WHERE ip.times_ordered_30d > 0
ORDER BY r.restaurant_name, ip.category;

-- ==========================================

-- 43. Customer Journey Funnel Analysis
-- Business Use: Conversion optimization and funnel drop-off identification
WITH user_journey AS (
    SELECT 
        u.user_id,
        u.created_at AS registration_date,
        MIN(o.order_date) AS first_order_date,
        COUNT(o.order_id) AS total_orders,
        MIN(CASE WHEN o.order_status = 'delivered' THEN o.order_date END) AS first_delivered_order
    FROM users u
    LEFT JOIN orders o ON u.user_id = o.customer_id
    WHERE u.user_type = 'customer'
        --AND u.created_at >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY u.user_id, u.created_at
),
funnel_stages AS (
    SELECT 
        COUNT(*) AS total_registered,
        COUNT(first_order_date) AS placed_first_order,
        COUNT(first_delivered_order) AS completed_first_order,
        COUNT(CASE WHEN total_orders >= 2 THEN 1 END) AS placed_second_order,
        COUNT(CASE WHEN total_orders >= 5 THEN 1 END) AS reached_5_orders
    FROM user_journey
)
SELECT 
    'Registered' AS stage,
    total_registered AS user_count,
    100.0 AS conversion_rate
FROM funnel_stages
UNION ALL
SELECT 
    'Placed First Order',
    placed_first_order,
    ROUND(placed_first_order * 100.0 / total_registered, 2)
FROM funnel_stages
UNION ALL
SELECT 
    'Completed First Order',
    completed_first_order,
    ROUND(completed_first_order * 100.0 / total_registered, 2)
FROM funnel_stages
UNION ALL
SELECT 
    'Placed Second Order',
    placed_second_order,
    ROUND(placed_second_order * 100.0 / total_registered, 2)
FROM funnel_stages
UNION ALL
SELECT 
    'Reached 5 Orders',
    reached_5_orders,
    ROUND(reached_5_orders * 100.0 / total_registered, 2)
FROM funnel_stages;

-- ==========================================

-- 44. Supply Chain Optimization - Restaurant Stock Planning
-- Business Use: Minimize food waste and ensure availability
WITH valid_orders AS (
    SELECT order_id
	FROM orders
	WHERE order_status = 'delivered'
	  --AND order_date >= CURRENT_DATE - INTERVAL '30 days'
),
item_velocity AS (
    SELECT 
        mi.menu_item_id,
        mi.item_name,
        mi.restaurant_id,
        COUNT(oi.order_item_id) AS order_frequency,
        SUM(oi.quantity) AS total_quantity_sold,
        ROUND(SUM(oi.quantity)::NUMERIC / 30, 2) AS daily_velocity,
		ROUND(STDDEV(oi.quantity)::NUMERIC, 2) AS demand_stddev
    FROM menu_items mi
    JOIN order_items oi ON mi.menu_item_id = oi.menu_item_id
    JOIN valid_orders vo ON oi.order_id = vo.order_id
    WHERE mi.is_available = true
    GROUP BY mi.menu_item_id, mi.item_name, mi.restaurant_id
)
SELECT 
    r.restaurant_name,
    iv.item_name,
    iv.total_quantity_sold AS sold_last_30_days,
    iv.daily_velocity,
    ROUND(iv.daily_velocity * 2 + COALESCE(iv.demand_stddev, 0), 0) AS safety_stock,
    ROUND(iv.daily_velocity * 2, 0) AS reorder_point,
    CASE 
        WHEN iv.daily_velocity > 10 THEN 'High Velocity - Daily Stock Check'
        WHEN iv.daily_velocity > 5 THEN 'Medium Velocity - Every 2 Days'
        ELSE 'Low Velocity - Weekly Check'
    END AS stock_check_frequency
FROM item_velocity iv
JOIN restaurants r ON iv.restaurant_id = r.restaurant_id
WHERE iv.total_quantity_sold > 0
ORDER BY r.restaurant_name, iv.daily_velocity DESC;

-- ==========================================

-- 45. Real-Time Order Capacity Planning
-- Business Use: Dynamic restaurant capacity management
WITH hourly_capacity AS (
    SELECT 
        o.restaurant_id,
        COUNT(o.order_id) AS orders_in_hour,
        SUM(mi.preparation_time * oi.quantity) AS total_prep_minutes
    FROM orders o
    JOIN order_items oi ON o.order_id = oi.order_id
    JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
    WHERE o.order_status IN ('confirmed', 'preparing')
        --AND o.order_date >= CURRENT_TIMESTAMP - INTERVAL '2 hours'
    GROUP BY o.restaurant_id
)
SELECT 
    r.restaurant_name,
    COALESCE(hc.orders_in_hour, 0) AS current_orders,
    COALESCE(hc.total_prep_minutes, 0) AS current_workload_minutes,
    ROUND(COALESCE(hc.total_prep_minutes, 0) * 100.0 / 180, 2) AS capacity_utilization_pct,
    CASE 
        WHEN COALESCE(hc.total_prep_minutes, 0) >= 180 * 0.9 THEN 'At Capacity - Reject Orders'
        WHEN COALESCE(hc.total_prep_minutes, 0) >= 180 * 0.7 THEN 'High Load - Slow Prep Times'
        WHEN COALESCE(hc.total_prep_minutes, 0) >= 180 * 0.5 THEN 'Moderate Load'
        ELSE 'Available - Accept Orders'
    END AS capacity_status
FROM restaurants r
LEFT JOIN hourly_capacity hc ON r.restaurant_id = hc.restaurant_id
WHERE r.is_operational = true
ORDER BY capacity_utilization_pct DESC;

-- ==========================================

-- 46. Customer Sentiment Analysis (Based on Reviews)
-- Business Use: Reputation management and service improvement
WITH review_analysis AS (
    SELECT 
        rv.restaurant_id,
        rv.rating,
        CASE 
            WHEN rv.rating >= 4 THEN 'Positive'
            WHEN rv.rating = 3 THEN 'Neutral'
            ELSE 'Negative'
        END AS sentiment
    FROM reviews rv
    --WHERE rv.review_date >= CURRENT_DATE - INTERVAL '30 days'
)
SELECT 
    r.restaurant_name,
    COUNT(ra.rating) AS total_reviews,
    COUNT(CASE WHEN ra.sentiment = 'Positive' THEN 1 END) AS positive_reviews,
    COUNT(CASE WHEN ra.sentiment = 'Neutral' THEN 1 END) AS neutral_reviews,
    COUNT(CASE WHEN ra.sentiment = 'Negative' THEN 1 END) AS negative_reviews,
    ROUND(AVG(ra.rating), 2) AS avg_overall_rating,
    ROUND(COUNT(CASE WHEN ra.rating >= 4 THEN 1 END) * 100.0 / COUNT(ra.rating), 2) AS positive_pct,
    CASE 
        WHEN ROUND(COUNT(CASE WHEN ra.rating >= 4 THEN 1 END) * 100.0 / COUNT(ra.rating), 2) >= 70 THEN 'Excellent'
        WHEN ROUND(COUNT(CASE WHEN ra.rating >= 4 THEN 1 END) * 100.0 / COUNT(ra.rating), 2) >= 50 THEN 'Good'
        ELSE 'Needs Improvement'
    END AS sentiment_status
FROM restaurants r
LEFT JOIN review_analysis ra ON r.restaurant_id = ra.restaurant_id
GROUP BY r.restaurant_id, r.restaurant_name
HAVING COUNT(ra.rating) >= 1
ORDER BY avg_overall_rating DESC;

-- ==========================================

-- 47. Delivery Agent Efficiency - Geographic Heat Map
-- Business Use: Identify underperforming regions
SELECT 
    ca.city,
    COUNT(d.delivery_id) AS total_deliveries,
    ROUND(AVG(d.delivery_rating), 2) AS avg_rating,
    ROUND(AVG(EXTRACT(EPOCH FROM (d.actual_delivery_time - d.pickup_time))/60), 2) AS avg_delivery_minutes,
    ROUND(AVG(d.distance_km), 2) AS avg_distance,
    COUNT(DISTINCT d.delivery_agent_id) AS agent_count,
    ROUND(COUNT(d.delivery_id)::NUMERIC / COUNT(DISTINCT d.delivery_agent_id), 2) AS avg_deliveries_per_agent
FROM deliveries d
JOIN orders o ON d.order_id = o.order_id
JOIN customer_addresses ca ON o.delivery_address_id = ca.address_id
WHERE d.delivery_status = 'delivered'
    --AND d.actual_delivery_time >= CURRENT_DATE - INTERVAL '30 days'
GROUP BY ca.city
HAVING COUNT(d.delivery_id) >= 1
ORDER BY avg_delivery_minutes DESC;

-- ==========================================

-- 48. Restaurant Collaboration Opportunities
-- Business Use: Identify cross-selling and partnership opportunities
WITH valid_orders AS (
    SELECT
        restaurant_id,
        customer_id
    FROM orders
    WHERE order_status = 'delivered'
      AND order_date >= CURRENT_DATE - INTERVAL '90 days'
),
restaurant_customers AS (
    SELECT DISTINCT
        restaurant_id,
        customer_id
    FROM valid_orders
),
restaurant_customer_counts AS (
    SELECT
        restaurant_id,
        COUNT(DISTINCT customer_id) AS total_customers
    FROM restaurant_customers
    GROUP BY restaurant_id
),
shared_customers AS (
    SELECT
        rc1.restaurant_id AS restaurant_id_1,
        rc2.restaurant_id AS restaurant_id_2,
        COUNT(DISTINCT rc1.customer_id) AS shared_customers
    FROM restaurant_customers rc1
    JOIN restaurant_customers rc2
        ON rc1.customer_id = rc2.customer_id
       AND rc1.restaurant_id < rc2.restaurant_id
    GROUP BY
        rc1.restaurant_id,
        rc2.restaurant_id
)
SELECT
    r1.restaurant_name AS restaurant_name,
    r2.restaurant_name AS partnership_opportunity,
    sc.shared_customers,

    ROUND(
        sc.shared_customers * 100.0 /
        NULLIF(LEAST(rc1.total_customers, rc2.total_customers), 0),
        2
    ) AS overlap_percentage

FROM shared_customers sc
JOIN restaurants r1
    ON sc.restaurant_id_1 = r1.restaurant_id
JOIN restaurants r2
    ON sc.restaurant_id_2 = r2.restaurant_id
JOIN restaurant_customer_counts rc1
    ON sc.restaurant_id_1 = rc1.restaurant_id
JOIN restaurant_customer_counts rc2
    ON sc.restaurant_id_2 = rc2.restaurant_id

WHERE sc.shared_customers >= 5
ORDER BY sc.shared_customers DESC
LIMIT 20;

-- ==========================================

-- 49. Geographic Clustering Analysis
-- Business Use: Restaurant expansion site selection
WITH city_metrics AS (
    SELECT
        ca.city,
        COUNT(DISTINCT o.customer_id) AS customers_in_city,
        SUM(o.final_amount) AS revenue_in_city
    FROM customer_addresses ca
    JOIN orders o
        ON ca.address_id = o.delivery_address_id
    WHERE o.order_status = 'delivered'
      AND o.order_date >= CURRENT_DATE - INTERVAL '90 days'
    GROUP BY ca.city
),
customer_locations AS (
    SELECT DISTINCT
        ca.latitude,
        ca.longitude,
        ca.city,
        cm.customers_in_city,
        cm.revenue_in_city
    FROM customer_addresses ca
    JOIN orders o
        ON ca.address_id = o.delivery_address_id
    JOIN city_metrics cm
        ON ca.city = cm.city
    WHERE o.order_status = 'delivered'
      AND o.order_date >= CURRENT_DATE - INTERVAL '90 days'
),
restaurant_coverage AS (
    SELECT 
        cl.city,
        cl.customers_in_city,
        cl.revenue_in_city,
        COUNT(DISTINCT r.restaurant_id) AS restaurant_count,
        ROUND(AVG(calculate_distance(
            cl.latitude, cl.longitude,
            ra.latitude, ra.longitude
        )), 2) AS avg_distance_to_restaurant
    FROM customer_locations cl
    CROSS JOIN restaurant_addresses ra
    JOIN restaurants r
        ON ra.restaurant_id = r.restaurant_id
    WHERE r.is_operational = true
      AND calculate_distance(
            cl.latitude, cl.longitude,
            ra.latitude, ra.longitude
          ) <= 10
    GROUP BY
        cl.city,
        cl.customers_in_city,
        cl.revenue_in_city
)
SELECT 
    city,
    customers_in_city,
    revenue_in_city,
    restaurant_count,
    avg_distance_to_restaurant,
    ROUND(
        revenue_in_city / NULLIF(restaurant_count, 0),
        2
    ) AS revenue_per_restaurant,
    CASE 
        WHEN restaurant_count < 3 AND customers_in_city > 50
            THEN 'High Priority'
        WHEN restaurant_count < 5 AND customers_in_city > 30
            THEN 'Medium Priority'
        ELSE 'Low Priority'
    END AS expansion_priority
FROM restaurant_coverage
ORDER BY revenue_in_city DESC, customers_in_city DESC;

-- ==========================================

-- 50. Comprehensive Executive Dashboard
-- Business Use: All KPIs in one view
SELECT 
    'EXECUTIVE_DASHBOARD' AS report_type,
    (SELECT COUNT(DISTINCT order_id) FROM orders WHERE order_date >= CURRENT_DATE - INTERVAL '90 days' AND order_status = 'delivered') AS orders_last_90d,
    (SELECT ROUND(SUM(final_amount), 2) FROM orders WHERE order_date >= CURRENT_DATE - INTERVAL '90 days' AND order_status = 'delivered') AS revenue_last_90d,
    (SELECT COUNT(DISTINCT customer_id) FROM orders WHERE order_date >= CURRENT_DATE - INTERVAL '90 days') AS active_customers_90d,
    (SELECT COUNT(DISTINCT restaurant_id) FROM orders WHERE order_date >= CURRENT_DATE - INTERVAL '90 days') AS active_restaurants_90d,
    (SELECT ROUND(AVG(rating), 2) FROM restaurants WHERE is_operational = true) AS avg_restaurant_rating,
    (SELECT ROUND(AVG(rating), 2) FROM delivery_agents) AS avg_agent_rating,
    (SELECT COUNT(*) FROM users WHERE user_type = 'customer' AND is_active = true) AS total_active_customers;

-- ==========================================
-- PART 5: FUNCTION DEMONSTRATIONS (51-59)
-- ==========================================

-- 51. Calculate Distance Between Coordinates
-- Business Use: Restaurant proximity search
SELECT 
    calculate_distance(
        28.6139,  -- Customer latitude (Raisina Hill, Delhi)
        77.2090,  -- Customer longitude
        28.5355,  -- Restaurant latitude
        77.3910   -- Restaurant longitude
    ) AS distance_km;

-- ==========================================

-- 52. Get Nearby Restaurants
-- Business Use: Show restaurants within delivery range
SELECT * FROM get_nearby_restaurants(28.6139, 77.2090, 10);

-- ==========================================

-- 53. Calculate Order Total
-- Business Use: Verify order pricing calculation
SELECT * FROM calculate_order_total(41);

-- ==========================================

-- 54. Check Order Delivery Status
-- Business Use: Customer order tracking
SELECT * FROM get_order_delivery_status(41);

-- ==========================================

-- 55. Manage Order Items
-- Business Use: Add or update items in an order
SELECT * FROM manage_order_item(44, 101, 1, 320.00, 'INSERT');

-- ==========================================

-- 56. Get Customer Order History
-- Business Use: Customer profile and support
SELECT * FROM get_customer_order_history(46, 10);

-- ==========================================

-- 57. Get Top Menu Items
-- Business Use: Trending menu items dashboard
SELECT * FROM get_top_menu_items(50);

-- ==========================================

-- 58. Validate Payment
-- Business Use: Payment verification before order confirmation
SELECT * FROM validate_order_payment(41);

SELECT * FROM validate_order_payment(45);

-- ==========================================

-- 59. Update Restaurants Ratings
-- Business Use: Monthly restaurants rating update
SELECT update_restaurant_rating(28);

-- ==========================================

-- 60. Available Delivery Agents
-- Business Use: List of available delivery agents
SELECT * FROM get_available_delivery_agents('Scooter');

-- ==========================================
-- PART 6: STORED PROCEDURE DEMONSTRATIONS (60-64)
-- ==========================================

-- 60. Place a New Order
-- Business Use: Complete order creation workflow

DO $$
DECLARE
    v_order_id INT;
    v_error_message VARCHAR;
BEGIN
    CALL place_order(
        v_order_id,
        v_error_message,
        46,                                                  -- customer_id
        21,                                                  -- restaurant_id
        24,                                                  -- delivery_address_id
        (CURRENT_TIMESTAMP + INTERVAL '1 hour')::TIMESTAMP,  -- requested_delivery_time
        '[
           {"menu_item_id": 104, "quantity": 3},             
		   {"menu_item_id": 105, "quantity": 1}
		]'::jsonb,                                           -- items and quantity
		0.10,                                                -- discount rate
		'Extra spicy please'::TEXT                           -- special_instructions
    );
    
    IF v_error_message IS NULL THEN
        RAISE NOTICE 'Order created successfully. Order ID: %', v_order_id;
    ELSE
        RAISE NOTICE 'Error: %', v_error_message;
    END IF;
END $$;


-- ==========================================

-- 61. Confirm Order
-- Business Use: Order confirmation with agent assignment

DO $$
DECLARE
    v_success BOOLEAN;
    v_message VARCHAR;
BEGIN
    CALL confirm_order(62, 16, v_success, v_message);
    RAISE NOTICE 'Success: %, Message: %', v_success, v_message;
END $$;


-- ==========================================

-- 62. Update Order Status
-- Business Use: Progress order through workflow stages

DO $$
DECLARE
    v_success BOOLEAN;
    v_message VARCHAR;
BEGIN
    CALL update_order_status(62, 'preparing', v_success, v_message);
    RAISE NOTICE 'Success: %, Message: %', v_success, v_message;
END $$;


-- ==========================================

-- 63. Customer Cancel Order
-- Business Use: Customer-initiated order cancellation

DO $$
DECLARE
    v_success BOOLEAN;
    v_message VARCHAR;
BEGIN
    CALL customer_cancel_order(61, 46, v_success, v_message);
    RAISE NOTICE 'Success: %, Message: %', v_success, v_message;
END $$;


-- ==========================================

-- 64. Admin Cancel Order
-- Business Use: Staff-initiated order cancellation with reason
DO $$
DECLARE
    v_success BOOLEAN;
    v_message VARCHAR;
BEGIN
    CALL admin_cancel_order(
        42,                              -- order_id
        5,                              -- admin_user_id
        'Out of stock on main ingredient', -- reason
        v_success,
        v_message
    );
    RAISE NOTICE 'Success: %, Message: %', v_success, v_message;
END $$;


-- ==========================================
-- END OF QUERIES
-- ==========================================

-- Total: 50 SELECT Queries + 14 Function and Procedure Examples = 64 Business-Oriented SQL Queries
-- Database: PostgreSQL 12+
-- Complexity: Basic to Expert Level
-- Use Cases: Operations, Analytics, Finance, Marketing, Fraud Detection
