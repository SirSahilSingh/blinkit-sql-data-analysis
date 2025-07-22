-- 🔁 RFM ANALYSIS
-- Recency, Frequency, Monetary value per customer
SELECT
  c.customer_id,
  MAX(o.order_date) AS last_order_date,
  COUNT(o.order_id) AS frequency,
  SUM(o.order_total) AS monetary_value,
  CURRENT_DATE - MAX(o.order_date) AS recency_days
FROM blinkit_customers c
JOIN blinkit_orders o ON c.customer_id = o.customer_id
GROUP BY c.customer_id;

-- 📊 COHORT ANALYSIS
-- Tracks how long customers continue to place orders after joining
WITH cohorts AS (
  SELECT 
    customer_id,
    DATE_TRUNC('month', registration_date) AS cohort_month
  FROM blinkit_customers
),
orders_by_month AS (
  SELECT 
    customer_id,
    DATE_TRUNC('month', order_date) AS order_month
  FROM blinkit_orders
),
cohort_data AS (
  SELECT 
    c.cohort_month,
    o.order_month,
    EXTRACT(MONTH FROM AGE(o.order_month, c.cohort_month)) AS months_since_signup,
    COUNT(DISTINCT o.customer_id) AS active_customers
  FROM cohorts c
  JOIN orders_by_month o ON c.customer_id = o.customer_id
  GROUP BY c.cohort_month, o.order_month, months_since_signup
)
SELECT * FROM cohort_data
ORDER BY cohort_month, months_since_signup;

-- 💰 CUSTOMER LIFETIME VALUE (CLV)
-- Estimate lifetime revenue and order patterns for each customer
SELECT 
  customer_id,
  COUNT(order_id) AS total_orders,
  SUM(order_total) AS total_revenue,
  ROUND(AVG(order_total), 2) AS avg_order_value,
  DATE_PART('day', MAX(order_date) - MIN(order_date)) AS lifespan_days,
  ROUND(SUM(order_total) / (DATE_PART('day', MAX(order_date) - MIN(order_date)) + 1), 2) AS daily_clv
FROM blinkit_orders
GROUP BY customer_id
ORDER BY total_revenue DESC;

-- 📉 CHURN DETECTION
-- Flag customers who haven't placed an order in over 90 days
SELECT 
  customer_id,
  MAX(order_date) AS last_order,
  CURRENT_DATE - MAX(order_date) AS days_since_last_order,
  CASE 
    WHEN CURRENT_DATE - MAX(order_date) > 90 THEN 'Churned'
    ELSE 'Active'
  END AS status
FROM blinkit_orders
GROUP BY customer_id
ORDER BY days_since_last_order DESC;

-- 🧠 BEHAVIORAL SEGMENTATION
-- Combine orders, feedback, and customer segments
SELECT 
  c.customer_id,
  c.customer_segment,
  COUNT(o.order_id) AS total_orders,
  SUM(o.order_total) AS revenue,
  ROUND(AVG(f.rating), 2) AS avg_rating,
  pm.payment_method
FROM blinkit_customers c
JOIN blinkit_orders o ON c.customer_id = o.customer_id
LEFT JOIN blinkit_customer_feedback f ON c.customer_id = f.customer_id
LEFT JOIN (
  SELECT DISTINCT order_id, payment_method FROM blinkit_orders
) pm ON o.order_id = pm.order_id
GROUP BY c.customer_id, c.customer_segment, pm.payment_method;
