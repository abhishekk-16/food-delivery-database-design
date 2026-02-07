-- 1. Loading users data from generated csv file 
COPY users (
    user_id,
    email,
    password_hash,
    phone_number,
    first_name,
    last_name,
    user_type,
    rating,
    created_at,
    updated_at,
    is_active
)
FROM 'F:/Food_delivery_db/food_delivery_data_generation/users.csv'
DELIMITER ','
CSV HEADER;

SELECT COUNT(*) FROM users;

SELECT user_type, COUNT(*)
FROM users
GROUP BY user_type;

SELECT user_id FROM users WHERE user_type = 'restaurant_owner';

-- 2. Loading restaurants and restaurants adresses from csv file

-- restaurants
COPY restaurants (
    restaurant_id, owner_id, restaurant_name, description,
    cuisine_type, phone_number, email, rating,
    total_orders, is_operational, created_at, updated_at
)
FROM 'F:/Food_delivery_db/food_delivery_data_generation/restaurants.csv'
CSV HEADER;

-- restaurants addresses
COPY restaurant_addresses (
    address_id, restaurant_id, street_address, city,
    state_province, postal_code, country,
    is_primary, created_at
)
FROM 'F:/Food_delivery_db/food_delivery_data_generation/restaurant_addresses.csv'
CSV HEADER;

SELECT COUNT(*) FROM restaurants;

SELECT COUNT(*) FROM restaurant_addresses;

SELECT city, COUNT(*)
FROM restaurant_addresses
GROUP BY city;

SELECT AVG(rating) FROM restaurants;

-- 3. Delivery agents
COPY delivery_agents (
    agent_id, user_id, vehicle_type, vehicle_number,
    rating, total_deliveries, is_available,
    created_at, updated_at
)
FROM 'F:/Food_delivery_db/food_delivery_data_generation/delivery_agents.csv'
CSV HEADER;

SELECT COUNT(*) FROM delivery_agents;

SELECT vehicle_type, COUNT(*)
FROM delivery_agents
GROUP BY vehicle_type;

-- 4. Customer addresses
COPY customer_addresses (
    address_id, customer_id, address_type, street_address,
    city, state_province, postal_code, country,
    is_default, created_at
)
FROM 'F:/Food_delivery_db/food_delivery_data_generation/customer_addresses.csv'
CSV HEADER;

SELECT COUNT(*) FROM customer_addresses;

SELECT city, COUNT(*)
FROM customer_addresses
GROUP BY city;

-- 5. Menu items
COPY menu_items (
    menu_item_id, restaurant_id, item_name, description,
    category, price, is_available, preparation_time,
    image_url, created_at, updated_at
)
FROM 'F:/Food_delivery_db/food_delivery_data_generation/menu_items.csv'
CSV HEADER;

SELECT m.restaurant_id, r.restaurant_name, COUNT(*)
FROM menu_items m
JOIN restaurants r ON m.restaurant_id = r.restaurant_id
GROUP BY m.restaurant_id, r.restaurant_name
ORDER BY m.restaurant_id;

-- 6. Orders table
-- Export Customer–Address Mapping
COPY (
    SELECT customer_id, address_id
    FROM customer_addresses
) 
TO 'F:/Food_delivery_db/food_delivery_data_generation/customer_address_map.csv'
CSV HEADER;

-- Truncate orders table
TRUNCATE TABLE orders RESTART IDENTITY CASCADE;

-- Copy data from csv
COPY orders (
    order_id, customer_id, restaurant_id, delivery_address_id,
    order_date, requested_delivery_time, total_amount,
    discount_amount, delivery_fee, tax_amount,
    order_status, payment_status, special_instructions,
    created_at, updated_at
)
FROM 'F:/Food_delivery_db/food_delivery_data_generation/orders.csv'
CSV HEADER;

-- FK sanity
SELECT COUNT(*)
FROM orders o
LEFT JOIN customer_addresses ca
ON o.delivery_address_id = ca.address_id
WHERE ca.address_id IS NULL;

-- Status distribution
SELECT order_status, COUNT(*) 
FROM orders
GROUP BY order_status;

-- 7. order items table
-- Export required mappings
COPY (
    SELECT order_id, restaurant_id
    FROM orders
)
TO 'F:/Food_delivery_db/food_delivery_data_generation/order_restaurant_map.csv'
CSV HEADER;

COPY (
    SELECT menu_item_id, restaurant_id, price
    FROM menu_items
)
TO 'F:/Food_delivery_db/food_delivery_data_generation/menu_items_map.csv'
CSV HEADER;

-- Truncate
TRUNCATE TABLE order_items RESTART IDENTITY;

-- Copy
COPY order_items (
    order_item_id, order_id, menu_item_id,
    quantity, item_price, special_instructions
)
FROM 'F:/Food_delivery_db/food_delivery_data_generation/order_items.csv'
CSV HEADER;

