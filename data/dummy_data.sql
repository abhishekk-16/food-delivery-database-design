-- ============================================
-- INDIAN FOOD DELIVERY DATABASE - DUMMY DATA
-- ============================================

-- ==========================================
-- 1. INSERT USERS (Customers, Restaurant Owners, Delivery Agents)
-- ==========================================

-- CUSTOMERS (user_id 1-20)
INSERT INTO users (email, password_hash, phone_number, first_name, last_name, user_type, rating) VALUES
('rahul.sharma@gmail.com', 'hash123', '9876543210', 'Rahul', 'Sharma', 'customer', 4.85),
('priya.patel@gmail.com', 'hash456', '9876543211', 'Priya', 'Patel', 'customer', 4.92),
('amit.kumar@yahoo.com', 'hash789', '9876543212', 'Amit', 'Kumar', 'customer', 4.75),
('neha.singh@gmail.com', 'hash321', '9876543213', 'Neha', 'Singh', 'customer', 4.88),
('vikram.reddy@gmail.com', 'hash654', '9876543214', 'Vikram', 'Reddy', 'customer', 4.90),
('anjali.mehta@hotmail.com', 'hash987', '9876543215', 'Anjali', 'Mehta', 'customer', 4.82),
('rohan.joshi@gmail.com', 'hash111', '9876543216', 'Rohan', 'Joshi', 'customer', 4.78),
('kavya.nair@gmail.com', 'hash222', '9876543217', 'Kavya', 'Nair', 'customer', 4.95),
('arjun.verma@yahoo.com', 'hash333', '9876543218', 'Arjun', 'Verma', 'customer', 4.80),
('sneha.gupta@gmail.com', 'hash444', '9876543219', 'Sneha', 'Gupta', 'customer', 4.87),
('siddharth.rao@gmail.com', 'hash555', '9876543220', 'Siddharth', 'Rao', 'customer', 4.91),
('pooja.desai@gmail.com', 'hash666', '9876543221', 'Pooja', 'Desai', 'customer', 4.83),
('karan.kapoor@hotmail.com', 'hash777', '9876543222', 'Karan', 'Kapoor', 'customer', 4.79),
('diya.shah@gmail.com', 'hash888', '9876543223', 'Diya', 'Shah', 'customer', 4.94),
('aditya.mishra@gmail.com', 'hash999', '9876543224', 'Aditya', 'Mishra', 'customer', 4.86),
('ishita.banerjee@yahoo.com', 'hash1010', '9876543225', 'Ishita', 'Banerjee', 'customer', 4.89),
('harsh.agarwal@gmail.com', 'hash1111', '9876543226', 'Harsh', 'Agarwal', 'customer', 4.77),
('tanvi.chopra@gmail.com', 'hash1212', '9876543227', 'Tanvi', 'Chopra', 'customer', 4.93),
('yash.malhotra@gmail.com', 'hash1313', '9876543228', 'Yash', 'Malhotra', 'customer', 4.81),
('riya.saxena@hotmail.com', 'hash1414', '9876543229', 'Riya', 'Saxena', 'customer', 4.84);

-- RESTAURANT OWNERS (user_id 21-30)
INSERT INTO users (email, password_hash, phone_number, first_name, last_name, user_type, rating) VALUES
('sandeep.owner@gmail.com', 'ownerhash1', '9123456780', 'Sandeep', 'Khanna', 'restaurant_owner', 4.70),
('ramesh.owner@gmail.com', 'ownerhash2', '9123456781', 'Ramesh', 'Iyer', 'restaurant_owner', 4.85),
('suresh.owner@yahoo.com', 'ownerhash3', '9123456782', 'Suresh', 'Pillai', 'restaurant_owner', 4.80),
('mahesh.owner@gmail.com', 'ownerhash4', '9123456783', 'Mahesh', 'Menon', 'restaurant_owner', 4.75),
('dinesh.owner@gmail.com', 'ownerhash5', '9123456784', 'Dinesh', 'Bhat', 'restaurant_owner', 4.90),
('rajesh.owner@hotmail.com', 'ownerhash6', '9123456785', 'Rajesh', 'Kulkarni', 'restaurant_owner', 4.82),
('mukesh.owner@gmail.com', 'ownerhash7', '9123456786', 'Mukesh', 'Pandey', 'restaurant_owner', 4.88),
('naresh.owner@gmail.com', 'ownerhash8', '9123456787', 'Naresh', 'Shetty', 'restaurant_owner', 4.78),
('jignesh.owner@yahoo.com', 'ownerhash9', '9123456788', 'Jignesh', 'Amin', 'restaurant_owner', 4.92),
('yogesh.owner@gmail.com', 'ownerhash10', '9123456789', 'Yogesh', 'Goswami', 'restaurant_owner', 4.86);

