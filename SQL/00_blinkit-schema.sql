CREATE TABLE blinkit_customers(
 customer_id VARCHAR PRIMARY KEY,
 customer_name VARCHAR,
 email VARCHAR ,
 phone VARCHAR ,
 address VARCHAR,
 area VARCHAR,
 pincode VARCHAR,
 registration_date DATE,
 customer_segment VARCHAR,
 total_orders INT,
 avg_order_value DECIMAL(8,2)
); 


CREATE TABLE blinkit_orders(
 order_id VARCHAR PRIMARY KEY,
 customer_id VARCHAR REFERENCES blinkit_customers(customer_id),
 order_date TIMESTAMP,
 promised_delivery_time TIMESTAMP,
 actual_delivery_time TIMESTAMP,
 delivery_status VARCHAR,
 order_total DECIMAL(8,2),
 payment_method VARCHAR,
 delivery_partner_id VARCHAR,
 store_id VARCHAR
 );

 CREATE TABLE blinkit_order_items (
    item_id SERIAL PRIMARY KEY,
    order_id VARCHAR REFERENCES blinkit_orders(order_id),
    product_id VARCHAR,
    quantity INT,
    unit_price DECIMAL
);

CREATE TABLE blinkit_products (
    product_id VARCHAR PRIMARY KEY,
    product_name VARCHAR,
    category VARCHAR,
    brand VARCHAR,
    price DECIMAL(8,2),
	mrp DECIMAL(8,2),
	margin_percentage INT,
	shelf_life_days INT,
	min_stock_level INT,
	max_stock_level INT
	);

CREATE TABLE blinkit_inventory (
    inventory_id SERIAL PRIMARY KEY,
    product_id VARCHAR REFERENCES blinkit_products(product_id),
    date DATE,
    stock_received INT,
    damaged_stock INT
);
	
CREATE TABLE blinkit_customer_feedback (
    feedback_id SERIAL PRIMARY KEY,
	order_id VARCHAR REFERENCES blinkit_orders(order_id),
    customer_id VARCHAR REFERENCES blinkit_customers(customer_id),
    product_id VARCHAR REFERENCES blinkit_products(product_id),
    rating INT,
    feedback_text TEXT,
    feedback_date DATE
);

CREATE TABLE blinkit_marketing_performance (
    campaign_id VARCHAR PRIMARY KEY,
    campaign_name VARCHAR,
    start_date DATE,
	target_audience VARCHAR,
	channel VARCHAR,
	revenue_generated DECIMAL(8,2),
	impressions INT,
	clicks INT,
	conversions INT
);


CREATE TABLE delivery_performances(
 order_id VARCHAR PRIMARY KEY REFERENCES blinkit_orders(order_id),
 delivery_partner_id VARCHAR ,
 promised_time TIMESTAMP ,
 actual_time TIMESTAMP ,
 delivery_time_minutes INT,
 distance_km DECIMAL,
 delivery_status VARCHAR,
 reason_if_delayed VARCHAR
 )

 