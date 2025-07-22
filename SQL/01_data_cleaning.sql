-- blinkit_customers
-- 1. Check for NULLs
SELECT * FROM blinkit_customers
WHERE customer_name IS NULL OR email IS NULL OR phone IS NULL;

-- 2. Standardize date format
SELECT registration_date FROM blinkit_customers LIMIT 5;

-- 3. Remove duplicates
SELECT customer_id, COUNT(*) FROM blinkit_customers
GROUP BY customer_id HAVING COUNT(*) > 1;

-- 4. Check for invalid phone numbers
SELECT * FROM blinkit_customers
WHERE LENGTH(phone) < 10 OR phone ~ '[^0-9]';

-- Fix the error in phone numbers
SELECT customer_id, phone,
REPLACE(phone, '9.1', '+91') AS new_phone
FROM blinkit_customers
WHERE phone LIKE '%9.1%';

-- 5. Normalize customer segments
SELECT DISTINCT customer_segment FROM blinkit_customers;
-- → If needed, use UPDATE to rename inconsistent values

-- blinkit_orders
-- 1. Check for NULL delivery times
SELECT * FROM blinkit_orders
WHERE promised_delivery_time IS NULL OR actual_delivery_time IS NULL;

-- 2. Calculate delivery delay
ALTER TABLE blinkit_orders ADD COLUMN delivery_delay_mins INT;

UPDATE blinkit_orders
SET delivery_delay_mins = EXTRACT(EPOCH FROM (actual_delivery_time - promised_delivery_time)) / 60;

-- 3. Check for negative delays
SELECT * FROM blinkit_orders WHERE delivery_delay_mins < 0;

-- 4. Handle payment methods
SELECT DISTINCT payment_method FROM blinkit_orders;


--blinkit_products
-- 1. Clean up product names and categories
UPDATE blinkit_products
SET product_name = INITCAP(TRIM(product_name));

UPDATE blinkit_products
SET category = INITCAP(TRIM(category));

-- 2. Ensure price is not negative or zero
UPDATE blinkit_products
SET price = NULL
WHERE price <= 0;

-- See any NULLs after cleaning
SELECT * FROM blinkit_products WHERE category IS NULL;

--blinkit_inventory
-- 1. Trim product_id (in case of spaces from CSV)
UPDATE blinkit_inventory
SET product_id = TRIM(product_id)
WHERE product_id IS NOT NULL;

-- 2. Replace negative values with NULL (invalid data)
UPDATE blinkit_inventory
SET stock_received = NULL
WHERE stock_received < 0;

UPDATE blinkit_inventory
SET damaged_stock = NULL
WHERE damaged_stock < 0;

-- 3. Add net_stock column (available stock = received - damaged)
ALTER TABLE blinkit_inventory
ADD COLUMN net_stock INT;

-- 4. Calculate net_stock
UPDATE blinkit_inventory
SET net_stock = stock_received - damaged_stock;

--blinkit_marketing_performances
-- 1. Trim whitespace from all text columns
UPDATE blinkit_marketing_performance
SET
    campaign_id = TRIM(campaign_id),
    campaign_name = TRIM(campaign_name),
    target_audience = TRIM(target_audience),
    channel = TRIM(channel);

-- 2. Replace negative or invalid numerical values with NULL
UPDATE blinkit_marketing_performance
SET revenue_generated = NULL
WHERE revenue_generated < 0;

UPDATE blinkit_marketing_performance
SET impressions = NULL
WHERE impressions < 0;

UPDATE blinkit_marketing_performance
SET clicks = NULL
WHERE clicks < 0;

UPDATE blinkit_marketing_performance
SET conversions = NULL
WHERE conversions < 0;

-- 3. Add new columns: CTR (Click-through rate) and Conversion Rate
ALTER TABLE blinkit_marketing_performance
ADD COLUMN ctr DECIMAL(5,2),
ADD COLUMN conversion_rate DECIMAL(5,2);

-- 4. Calculate derived metrics
UPDATE blinkit_marketing_performance
SET
    ctr = ROUND((clicks::DECIMAL / impressions) * 100, 2)
WHERE impressions > 0;

UPDATE blinkit_marketing_performance
SET
    conversion_rate = ROUND((conversions::DECIMAL / clicks) * 100, 2)
WHERE clicks > 0;

--blinkit_order_items
-- 1. Trim text columns (in case of CSV space issues)
UPDATE blinkit_order_items
SET 
    order_id = TRIM(order_id),
    product_id = TRIM(product_id);

-- 2. Replace negative quantity or price with NULL (invalid values)
UPDATE blinkit_order_items
SET quantity = NULL
WHERE quantity < 0;

UPDATE blinkit_order_items
SET unit_price = NULL
WHERE unit_price < 0;

-- 3. Add a derived column: total_price = quantity × unit_price
ALTER TABLE blinkit_order_items
ADD COLUMN total_price DECIMAL;

-- 4. Update total_price values
UPDATE blinkit_order_items
SET total_price = quantity * unit_price
WHERE quantity IS NOT NULL AND unit_price IS NOT NULL;

--blinkit_custommer_feedback
-- 1. Trim all string fields
UPDATE blinkit_customer_feedback
SET 
    order_id = TRIM(order_id),
    customer_id = TRIM(customer_id),
    feedback_text = TRIM(feedback_text);

-- 2. Handle invalid ratings (e.g., out of expected 1–5 range)
UPDATE blinkit_customer_feedback
SET rating = NULL
WHERE rating < 1 OR rating > 5;

-- 3. Remove duplicate feedbacks (if same customer reviewed same product multiple times)
DELETE FROM blinkit_customer_feedback
WHERE feedback_id NOT IN (
    SELECT MIN(feedback_id)
    FROM blinkit_customer_feedback
    GROUP BY customer_id
);

-- 4. Handle any invalid or blank dates
-- This will only work if there are actual empty strings (may happen in CSV import)
-- Otherwise you can skip this step if dates are okay
-- UPDATE blinkit_customer_feedback
-- SET feedback_date = NULL
-- WHERE feedback_date = '';

-- 5. Optional: Categorize feedback (positive, neutral, negative)
-- Add a new column for feedback sentiment category
ALTER TABLE blinkit_customer_feedback
ADD COLUMN feedback_category VARCHAR;

-- 6. Simple sentiment logic based on rating
UPDATE blinkit_customer_feedback
SET feedback_category = CASE
    WHEN rating >= 4 THEN 'Positive'
    WHEN rating = 3 THEN 'Neutral'
    WHEN rating <= 2 THEN 'Negative'
    ELSE NULL
END;

--delivery_performaces
-- 1. Trim extra spaces
UPDATE delivery_performances
SET
    delivery_partner_id = TRIM(delivery_partner_id),
    delivery_status = TRIM(delivery_status),
    reason_if_delayed = TRIM(reason_if_delayed);

-- 2. Replace blanks in reason_if_delayed with NULL
UPDATE delivery_performances
SET reason_if_delayed = NULL
WHERE reason_if_delayed = '';

-- 3. Optional: Categorize delay status (if not already clean)
-- For example, mark status as 'On Time' if delivery_time_minutes <= 30
UPDATE delivery_performances
SET delivery_status = CASE
    WHEN delivery_time_minutes <= 30 THEN 'On Time'
    WHEN delivery_time_minutes > 30 THEN 'Delayed'
    ELSE delivery_status
END
WHERE delivery_status IS NULL OR delivery_status = '';
