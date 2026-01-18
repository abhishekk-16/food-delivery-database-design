-- 1. USERS TABLE
CREATE TABLE users (
    user_id SERIAL PRIMARY KEY,
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(15) UNIQUE NOT NULL,
    first_name VARCHAR(100) NOT NULL,
    last_name VARCHAR(100) NOT NULL,
    user_type VARCHAR(50) NOT NULL 
        CHECK (user_type IN ('customer', 'restaurant_owner', 'delivery_agent')),
    rating DECIMAL(3, 2) DEFAULT 5.00 
        CHECK (rating >= 0 AND rating <= 5),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_active BOOLEAN DEFAULT true
);

-- 2. RESTAURANTS TABLE
CREATE TABLE restaurants (
    restaurant_id SERIAL PRIMARY KEY,
    owner_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    restaurant_name VARCHAR(255) NOT NULL,
    description TEXT,
    cuisine_type VARCHAR(100),
    phone_number VARCHAR(15),
    email VARCHAR(255),
    rating DECIMAL(3, 2) DEFAULT 5.00 
        CHECK (rating >= 0 AND rating <= 5),
    total_orders INT DEFAULT 0 CHECK (total_orders >= 0),
    is_operational BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 3. RESTAURANT ADDRESSES TABLE
CREATE TABLE restaurant_addresses (
    address_id SERIAL PRIMARY KEY,
    restaurant_id INT NOT NULL REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_primary BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 4. MENU ITEMS TABLE
CREATE TABLE menu_items (
    menu_item_id SERIAL PRIMARY KEY,
    restaurant_id INT NOT NULL REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
    item_name VARCHAR(255) NOT NULL,
    description TEXT,
    category VARCHAR(100) NOT NULL,
    price DECIMAL(10, 2) NOT NULL CHECK (price > 0),
    is_available BOOLEAN DEFAULT true,
    preparation_time INT DEFAULT 30 CHECK (preparation_time > 0),
    image_url VARCHAR(500),
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 5. CUSTOMER ADDRESSES TABLE
CREATE TABLE customer_addresses (
    address_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    address_type VARCHAR(50) 
        CHECK (address_type IN ('home', 'work', 'other')),
    street_address VARCHAR(255) NOT NULL,
    city VARCHAR(100) NOT NULL,
    state_province VARCHAR(100),
    postal_code VARCHAR(20),
    country VARCHAR(100) NOT NULL,
    latitude DECIMAL(10, 8),
    longitude DECIMAL(11, 8),
    is_default BOOLEAN DEFAULT false,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 6. ORDERS TABLE (Core Transaction Table)
CREATE TABLE orders (
    order_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    restaurant_id INT NOT NULL REFERENCES restaurants(restaurant_id),
    delivery_address_id INT NOT NULL REFERENCES customer_addresses(address_id),
    order_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    requested_delivery_time TIMESTAMP,
    total_amount DECIMAL(10, 2) NOT NULL CHECK (total_amount >= 0),
    discount_amount DECIMAL(10, 2) DEFAULT 0 CHECK (discount_amount >= 0),
    delivery_fee DECIMAL(10, 2) DEFAULT 50.00 CHECK (delivery_fee >= 0),
    tax_amount DECIMAL(10, 2) DEFAULT 0 CHECK (tax_amount >= 0),
    final_amount DECIMAL(10, 2) GENERATED ALWAYS AS
	     (total_amount + tax_amount + delivery_fee - discount_amount) STORED,
    order_status VARCHAR(50) DEFAULT 'pending' 
        CHECK (order_status IN ('pending', 'confirmed', 'preparing', 'ready', 
                               'out_for_delivery', 'delivered', 'cancelled')),
    payment_status VARCHAR(50) DEFAULT 'pending' 
        CHECK (payment_status IN ('pending', 'paid', 'failed', 'refunded')),
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
	
	CONSTRAINT chk_delivery_time_future
	    CHECK (requested_delivery_time > order_date)
);

-- 7. ORDER ITEMS TABLE
CREATE TABLE order_items (
    order_item_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL REFERENCES orders(order_id) ON DELETE CASCADE,
    menu_item_id INT NOT NULL REFERENCES menu_items(menu_item_id),
    quantity INT NOT NULL CHECK (quantity > 0),
    item_price DECIMAL(10, 2) NOT NULL CHECK (item_price > 0),
    special_instructions TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 8. PAYMENTS TABLE
CREATE TABLE payments (
    payment_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
    payment_method VARCHAR(50) NOT NULL 
        CHECK (payment_method IN ('credit_card', 'debit_card', 'wallet', 'cash', 'upi')),
    payment_amount DECIMAL(10, 2) NOT NULL CHECK (payment_amount >= 0),
    transaction_id VARCHAR(100) UNIQUE,
    payment_status VARCHAR(50) DEFAULT 'pending' 
        CHECK (payment_status IN ('pending', 'processing', 'completed', 'failed', 'refunded')),
    payment_date TIMESTAMP,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 9. DELIVERY AGENTS TABLE
CREATE TABLE delivery_agents (
    agent_id SERIAL PRIMARY KEY,
    user_id INT NOT NULL UNIQUE REFERENCES users(user_id) ON DELETE CASCADE,
    vehicle_type VARCHAR(50) NOT NULL 
        CHECK (vehicle_type IN ('motorcycle', 'scooter', 'bicycle', 'car')),
    vehicle_number VARCHAR(50),
    rating DECIMAL(3, 2) DEFAULT 5.00 
        CHECK (rating >= 0 AND rating <= 5),
    total_deliveries INT DEFAULT 0 CHECK (total_deliveries >= 0),
    is_available BOOLEAN DEFAULT true,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 10. DELIVERIES TABLE
CREATE TABLE deliveries (
    delivery_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL UNIQUE REFERENCES orders(order_id) ON DELETE CASCADE,
    delivery_agent_id INT REFERENCES delivery_agents(agent_id),
    pickup_time TIMESTAMP,
    estimated_delivery_time TIMESTAMP,
    actual_delivery_time TIMESTAMP,
    delivery_status VARCHAR(50) DEFAULT 'pending' 
        CHECK (delivery_status IN ('pending', 'pickup_pending', 'in_transit', 'delivered', 'cancelled')),
    distance_km DECIMAL(10, 2),
    delivery_rating INT CHECK (delivery_rating IS NULL OR (delivery_rating >= 1 AND delivery_rating <= 5)),
    delivery_feedback TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,

	CONSTRAINT chk_pickup_time_past
	    CHECK((pickup_time < estimated_delivery_time) AND
		      (pickup_time < actual_delivery_time))
);

-- 11. REVIEWS TABLE
CREATE TABLE reviews (
    review_id SERIAL PRIMARY KEY,
    customer_id INT NOT NULL REFERENCES users(user_id) ON DELETE CASCADE,
    restaurant_id INT NOT NULL REFERENCES restaurants(restaurant_id) ON DELETE CASCADE,
    order_id INT NOT NULL REFERENCES orders(order_id),
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    food_quality_rating INT CHECK (food_quality_rating IS NULL OR (food_quality_rating >= 1 AND food_quality_rating <= 5)),
    delivery_rating INT CHECK (delivery_rating IS NULL OR (delivery_rating >= 1 AND delivery_rating <= 5)),
    comment TEXT,
    review_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- 12. Create audit table
CREATE TABLE order_status_audit_log (
    log_id SERIAL PRIMARY KEY,
    order_id INT NOT NULL,
    old_status VARCHAR(50),
    new_status VARCHAR(50),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

-- Query to view audit log
-- SELECT * FROM order_status_audit_log WHERE order_id = 1 ORDER BY changed_at;

-- USER INDEXES
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_phone_number ON users(phone_number);
CREATE INDEX idx_users_user_type ON users(user_type);
CREATE INDEX idx_users_is_active ON users(is_active);

-- RESTAURANT INDEXES
CREATE INDEX idx_restaurants_owner_id ON restaurants(owner_id);
CREATE INDEX idx_restaurants_name ON restaurants(restaurant_name);
CREATE INDEX idx_restaurants_is_operational ON restaurants(is_operational);
CREATE INDEX idx_restaurants_city ON restaurant_addresses(city);
CREATE UNIQUE INDEX idx_restaurant_primary_address ON restaurant_addresses(restaurant_id) WHERE is_primary = true;

-- MENU ITEM INDEXES
CREATE INDEX idx_menu_items_restaurant_id ON menu_items(restaurant_id);
CREATE INDEX idx_menu_items_category ON menu_items(category);
CREATE INDEX idx_menu_items_is_available ON menu_items(is_available);
CREATE INDEX idx_menu_items_restaurant_category ON menu_items(restaurant_id, category);

-- ORDER INDEXES (Critical for performance)
CREATE INDEX idx_orders_customer_id ON orders(customer_id);
CREATE INDEX idx_orders_restaurant_id ON orders(restaurant_id);
CREATE INDEX idx_orders_order_status ON orders(order_status);
CREATE INDEX idx_orders_payment_status ON orders(payment_status);
CREATE INDEX idx_orders_order_date ON orders(order_date);
CREATE INDEX idx_orders_customer_date ON orders(customer_id, order_date DESC);
CREATE INDEX idx_orders_restaurant_date ON orders(restaurant_id, order_date DESC);

-- ORDER ITEMS INDEXES
CREATE INDEX idx_order_items_order_id ON order_items(order_id);
CREATE INDEX idx_order_items_menu_item_id ON order_items(menu_item_id);

-- PAYMENT INDEXES
CREATE INDEX idx_payments_order_id ON payments(order_id);
CREATE INDEX idx_payments_payment_status ON payments(payment_status);
CREATE INDEX idx_payments_created_at ON payments(created_at);

-- DELIVERY INDEXES
CREATE INDEX idx_deliveries_order_id ON deliveries(order_id);
CREATE INDEX idx_deliveries_delivery_agent_id ON deliveries(delivery_agent_id);
CREATE INDEX idx_deliveries_delivery_status ON deliveries(delivery_status);
CREATE INDEX idx_deliveries_agent_status ON deliveries(delivery_agent_id, delivery_status);

-- DELIVERY AGENT INDEXES
CREATE INDEX idx_delivery_agents_user_id ON delivery_agents(user_id);
CREATE INDEX idx_delivery_agents_is_available ON delivery_agents(is_available);
CREATE INDEX idx_delivery_agents_available_status ON delivery_agents(is_available, rating DESC);

-- ADDRESS INDEXES
CREATE INDEX idx_customer_addresses_customer_id ON customer_addresses(customer_id);
CREATE INDEX idx_customer_addresses_is_default ON customer_addresses(is_default);
CREATE INDEX idx_restaurant_addresses_restaurant_id ON restaurant_addresses(restaurant_id);

-- REVIEW INDEXES
CREATE INDEX idx_reviews_customer_id ON reviews(customer_id);
CREATE INDEX idx_reviews_restaurant_id ON reviews(restaurant_id);
CREATE INDEX idx_reviews_order_id ON reviews(order_id);
CREATE INDEX idx_reviews_restaurant_rating ON reviews(restaurant_id, rating DESC);