-- update orders table total
-- Step 1: Update total_amount from order_items
UPDATE orders o
SET total_amount = t.items_total
FROM (
    SELECT 
        order_id,
        SUM(quantity * item_price) AS items_total
    FROM order_items
    GROUP BY order_id
) t
WHERE o.order_id = t.order_id;

-- Step 2: Recalculate tax
UPDATE orders
SET tax_amount = ROUND(total_amount * 0.05, 2);

-- Avg items per order
SELECT AVG(cnt)
FROM (
    SELECT order_id, COUNT(*) cnt
    FROM order_items
    GROUP BY order_id
) t;

-- Revenue sanity
SELECT
    SUM(oi.quantity * oi.item_price) AS items_total,
    SUM(o.total_amount) AS orders_total
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id;

-- No cross-restaurant items
SELECT COUNT(*)
FROM order_items oi
JOIN orders o ON oi.order_id = o.order_id
JOIN menu_items mi ON oi.menu_item_id = mi.menu_item_id
WHERE o.restaurant_id <> mi.restaurant_id;

-- 8. Payments table
-- Exporting required orders data
COPY (
    SELECT 
        order_id,
        order_status,
        payment_status,
        final_amount,
        created_at
    FROM orders
)
TO 'F:/Food_delivery_db/food_delivery_data_generation/order_payment_map.csv'
CSV HEADER;

-- Truncate payments table
TRUNCATE TABLE payments RESTART IDENTITY;

-- copy data from csv
COPY payments (
    payment_id, order_id, payment_method,
    payment_amount, transaction_id,
    payment_status, payment_date,
    created_at, updated_at
)
FROM 'F:/Food_delivery_db/food_delivery_data_generation/payments.csv'
CSV HEADER;

-- 9. Deliveries table
-- Export required data 
COPY (
    SELECT 
        o.order_id,
        o.order_status,
        o.created_at
    FROM orders o
)
TO 'F:/Food_delivery_db/food_delivery_data_generation/order_delivery_map.csv'
CSV HEADER;

COPY (
    SELECT agent_id
    FROM delivery_agents
    WHERE is_available = true
)
TO 'F:/Food_delivery_db/food_delivery_data_generation/delivery_agents_map.csv'
CSV HEADER;

-- Truncate table
TRUNCATE TABLE deliveries RESTART IDENTITY;

-- copy from csv
COPY deliveries (
    delivery_id, order_id, delivery_agent_id,
    pickup_time, estimated_delivery_time, actual_delivery_time,
    delivery_status, distance_km,
    delivery_rating, delivery_feedback,
    created_at, updated_at
)
FROM 'F:/Food_delivery_db/food_delivery_data_generation/deliveries.csv'
CSV HEADER;

-- Validate
-- Delivered orders must have actual_delivery_time
SELECT COUNT(*)
FROM deliveries
WHERE delivery_status = 'delivered'
AND actual_delivery_time IS NULL;

-- Cancelled orders should not have agent
SELECT COUNT(*)
FROM deliveries
WHERE delivery_status = 'cancelled'
AND delivery_agent_id IS NOT NULL;

-- Time sanity
SELECT COUNT(*)
FROM deliveries
WHERE pickup_time >= estimated_delivery_time;

-- 10. Reviews table
-- Exporting required data from orders table
COPY (
    SELECT 
        o.order_id,
        o.customer_id,
        o.restaurant_id,
        o.created_at
    FROM orders o
    WHERE o.order_status = 'delivered'
)
TO 'F:/Food_delivery_db/food_delivery_data_generation/delivered_orders_for_reviews.csv'
CSV HEADER;

-- Truncate table
TRUNCATE TABLE reviews RESTART IDENTITY;

-- copy from csv
COPY reviews (
    review_id, customer_id, restaurant_id, order_id,
    rating, food_quality_rating, delivery_rating,
    comment, review_date, updated_at
)
FROM 'F:/Food_delivery_db/food_delivery_data_generation/reviews.csv'
CSV HEADER;

-- Only delivered orders have reviews
SELECT COUNT(*)
FROM reviews r
JOIN orders o USING (order_id)
WHERE o.order_status <> 'delivered';

-- Rating sanity
SELECT MIN(rating), MAX(rating) FROM reviews;


-- 11. order status audit log table
-- Export required data from orders
COPY (
    SELECT order_id, order_status, created_at
    FROM orders
)
TO 'F:/Food_delivery_db/food_delivery_data_generation/orders_for_audit.csv'
CSV HEADER;

-- truncate
TRUNCATE TABLE order_status_audit_log RESTART IDENTITY;

-- copy from csv
COPY order_status_audit_log (
    log_id, order_id, old_status,
    new_status, changed_at
)
FROM 'F:/Food_delivery_db/food_delivery_data_generation/order_status_audit_log.csv'
CSV HEADER;

-- Each order has multiple transitions
SELECT order_id, COUNT(*) 
FROM order_status_audit_log
GROUP BY order_id
HAVING COUNT(*) < 2;