-- DELIVERY AGENTS (user_id 31-45)
INSERT INTO users (email, password_hash, phone_number, first_name, last_name, user_type, rating) VALUES
('deepak.agent@gmail.com', 'agenthash1', '9988776650', 'Deepak', 'Yadav', 'delivery_agent', 4.85),
('manish.agent@gmail.com', 'agenthash2', '9988776651', 'Manish', 'Chauhan', 'delivery_agent', 4.78),
('prakash.agent@yahoo.com', 'agenthash3', '9988776652', 'Prakash', 'Thakur', 'delivery_agent', 4.92),
('sanjay.agent@gmail.com', 'agenthash4', '9988776653', 'Sanjay', 'Rawat', 'delivery_agent', 4.88),
('vijay.agent@gmail.com', 'agenthash5', '9988776654', 'Vijay', 'Tiwari', 'delivery_agent', 4.80),
('ajay.agent@hotmail.com', 'agenthash6', '9988776655', 'Ajay', 'Jha', 'delivery_agent', 4.75),
('ravi.agent@gmail.com', 'agenthash7', '9988776656', 'Ravi', 'Pandey', 'delivery_agent', 4.90),
('sunil.agent@gmail.com', 'agenthash8', '9988776657', 'Sunil', 'Rana', 'delivery_agent', 4.82),
('anil.agent@yahoo.com', 'agenthash9', '9988776658', 'Anil', 'Bisht', 'delivery_agent', 4.87),
('manoj.agent@gmail.com', 'agenthash10', '9988776659', 'Manoj', 'Negi', 'delivery_agent', 4.79),
('santosh.agent@gmail.com', 'agenthash11', '9988776660', 'Santosh', 'Bhatt', 'delivery_agent', 4.91),
('rakesh.agent@gmail.com', 'agenthash12', '9988776661', 'Rakesh', 'Joshi', 'delivery_agent', 4.84),
('ashok.agent@hotmail.com', 'agenthash13', '9988776662', 'Ashok', 'Bisht', 'delivery_agent', 4.76),
('pankaj.agent@gmail.com', 'agenthash14', '9988776663', 'Pankaj', 'Sharma', 'delivery_agent', 4.93),
('naveen.agent@gmail.com', 'agenthash15', '9988776664', 'Naveen', 'Mehta', 'delivery_agent', 4.89);

-- ==========================================
-- 2. INSERT RESTAURANTS
-- ==========================================

INSERT INTO restaurants (owner_id, restaurant_name, description, cuisine_type, phone_number, email, rating, total_orders, is_operational) VALUES
(66, 'Punjabi Dhaba Deluxe', 'Authentic North Indian cuisine with rich flavors', 'North Indian', '011-12345601', 'contact@punjabidhaba.com', 4.6, 1250, true),
(67, 'South Spice Express', 'Traditional South Indian breakfast and meals', 'South Indian', '044-12345602', 'hello@southspice.com', 4.7, 980, true),
(68, 'Mumbai Chaat Corner', 'Street food favorites from Mumbai', 'Street Food', '022-12345603', 'orders@mumbaichaat.com', 4.5, 1500, true),
(69, 'Biryani House Premium', 'Hyderabadi and Lucknowi biryani specialists', 'Biryani', '040-12345604', 'info@biryanihouse.com', 4.8, 2100, true),
(70, 'Chinese Wok Restaurant', 'Indo-Chinese fusion cuisine', 'Chinese', '080-12345605', 'support@chinesewok.com', 4.4, 850, true),
(71, 'Thali Junction', 'Unlimited Gujarati and Rajasthani thalis', 'Gujarati', '079-12345606', 'contact@thalijunction.com', 4.7, 1100, true),
(72, 'Pizza Paradise India', 'Wood-fired pizzas with Indian twist', 'Italian', '011-12345607', 'orders@pizzaparadise.com', 4.3, 920, true),
(73, 'Coastal Curry House', 'Goan and Kerala seafood specialties', 'Seafood', '0832-12345608', 'info@coastalcurry.com', 4.9, 780, true),
(74, 'Tandoori Nights', 'Grilled kebabs and tandoori items', 'North Indian', '0124-12345609', 'hello@tandoorinights.com', 4.6, 1320, true),
(75, 'Dosa Plaza', 'Variety of dosas and South Indian snacks', 'South Indian', '044-12345610', 'contact@dosaplaza.com', 4.5, 1650, true);

-- ==========================================
-- 3. INSERT RESTAURANT ADDRESSES
-- ==========================================

INSERT INTO restaurant_addresses (restaurant_id, street_address, city, state_province, postal_code, country, latitude, longitude, is_primary) VALUES
(21, '45 Connaught Place', 'New Delhi', 'Delhi', '110001', 'India', 28.63124000, 77.21790000, true),
(22, '12 T. Nagar Main Road', 'Chennai', 'Tamil Nadu', '600017', 'India', 13.04170000, 80.23410000, true),
(23, '89 Linking Road', 'Mumbai', 'Maharashtra', '400050', 'India', 19.05440000, 72.83090000, true),
(24, '23 Banjara Hills Road', 'Hyderabad', 'Telangana', '500034', 'India', 17.41650000, 78.44910000, true),
(25, '67 MG Road', 'Bangalore', 'Karnataka', '560001', 'India', 12.97550000, 77.60730000, true),
(26, '34 CG Road', 'Ahmedabad', 'Gujarat', '380009', 'India', 23.03960000, 72.55350000, true),
(27, '56 Rajouri Garden', 'New Delhi', 'Delhi', '110027', 'India', 28.64140000, 77.12150000, true),
(28, '78 Panaji Beach Road', 'Panaji', 'Goa', '403001', 'India', 15.49840000, 73.82750000, true),
(29, '91 Cyber City', 'Gurugram', 'Haryana', '122002', 'India', 28.49450000, 77.08260000, true),
(30, '101 Anna Salai', 'Chennai', 'Tamil Nadu', '600002', 'India', 13.06070000, 80.25930000, true);

-- ==========================================
-- 4. INSERT MENU ITEMS (10 items per restaurant)
-- ==========================================

