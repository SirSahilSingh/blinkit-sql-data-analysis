-- Number of records in each table
SELECT 'blinkit_customers' AS table_name, COUNT(*) FROM blinkit_customers
UNION ALL
SELECT 'blinkit_orders', COUNT(*) FROM blinkit_orders
UNION ALL
SELECT 'blinkit_order_items', COUNT(*) FROM blinkit_order_items
UNION ALL
SELECT 'blinkit_products', COUNT(*) FROM blinkit_products
UNION ALL
SELECT 'blinkit_inventory', COUNT(*) FROM blinkit_inventory
UNION ALL
SELECT 'blinkit_customer_feedback', COUNT(*) FROM blinkit_customer_feedback
UNION ALL
SELECT 'blinkit_marketing_performance', COUNT(*) FROM blinkit_marketing_performance
UNION ALL
SELECT 'delivery_performances', COUNT(*) FROM delivery_performances;

-- Preview first 5 records from orders
SELECT * FROM blinkit_orders LIMIT 5;

-- Top 10 customers by total spending
SELECT customer_id, 
       COUNT(order_id) AS total_orders,
       SUM(order_total) AS total_spent
FROM blinkit_orders
GROUP BY customer_id
ORDER BY total_spent DESC
LIMIT 10;

-- Count of customers in each customer segment (e.g., New, Regular, Premium)
SELECT customer_segment, 
       COUNT(*) AS customer_count
FROM blinkit_customers
GROUP BY customer_segment
ORDER BY customer_count DESC;

-- Most frequently ordered products across all orders
SELECT p.product_name, 
       SUM(oi.quantity) AS total_quantity_ordered
FROM blinkit_order_items oi
JOIN blinkit_products p ON oi.product_id = p.product_id
GROUP BY p.product_name
ORDER BY total_quantity_ordered DESC
LIMIT 10;

-- Daily average order value to observe trends or drops
SELECT DATE(order_date) AS order_day,
       ROUND(AVG(order_total), 2) AS avg_order_value
FROM blinkit_orders
GROUP BY DATE(order_date)
ORDER BY order_day;

-- Number of on-time vs delayed deliveries
SELECT delivery_status, 
       COUNT(*) AS total_deliveries
FROM delivery_performances
GROUP BY delivery_status;

-- Common reasons for delayed deliveries
SELECT reason_if_delayed, 
       COUNT(*) AS delay_count
FROM delivery_performances
WHERE delivery_status = 'Delayed'
GROUP BY reason_if_delayed
ORDER BY delay_count DESC;

-- Average delivery time by partner
SELECT delivery_partner_id, 
       AVG(delivery_time_minutes) AS avg_delivery_time
FROM delivery_performances
GROUP BY delivery_partner_id
ORDER BY avg_delivery_time DESC;

-- Compare campaigns based on revenue, conversions, and clicks
SELECT campaign_name, 
       revenue_generated, 
       conversions, 
       clicks, 
       impressions
FROM blinkit_marketing_performance
ORDER BY revenue_generated DESC;

-- Click-through rate (CTR) and conversion rate by campaign
SELECT campaign_name,
       ROUND((clicks * 100.0) / impressions, 2) AS click_through_rate_pct,
       ROUND((conversions * 100.0) / clicks, 2) AS conversion_rate_pct
FROM blinkit_marketing_performance
WHERE impressions > 0 AND clicks > 0
ORDER BY conversion_rate_pct DESC;

-- Distribution of customer feedback ratings
SELECT rating, 
       COUNT(*) AS review_count
FROM blinkit_customer_feedback
GROUP BY rating
ORDER BY rating DESC;


