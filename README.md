# BLINKIT DeCoded -A SQL DATA ANALYTICS CASE STUDY
![image alt](https://github.com/SirSahilSingh/blinkit-sql-data-analysis/blob/d8c9b8645c0da529ccd5f3e64d747d2e2eb78640/images/blinkit%20banner.png)  
Inspired by Blinkit’s rapid delivery ecosystem, this project presents a comprehensive SQL-based analytical workflow designed to replicate and analyze a hyperlocal grocery delivery platform. It begins with transforming raw CSV files into a well-structured PostgreSQL database, covering aspects such as customer behavior, order trends, delivery performance, inventory management, marketing effectiveness, and feedback analysis. The goal is to derive meaningful insights through robust schema design, data cleaning, and a foundation for exploratory data analysis.

## 🏢 Business Context

Blinkit is a hyperlocal quick-commerce delivery service that promises groceries and essentials delivered in under 10 minutes. Operating in a time-sensitive and competitive environment, Blinkit depends heavily on data to optimize delivery routes, understand customer behavior, minimize churn, and maximize operational efficiency.


## 📌 Problem Statement

Blinkit, a fast-paced quick-commerce delivery platform, handles massive amounts of customer, product, delivery, and marketing data daily. While operational metrics are constantly recorded, actionable insights are often hidden beneath this raw data.

The challenge is to transform scattered and siloed datasets into a centralized analytical model that can answer key business questions such as:

- Who are our most valuable customers?
- What delivery patterns indicate delays or churn risk?
- Which marketing campaigns actually drive conversions?
- Which product categories experience high damage or return rates?
- How do customer behaviors evolve over time?

---

## 🎯 Objectives

This project aims to simulate an end-to-end SQL data analysis pipeline, replicating how real-world analysts build insights layers inside companies like Blinkit.

-  **Data Integration**: Import, structure, and normalize multiple Blinkit-related CSV datasets into PostgreSQL.
-  **Data Cleaning**: Handle date formats, nulls, phone inconsistencies, and mismatched keys to prepare the data for analysis.
-  **EDA & Business Analysis**: Write SQL queries to uncover customer trends, delivery performance, feedback patterns, and segment-level behaviors.
-  **Analytical Views**: Build reusable SQL views for key metrics such as RFM analysis, churn status, and cohort trends.
-  **Visualization Readiness**: Prepare a structured database layer that supports dashboarding in BI tools (Power BI/Tableau).
-  **Documentation**: Deliver clean, modular SQL scripts with full documentation, schema diagrams, and GitHub-level presentation.

## 🗝️ Key Business Questions Answered

- Which customer segments generate the most revenue?
- What is the average delivery delay by city or area?
- Are repeat customers more likely to leave better feedback?
- How effective are Blinkit's marketing campaigns by channel?
- What is the customer churn rate and how can we reduce it?

## 🧱 Database Schema & ERD

The Blinkit SQL database is designed using a relational schema to reflect real-world operations in a hyperlocal quick-commerce platform. Below is an overview of the schema and relationships between core entities like customers, orders, deliveries, products, and marketing.

### 🗺️ Entity-Relationship Diagram (ERD)

![ERD](./diagrams/ERD_of_tables.png)

> 📌 *Note: The ERD shows primary keys, foreign key relationships, and one-to-many connections between all major entities.*


### 📘 Key Tables Overview

| Table | Description |
|-------|-------------|
| `blinkit_customers` | Stores customer profile, segment, registration, and location data |
| `blinkit_orders` | Core order data including timestamps, delivery status, and payment method |
| `blinkit_order_items` | Order-level breakdown of products and quantities purchased |
| `blinkit_products` | Product catalog with pricing and category details |
| `blinkit_inventory` | Tracks stock received and damaged across time |
| `blinkit_marketing_performance` | Campaign metrics like impressions, clicks, conversions, revenue |
| `blinkit_customer_feedback` | Customer feedback with text, rating, and feedback date |
| `delivery_performances` | Logs actual vs promised delivery times, distance, and delays |

> All tables are stored in a PostgreSQL database and linked via primary and foreign key constraints. Full schema definitions are available in [`/SQL/00_blinkit-schema.sql`](./SQL/00_blinkit-schema.sql).

## 🧼 Data Cleaning 

Raw data in CSV format often contains inconsistencies, nulls, and format issues. A major part of this project involved cleaning and preparing data for analysis using SQL in PostgreSQL.

### 🔧 Key Cleaning Steps Performed (DEMO)

### _1. blinkit_customers_

    -- 1. Check for missing values
    SELECT * FROM blinkit_customers
    WHERE customer_name IS NULL OR email IS NULL OR phone IS NULL;

    -- 2. Fix date format issues (if needed) - checked via Excel and PostgreSQL
    SELECT registration_date FROM blinkit_customers LIMIT 5;

    -- 3. Check for duplicate customers
    SELECT customer_id, COUNT(*) 
    FROM blinkit_customers
    GROUP BY customer_id
    HAVING COUNT(*) > 1;

    -- 4. Fix phone number formatting
    SELECT customer_id, phone, REPLACE(phone, '9.1', '+91') AS new_phone
    FROM blinkit_customers
    WHERE phone LIKE '%9.1%';

    -- 5. Normalize customer segment names
    SELECT DISTINCT customer_segment FROM blinkit_customers;
    -- UPDATE if inconsistent casing or spelling exists

### _2. blinkit_orders_

    -- 1. Find orders missing delivery times
    SELECT * FROM blinkit_orders
    WHERE promised_delivery_time IS NULL OR actual_delivery_time IS NULL;

    -- 2. Calculate delivery delay (in minutes)
    ALTER TABLE blinkit_orders ADD COLUMN delivery_delay_mins INT;

    UPDATE blinkit_orders
    SET delivery_delay_mins = EXTRACT(EPOCH FROM (actual_delivery_time - promised_delivery_time)) / 60;

    -- 3. Investigate negative delays (should not occur)
    SELECT * FROM blinkit_orders WHERE delivery_delay_mins < 0;

🧼 Full SQL cleaning scripts are available in [`SQL/01_data_cleaning.sql`](./SQL/01_data_cleaning.sql)