-- Restaurant 1: Punjabi Dhaba Deluxe (North Indian)
INSERT INTO menu_items (restaurant_id, item_name, description, category, price, is_available, preparation_time) VALUES
(21, 'Butter Chicken', 'Creamy tomato gravy with tender chicken pieces', 'Main Course', 320.00, true, 25),
(21, 'Dal Makhani', 'Black lentils cooked overnight in butter and cream', 'Main Course', 240.00, true, 30),
(21, 'Paneer Tikka Masala', 'Grilled cottage cheese in spicy tomato gravy', 'Main Course', 280.00, true, 20),
(21, 'Garlic Naan', 'Soft bread with garlic and butter', 'Breads', 60.00, true, 10),
(21, 'Tandoori Roti', 'Whole wheat flatbread from tandoor', 'Breads', 40.00, true, 8),
(21, 'Chicken Biryani', 'Fragrant rice with spiced chicken', 'Rice', 350.00, true, 35),
(21, 'Lassi', 'Sweet yogurt drink', 'Beverages', 80.00, true, 5),
(21, 'Gulab Jamun', 'Sweet milk dumplings in sugar syrup', 'Desserts', 100.00, true, 5),
(21, 'Raita', 'Yogurt with cucumber and spices', 'Sides', 70.00, true, 5),
(21, 'Mixed Veg Curry', 'Seasonal vegetables in aromatic curry', 'Main Course', 220.00, true, 20);

-- Restaurant 2: South Spice Express (South Indian)
INSERT INTO menu_items (restaurant_id, item_name, description, category, price, is_available, preparation_time) VALUES
(22, 'Masala Dosa', 'Crispy rice crepe with potato filling', 'Breakfast', 120.00, true, 15),
(22, 'Idli Sambar', 'Steamed rice cakes with lentil soup', 'Breakfast', 80.00, true, 10),
(22, 'Medu Vada', 'Fried lentil donuts', 'Breakfast', 90.00, true, 12),
(22, 'Filter Coffee', 'South Indian style strong coffee', 'Beverages', 50.00, true, 5),
(22, 'Rava Dosa', 'Crispy semolina crepe', 'Breakfast', 110.00, true, 12),
(22, 'Uttapam', 'Thick rice pancake with toppings', 'Breakfast', 130.00, true, 18),
(22, 'Bisi Bele Bath', 'Spicy lentil rice with vegetables', 'Main Course', 150.00, true, 20),
(22, 'Coconut Chutney', 'Fresh coconut paste', 'Sides', 30.00, true, 5),
(22, 'Rasam', 'Tangy tamarind soup', 'Sides', 60.00, true, 10),
(22, 'Payasam', 'Sweet rice pudding with nuts', 'Desserts', 85.00, true, 15);

-- Restaurant 3: Mumbai Chaat Corner (Street Food)
INSERT INTO menu_items (restaurant_id, item_name, description, category, price, is_available, preparation_time) VALUES
(23, 'Pav Bhaji', 'Spicy vegetable curry with butter bread', 'Street Food', 140.00, true, 15),
(23, 'Vada Pav', 'Spiced potato fritter in bread bun', 'Street Food', 50.00, true, 10),
(23, 'Pani Puri', '6 crispy puris with tangy water', 'Chaat', 60.00, true, 8),
(23, 'Bhel Puri', 'Puffed rice with chutneys and sev', 'Chaat', 70.00, true, 10),
(23, 'Dahi Puri', 'Crispy puris with yogurt and chutney', 'Chaat', 80.00, true, 12),
(23, 'Sev Puri', 'Flat puris topped with chutneys and sev', 'Chaat', 75.00, true, 10),
(23, 'Masala Chai', 'Spiced Indian tea', 'Beverages', 30.00, true, 5),
(23, 'Misal Pav', 'Spicy sprouts curry with bread', 'Street Food', 110.00, true, 18),
(23, 'Ragda Pattice', 'Potato patty with white pea curry', 'Street Food', 90.00, true, 15),
(23, 'Kulfi Falooda', 'Indian ice cream with noodles', 'Desserts', 120.00, true, 8);

-- Restaurant 4: Biryani House Premium (Biryani)
INSERT INTO menu_items (restaurant_id, item_name, description, category, price, is_available, preparation_time) VALUES
(24, 'Hyderabadi Chicken Biryani', 'Aromatic basmati rice with spiced chicken', 'Biryani', 380.00, true, 40),
(24, 'Mutton Biryani', 'Tender mutton pieces with fragrant rice', 'Biryani', 450.00, true, 45),
(24, 'Veg Dum Biryani', 'Mixed vegetables in layered rice', 'Biryani', 280.00, true, 35),
(24, 'Egg Biryani', 'Boiled eggs in flavorful rice', 'Biryani', 250.00, true, 30),
(24, 'Paneer Biryani', 'Cottage cheese chunks in aromatic rice', 'Biryani', 300.00, true, 35),
(24, 'Raita', 'Cool yogurt with onions and cucumber', 'Sides', 60.00, true, 5),
(24, 'Mirchi Ka Salan', 'Spicy chili curry', 'Sides', 90.00, true, 15),
(24, 'Double Ka Meetha', 'Bread pudding dessert', 'Desserts', 110.00, true, 10),
(24, 'Chicken 65', 'Spicy fried chicken appetizer', 'Starters', 220.00, true, 20),
(24, 'Kebab Platter', 'Assorted grilled kebabs', 'Starters', 350.00, true, 25);

-- Restaurant 5: Chinese Wok Restaurant (Chinese)
INSERT INTO menu_items (restaurant_id, item_name, description, category, price, is_available, preparation_time) VALUES
(25, 'Veg Hakka Noodles', 'Stir-fried noodles with vegetables', 'Noodles', 180.00, true, 15),
(25, 'Chicken Fried Rice', 'Fried rice with chicken and veggies', 'Rice', 220.00, true, 18),
(25, 'Chilli Chicken', 'Spicy chicken in Indo-Chinese sauce', 'Main Course', 280.00, true, 20),
(25, 'Veg Manchurian', 'Fried vegetable balls in tangy sauce', 'Main Course', 200.00, true, 18),
(25, 'Spring Rolls', 'Crispy vegetable rolls', 'Starters', 150.00, true, 12),
(25, 'Chicken Momos', '8 pieces steamed dumplings', 'Starters', 160.00, true, 15),
(25, 'Hot and Sour Soup', 'Spicy and tangy soup', 'Soup', 120.00, true, 10),
(25, 'Schezwan Fried Rice', 'Spicy fried rice', 'Rice', 210.00, true, 18),
(25, 'Paneer Chilli', 'Cottage cheese in spicy sauce', 'Main Course', 240.00, true, 20),
(25, 'Date Pancake', 'Sweet date dessert', 'Desserts', 130.00, true, 15);

-- Restaurant 6: Thali Junction (Gujarati)
INSERT INTO menu_items (restaurant_id, item_name, description, category, price, is_available, preparation_time) VALUES
(26, 'Gujarati Thali', 'Unlimited traditional Gujarati meal', 'Thali', 350.00, true, 25),
(26, 'Rajasthani Thali', 'Unlimited Rajasthani delicacies', 'Thali', 380.00, true, 25),
(26, 'Dhokla', 'Steamed gram flour snack', 'Snacks', 80.00, true, 10),
(26, 'Khandvi', 'Rolled gram flour snack', 'Snacks', 90.00, true, 15),
(26, 'Gujarati Kadhi', 'Sweet and tangy yogurt curry', 'Main Course', 120.00, true, 20),
(26, 'Undhiyu', 'Mixed vegetable Gujarati specialty', 'Main Course', 180.00, true, 30),
(26, 'Thepla', 'Spiced flatbread', 'Breads', 60.00, true, 12),
(26, 'Shrikhand', 'Sweetened strained yogurt', 'Desserts', 100.00, true, 5),
(26, 'Chaas', 'Spiced buttermilk', 'Beverages', 40.00, true, 5),
(26, 'Mohanthal', 'Gram flour sweet', 'Desserts', 110.00, true, 5);

-- Restaurant 7: Pizza Paradise India (Italian)
INSERT INTO menu_items (restaurant_id, item_name, description, category, price, is_available, preparation_time) VALUES
(27, 'Margherita Pizza', 'Classic tomato and cheese pizza', 'Pizza', 320.00, true, 20),
(27, 'Paneer Tikka Pizza', 'Indian fusion pizza with paneer', 'Pizza', 380.00, true, 22),
(27, 'Chicken Tandoori Pizza', 'Tandoori chicken on pizza base', 'Pizza', 420.00, true, 25),
(27, 'Veggie Supreme Pizza', 'Loaded with vegetables', 'Pizza', 360.00, true, 22),
(27, 'Garlic Bread', 'Toasted bread with garlic butter', 'Sides', 120.00, true, 10),
(27, 'Pasta Alfredo', 'Creamy white sauce pasta', 'Pasta', 280.00, true, 18),
(27, 'Pasta Arrabiata', 'Spicy tomato sauce pasta', 'Pasta', 260.00, true, 18),
(27, 'Chocolate Lava Cake', 'Warm chocolate dessert', 'Desserts', 150.00, true, 15),
(27, 'Tiramisu', 'Italian coffee dessert', 'Desserts', 180.00, true, 10),
(27, 'Coke', 'Soft drink', 'Beverages', 50.00, true, 2);

-- Restaurant 8: Coastal Curry House (Seafood)
INSERT INTO menu_items (restaurant_id, item_name, description, category, price, is_available, preparation_time) VALUES
(28, 'Fish Curry', 'Goan style spicy fish curry', 'Main Course', 380.00, true, 25),
(28, 'Prawn Fry', 'Pan-fried prawns with spices', 'Main Course', 450.00, true, 20),
(28, 'Crab Masala', 'Kerala style crab curry', 'Main Course', 520.00, true, 30),
(28, 'Fish Tikka', 'Grilled marinated fish', 'Starters', 320.00, true, 18),
(28, 'Vindaloo Pork', 'Spicy Goan pork curry', 'Main Course', 350.00, true, 35),
(28, 'Squid Fry', 'Crispy fried squid', 'Starters', 380.00, true, 15),
(28, 'Appam', 'Rice pancake', 'Breads', 50.00, true, 10),
(28, 'Kerala Parotta', 'Layered flatbread', 'Breads', 60.00, true, 12),
(28, 'Sol Kadhi', 'Coconut kokum drink', 'Beverages', 70.00, true, 5),
(28, 'Bebinca', 'Goan layered dessert', 'Desserts', 140.00, true, 10);

-- Restaurant 9: Tandoori Nights (North Indian)
INSERT INTO menu_items (restaurant_id, item_name, description, category, price, is_available, preparation_time) VALUES
(29, 'Chicken Tikka', 'Grilled chicken chunks', 'Starters', 280.00, true, 20),
(29, 'Seekh Kebab', 'Minced meat on skewers', 'Starters', 300.00, true, 22),
(29, 'Paneer Tikka', 'Grilled cottage cheese', 'Starters', 240.00, true, 18),
(29, 'Tandoori Chicken', 'Half chicken marinated and grilled', 'Main Course', 380.00, true, 30),
(29, 'Rogan Josh', 'Kashmiri mutton curry', 'Main Course', 420.00, true, 35),
(29, 'Kadai Paneer', 'Cottage cheese in tomato gravy', 'Main Course', 280.00, true, 20),
(29, 'Butter Naan', 'Soft leavened bread', 'Breads', 50.00, true, 8),
(29, 'Kulcha', 'Stuffed bread', 'Breads', 70.00, true, 12),
(29, 'Mint Chutney', 'Fresh mint sauce', 'Sides', 40.00, true, 5),
(29, 'Phirni', 'Rice pudding dessert', 'Desserts', 90.00, true, 10);

-- Restaurant 10: Dosa Plaza (South Indian)
INSERT INTO menu_items (restaurant_id, item_name, description, category, price, is_available, preparation_time) VALUES
(30, 'Paper Dosa', 'Extra thin crispy dosa', 'Breakfast', 130.00, true, 15),
(30, 'Mysore Masala Dosa', 'Spicy dosa with potato filling', 'Breakfast', 140.00, true, 18),
(30, 'Cheese Dosa', 'Dosa with cheese filling', 'Breakfast', 150.00, true, 15),
(30, 'Paneer Dosa', 'Dosa with cottage cheese', 'Breakfast', 160.00, true, 18),
(30, 'Set Dosa', '3 small soft dosas', 'Breakfast', 110.00, true, 12),
(30, 'Pongal', 'Rice and lentil dish', 'Breakfast', 100.00, true, 15),
(30, 'Sambhar Vada', 'Lentil donuts in sambar', 'Breakfast', 95.00, true, 12),
(30, 'Upma', 'Semolina breakfast dish', 'Breakfast', 85.00, true, 10),
(30, 'Lemon Rice', 'Tangy rice with peanuts', 'Main Course', 120.00, true, 15),
(30, 'Badam Milk', 'Almond flavored milk', 'Beverages', 70.00, true, 5);

-- ==========================================
-- 5. INSERT CUSTOMER ADDRESSES
-- ==========================================

INSERT INTO customer_addresses (customer_id, address_type, street_address, city, state_province, postal_code, country, latitude, longitude, is_default) VALUES
-- Customer 1 (Rahul Sharma)
(46, 'home', '45 Lajpat Nagar', 'New Delhi', 'Delhi', '110024', 'India', 28.56770000, 77.24340000, true),
(46, 'work', '12 Nehru Place', 'New Delhi', 'Delhi', '110019', 'India', 28.54960000, 77.25060000, false),
-- Customer 2 (Priya Patel)
(47, 'home', '78 Adyar', 'Chennai', 'Tamil Nadu', '600020', 'India', 13.00690000, 80.25730000, true),
-- Customer 3 (Amit Kumar)
(48, 'home', '23 Bandra West', 'Mumbai', 'Maharashtra', '400050', 'India', 19.05970000, 72.82920000, true),
(48, 'work', '56 Andheri East', 'Mumbai', 'Maharashtra', '400069', 'India', 19.11970000, 72.86800000, false),
-- Customer 4 (Neha Singh)
(49, 'home', '89 Jubilee Hills', 'Hyderabad', 'Telangana', '500033', 'India', 17.43260000, 78.40890000, true),
-- Customer 5 (Vikram Reddy)
(50, 'home', '34 Koramangala', 'Bangalore', 'Karnataka', '560034', 'India', 12.93480000, 77.62750000, true),
(50, 'work', '67 Whitefield', 'Bangalore', 'Karnataka', '560066', 'India', 12.96980000, 77.75010000, false),
-- Customer 6 (Anjali Mehta)
(51, 'home', '12 Vastrapur', 'Ahmedabad', 'Gujarat', '380015', 'India', 23.03620000, 72.52470000, true),
-- Customer 7 (Rohan Joshi)
(52, 'home', '56 Dwarka', 'New Delhi', 'Delhi', '110075', 'India', 28.59230000, 77.04640000, true),
-- Customer 8 (Kavya Nair)
(53, 'home', '90 Panjim', 'Panaji', 'Goa', '403001', 'India', 15.49160000, 73.82770000, true),
-- Customer 9 (Arjun Verma)
(54, 'home', '23 DLF Phase 3', 'Gurugram', 'Haryana', '122002', 'India', 28.49290000, 77.09320000, true),
-- Customer 10 (Sneha Gupta)
(55, 'home', '45 Nungambakkam', 'Chennai', 'Tamil Nadu', '600034', 'India', 13.05980000, 80.24250000, true),
-- Customer 11-20 (one address each)
(56, 'home', '78 Koti', 'Hyderabad', 'Telangana', '500095', 'India', 17.39140000, 78.47560000, true),
(57, 'home', '12 Navrangpura', 'Ahmedabad', 'Gujarat', '380009', 'India', 23.03570000, 72.55350000, true),
(58, 'home', '34 Powai', 'Mumbai', 'Maharashtra', '400076', 'India', 19.11680000, 72.90550000, true),
(59, 'home', '56 Satellite', 'Ahmedabad', 'Gujarat', '380015', 'India', 23.02650000, 72.51200000, true),
(60, 'home', '89 Sector 14', 'Gurugram', 'Haryana', '122001', 'India', 28.47440000, 77.04710000, true),
(61, 'home', '23 Salt Lake', 'Kolkata', 'West Bengal', '700091', 'India', 22.58560000, 88.41750000, true),
(62, 'home', '45 Civil Lines', 'Jaipur', 'Rajasthan', '302006', 'India', 26.93410000, 75.80570000, true),
(63, 'home', '67 Hazratganj', 'Lucknow', 'Uttar Pradesh', '226001', 'India', 26.85370000, 80.94990000, true),
(64, 'home', '90 Model Town', 'Ludhiana', 'Punjab', '141002', 'India', 30.70610000, 75.87190000, true),
(65, 'home', '12 Anna Nagar', 'Chennai', 'Tamil Nadu', '600040', 'India', 13.08510000, 80.21010000, true);

-- ==========================================
-- 6. INSERT DELIVERY AGENTS
-- ==========================================

INSERT INTO delivery_agents (user_id, vehicle_type, vehicle_number, rating, total_deliveries, is_available) VALUES
(76, 'motorcycle', 'DL-01-AB-1234', 4.85, 523, true),
(77, 'scooter', 'DL-02-CD-5678', 4.78, 412, true),
(78, 'motorcycle', 'TN-03-EF-9012', 4.92, 687, false),
(79, 'motorcycle', 'MH-04-GH-3456', 4.88, 598, true),
(80, 'scooter', 'KA-05-IJ-7890', 4.80, 445, true),
(81, 'bicycle', 'DL-06-KL-1234', 4.75, 321, true),
(82, 'motorcycle', 'GJ-07-MN-5678', 4.90, 612, false),
(83, 'scooter', 'DL-08-OP-9012', 4.82, 489, true),
(84, 'motorcycle', 'HR-09-QR-3456', 4.87, 553, true),
(85, 'scooter', 'TN-10-ST-7890', 4.79, 467, true),
(86, 'motorcycle', 'TS-11-UV-1234', 4.91, 634, true),
(87, 'scooter', 'GJ-12-WX-5678', 4.84, 501, true),
(88, 'bicycle', 'MH-13-YZ-9012', 4.76, 389, true),
(89, 'motorcycle', 'DL-14-AA-3456', 4.93, 712, false),
(90, 'scooter', 'KA-15-BB-7890', 4.89, 578, true);

-- ==========================================
-- 7. INSERT ORDERS (20 diverse orders)
-- ==========================================

INSERT INTO orders (customer_id, restaurant_id, delivery_address_id, order_date, requested_delivery_time, total_amount, discount_amount, delivery_fee, tax_amount, order_status, payment_status, special_instructions) VALUES
-- Order 1: Delivered
(46, 21, 24, '2025-11-20 19:30:00', '2025-11-20 20:30:00', 660.00, 0, 50.00, 33.00, 'delivered', 'paid', 'Extra spicy please'),
-- Order 2: Out for delivery
(47, 22, 26, '2025-11-22 12:00:00', '2025-11-22 13:00:00', 320.00, 20.00, 50.00, 16.00, 'out_for_delivery', 'paid', NULL),
-- Order 3: Preparing
(48, 23, 27, '2025-11-22 16:45:00', '2025-11-22 17:45:00', 290.00, 0, 50.00, 14.50, 'preparing', 'paid', 'Less spicy'),
-- Order 4: Confirmed
(49, 24, 30, '2025-11-22 17:00:00', '2025-11-22 18:15:00', 820.00, 50.00, 50.00, 41.00, 'confirmed', 'paid', NULL),
-- Order 5: Pending
(50, 25, 31, '2025-11-22 17:10:00', '2025-11-22 18:30:00', 580.00, 0, 50.00, 29.00, 'pending', 'pending', 'No onions'),
-- Order 6: Delivered
(51, 26, 34, '2025-11-21 13:30:00', '2025-11-21 14:30:00', 350.00, 0, 50.00, 17.50, 'delivered', 'paid', NULL),
-- Order 7: Cancelled
(52, 27, 35, '2025-11-21 19:00:00', '2025-11-21 20:00:00', 700.00, 0, 50.00, 35.00, 'cancelled', 'refunded', 'Order cancelled by customer'),
-- Order 8: Delivered
(53, 28, 36, '2025-11-20 20:00:00', '2025-11-20 21:00:00', 830.00, 30.00, 50.00, 41.50, 'delivered', 'paid', 'Medium spicy'),
-- Order 9: Ready
(54, 29, 37, '2025-11-22 17:15:00', '2025-11-22 18:00:00', 660.00, 0, 50.00, 33.00, 'ready', 'paid', NULL),
-- Order 10: Delivered
(55, 30, 38, '2025-11-21 08:30:00', '2025-11-21 09:30:00', 380.00, 0, 50.00, 19.00, 'delivered', 'paid', 'Extra chutney'),
-- Order 11: Out for delivery
(56, 21, 39, '2025-11-22 17:20:00', '2025-11-22 18:20:00', 540.00, 0, 50.00, 27.00, 'out_for_delivery', 'paid', NULL),
-- Order 12: Preparing
(57, 22, 40, '2025-11-22 17:00:00', '2025-11-22 17:45:00', 290.00, 10.00, 50.00, 14.50, 'preparing', 'paid', 'Pack separately'),
-- Order 13: Confirmed
(58, 23, 41, '2025-11-22 17:05:00', '2025-11-22 18:00:00', 310.00, 0, 50.00, 15.50, 'confirmed', 'paid', NULL),
-- Order 14: Pending
(59, 24, 42, '2025-11-22 17:18:00', '2025-11-22 18:30:00', 650.00, 0, 50.00, 32.50, 'pending', 'pending', 'Call before delivery'),
-- Order 15: Delivered
(60, 25, 43, '2025-11-21 12:00:00', '2025-11-21 13:00:00', 490.00, 0, 50.00, 24.50, 'delivered', 'paid', NULL),
-- Order 16: Delivered
(61, 26, 44, '2025-11-20 14:00:00', '2025-11-20 15:00:00', 380.00, 0, 50.00, 19.00, 'delivered', 'paid', 'Extra rice'),
-- Order 17: Ready
(62, 27, 45, '2025-11-22 17:25:00', '2025-11-22 18:15:00', 680.00, 20.00, 50.00, 34.00, 'ready', 'paid', NULL),
-- Order 18: Preparing
(63, 28, 46, '2025-11-22 16:50:00', '2025-11-22 17:50:00', 900.00, 0, 50.00, 45.00, 'preparing', 'paid', 'Less oil'),
-- Order 19: Confirmed
(64, 29, 24, '2025-11-22 17:12:00', '2025-11-22 18:00:00', 720.00, 30.00, 50.00, 36.00, 'confirmed', 'paid', NULL),
-- Order 20: Delivered
(65, 30, 25, '2025-11-21 09:00:00', '2025-11-21 10:00:00', 400.00, 0, 50.00, 20.00, 'delivered', 'paid', 'Extra sambar');

-- ==========================================
-- 8. INSERT ORDER ITEMS
-- ==========================================

-- Order 1 items (680 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(41, 101, 2, 320.00),  -- Butter Chicken x2
(41, 105, 1, 40.00);   -- Tandoori Roti x1

-- Order 2 items (320 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(42, 111, 2, 120.00), -- Masala Dosa x2
(42, 112, 1, 80.00);  -- Idli Sambar x1

-- Order 3 items (290 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(43, 121, 2, 140.00), -- Pav Bhaji x2
(43, 127, 1, 30.00);  -- Masala Chai x1

-- Order 4 items (820 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(44, 131, 1, 380.00), -- Hyderabadi Chicken Biryani
(44, 132, 1, 450.00); -- Mutton Biryani

-- Order 5 items (580 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(45, 141, 2, 180.00), -- Veg Hakka Noodles x2
(45, 143, 1, 220.00); -- Chilli Chicken

-- Order 6 items (350 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(46, 151, 1, 350.00); -- Gujarati Thali

-- Order 7 items (700 total - cancelled)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(47, 161, 1, 320.00), -- Margherita Pizza
(47, 163, 1, 380.00); -- Paneer Tikka Pizza

-- Order 8 items (830 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(48, 171, 1, 380.00), -- Fish Curry
(48, 172, 1, 450.00); -- Prawn Fry

-- Order 9 items (660 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(49, 181, 2, 280.00), -- Chicken Tikka x2
(49, 184, 1, 100.00); -- Paneer Tikka

-- Order 10 items (380 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(50, 191, 2, 130.00), -- Paper Dosa x2
(50, 192, 1, 120.00); -- Mysore Masala Dosa

-- Order 11 items (540 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(51, 102, 2, 240.00),  -- Dal Makhani x2
(51, 104, 3, 60.00);   -- Garlic Naan x3

-- Order 12 items (290 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(52, 115, 2, 120.00), -- Rava Dosa x2
(52, 114, 1, 50.00);  -- Filter Coffee

-- Order 13 items (310 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(53, 123, 3, 60.00),  -- Pani Puri x3
(53, 124, 2, 70.00);  -- Bhel Puri x2

-- Order 14 items (650 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(54, 133, 2, 280.00), -- Veg Dum Biryani x2
(54, 136, 1, 90.00);  -- Mirchi Ka Salan

-- Order 15 items (490 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(55, 142, 1, 220.00), -- Chicken Fried Rice
(55, 144, 1, 200.00), -- Veg Manchurian
(55, 145, 1, 70.00);  -- Spring Rolls

-- Order 16 items (380 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(56, 152, 1, 380.00); -- Rajasthani Thali

-- Order 17 items (680 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(57, 161, 1, 320.00), -- Margherita Pizza
(57, 164, 1, 360.00); -- Veggie Supreme Pizza

-- Order 18 items (900 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(58, 171, 1, 380.00), -- Fish Curry
(58, 173, 1, 520.00); -- Crab Masala

-- Order 19 items (720 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(59, 184, 2, 380.00); -- Tandoori Chicken x2

-- Order 20 items (400 total)
INSERT INTO order_items (order_id, menu_item_id, quantity, item_price) VALUES
(60, 191, 2, 130.00), -- Paper Dosa x2
(60, 196, 2, 100.00); -- Pongal x2

-- ==========================================
-- 9. INSERT PAYMENTS
-- ==========================================

INSERT INTO payments (order_id, payment_method, payment_amount, transaction_id, payment_status, payment_date) VALUES
(41, 'upi', 764.00, 'TXN202511201930001', 'completed', '2025-11-20 19:32:00'),
(42, 'credit_card', 366.00, 'TXN202511221200001', 'completed', '2025-11-22 12:02:00'),
(43, 'upi', 375.50, 'TXN202511221645001', 'completed', '2025-11-22 16:47:00'),
(44, 'debit_card', 871.50, 'TXN202511221700001', 'completed', '2025-11-22 17:02:00'),
(45, 'wallet', 659.00, NULL, 'pending', NULL),
(46, 'upi', 417.50, 'TXN202511211330001', 'completed', '2025-11-21 13:32:00'),
(47, 'credit_card', 785.00, 'TXN202511211900001', 'refunded', '2025-11-21 19:05:00'),
(48, 'upi', 891.50, 'TXN202511202000001', 'completed', '2025-11-20 20:02:00'),
(49, 'cash', 743.00, NULL, 'completed', '2025-11-22 17:17:00'),
(50, 'upi', 449.00, 'TXN202511210830001', 'completed', '2025-11-21 08:32:00'),
(51, 'upi', 743.00, 'TXN202511221720001', 'completed', '2025-11-22 17:22:00'),
(52, 'wallet', 344.50, 'TXN202511221700002', 'completed', '2025-11-22 17:02:00'),
(53, 'credit_card', 386.00, 'TXN202511221705001', 'completed', '2025-11-22 17:07:00'),
(54, 'upi', 732.50, NULL, 'pending', NULL),
(55, 'upi', 564.50, 'TXN202511211200001', 'completed', '2025-11-21 12:02:00'),
(56, 'cash', 449.00, NULL, 'completed', '2025-11-20 14:45:00'),
(57, 'debit_card', 744.00, 'TXN202511221725001', 'completed', '2025-11-22 17:27:00'),
(58, 'upi', 995.00, 'TXN202511221650001', 'completed', '2025-11-22 16:52:00'),
(59, 'wallet', 818.00, 'TXN202511221712001', 'completed', '2025-11-22 17:14:00'),
(60, 'upi', 533.00, 'TXN202511210900001', 'completed', '2025-11-21 09:02:00');

-- ==========================================
-- 10. INSERT DELIVERIES
-- ==========================================

INSERT INTO deliveries (order_id, delivery_agent_id, pickup_time, estimated_delivery_time, actual_delivery_time, delivery_status, distance_km, delivery_rating, delivery_feedback) VALUES
-- Delivered orders
(41, 16, '2025-11-20 19:50:00', '2025-11-20 20:30:00', '2025-11-20 20:25:00', 'delivered', 3.5, 5, 'Very fast delivery'),
(46, 17, '2025-11-21 13:50:00', '2025-11-21 14:30:00', '2025-11-21 14:28:00', 'delivered', 2.8, 5, 'Good service'),
(48, 19, '2025-11-20 20:20:00', '2025-11-20 21:00:00', '2025-11-20 20:55:00', 'delivered', 4.2, 4, 'Food was slightly cold'),
(50, 20, '2025-11-21 08:50:00', '2025-11-21 09:30:00', '2025-11-21 09:27:00', 'delivered', 1.9, 5, 'Excellent'),
(55, 22, '2025-11-21 12:20:00', '2025-11-21 13:00:00', '2025-11-21 12:58:00', 'delivered', 3.1, 5, 'On time'),
(56, 23, '2025-11-20 14:20:00', '2025-11-20 15:00:00', '2025-11-20 14:52:00', 'delivered', 2.5, 4, 'Good'),
(60, 24, '2025-11-21 09:20:00', '2025-11-21 10:00:00', '2025-11-21 09:58:00', 'delivered', 3.8, 5, 'Great service'),

-- Out for delivery orders
(42, 18, '2025-11-22 12:20:00', '2025-11-22 13:00:00', NULL, 'in_transit', 3.2, NULL, NULL),
(51, 25, '2025-11-22 17:40:00', '2025-11-22 18:20:00', NULL, 'in_transit', 2.9, NULL, NULL),

-- Ready orders (not assigned yet)
(49, NULL, NULL, '2025-11-22 18:00:00', NULL, 'pickup_pending', 4.1, NULL, NULL),
(57, NULL, NULL, '2025-11-22 18:15:00', NULL, 'pickup_pending', 3.7, NULL, NULL),

-- Preparing orders
(43, NULL, NULL, '2025-11-22 17:45:00', NULL, 'pending', 2.3, NULL, NULL),
(52, NULL, NULL, '2025-11-22 17:45:00', NULL, 'pending', 1.8, NULL, NULL),
(58, NULL, NULL, '2025-11-22 17:50:00', NULL, 'pending', 5.2, NULL, NULL),

-- Confirmed orders
(44, NULL, NULL, '2025-11-22 18:15:00', NULL, 'pending', 3.9, NULL, NULL),
(53, NULL, NULL, '2025-11-22 18:00:00', NULL, 'pending', 2.6, NULL, NULL),
(59, NULL, NULL, '2025-11-22 18:00:00', NULL, 'pending', 4.5, NULL, NULL),

-- Pending orders (no delivery record yet)
-- Orders 45, 54 don't have delivery records yet

-- Cancelled order
(47, NULL, NULL, NULL, NULL, 'cancelled', NULL, NULL, NULL);

-- ==========================================
-- 11. INSERT REVIEWS
-- ==========================================

INSERT INTO reviews (customer_id, restaurant_id, order_id, rating, food_quality_rating, delivery_rating, comment) VALUES
(46, 21, 41, 5, 5, 5, 'Excellent butter chicken! Will order again.'),
(51, 26, 46, 5, 5, 5, 'Authentic Gujarati thali, loved it!'),
(53, 28, 48, 4, 5, 4, 'Fish curry was amazing, but delivery was slightly delayed'),
(55, 30, 50, 5, 5, 5, 'Best dosa in Chennai!'),
(60, 25, 55, 4, 4, 5, 'Good Chinese food, delivery was quick'),
(61, 26, 56, 5, 5, 4, 'Great thali, very filling'),
(65, 30, 60, 5, 5, 5, 'Perfect South Indian breakfast');

-- ==========================================
-- SUMMARY OF INSERTED DATA
-- ==========================================

/*
USERS: 45 total
  - Customers: 20 (user_id 1-20)
  - Restaurant Owners: 10 (user_id 21-30)
  - Delivery Agents: 15 (user_id 31-45)

RESTAURANTS: 10 (covering various Indian cuisines)

RESTAURANT ADDRESSES: 10 (one per restaurant, covering major Indian cities)

MENU ITEMS: 100 (10 items per restaurant)

CUSTOMER ADDRESSES: 24 (customers have 1-2 addresses)

DELIVERY AGENTS: 15 (with various vehicle types)

ORDERS: 20 
  - Delivered: 7
  - Out for delivery: 2
  - Ready: 2
  - Preparing: 3
  - Confirmed: 3
  - Pending: 2
  - Cancelled: 1

ORDER ITEMS: 41 (realistic item combinations per order)

PAYMENTS: 20 (one per order, various payment methods)

DELIVERIES: 18 (tracking info for orders beyond pending)

REVIEWS: 7 (for delivered orders)

CITIES COVERED:
- Delhi, Mumbai, Chennai, Hyderabad, Bangalore
- Ahmedabad, Panaji, Gurugram, Kolkata, Jaipur
- Lucknow, Ludhiana

CUISINE TYPES:
- North Indian, South Indian, Street Food, Biryani
- Chinese, Gujarati, Italian, Seafood

This data is perfect for practicing:
- Complex JOINs
- Aggregations
- Window functions
- Subqueries
- Geospatial calculations
- Order lifecycle tracking
- Revenue analytics
*/