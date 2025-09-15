-- PROBLEM STATEMENT : Analyze Olist marketplace orders from 2016 to 2018 to identify seller-to-state delivery routes
-- where delays have the biggest negative impact on customer reviews and revenue. Based on these insights, propose targeted
-- logistics improvements that can boost the overall on-time delivery rate by at least 5% and increase the average customer 
-- review score by 0.2 points

-- Step 1: Understand the structure and nature of the data
-- Step 2: Data Analysis
-- 		 Step 2a: Calculating basic statistics 
--       Step 2b: Finding Null values and handling them
--       Step 2c: Using Group by to aggregate data and finding insights
--       Step 2d: Using joins, Subqueries and CTE's to extract meaningful insights
--       Step 2e: Using Window Functions to perform calculations
-- Step 3: Creating Views for better understanding of the desired KPI's
-- Step 4: Insights and Next Steps


-- CREATE DATABASE sql_project;
USE sql_project;

-- 1. Understanding the structure of the dataset

-- View all tables in the schema
SHOW TABLES;

-- Get table descriptions
DESCRIBE olist_customers_dataset;
DESCRIBE olist_geolocation;
DESCRIBE olist_order_items;
DESCRIBE olist_order_payments;
DESCRIBE olist_order_reviews;
DESCRIBE olist_orders;
DESCRIBE olist_products;
DESCRIBE olist_sellers;
DESCRIBE product_category_name_translation;

-- Checking how many rows we have in the current dataset
SELECT 'olist_orders' AS table_name, COUNT(*) AS row_count FROM olist_orders
UNION ALL
SELECT 'olist_customers_dataset', COUNT(*) FROM olist_customers_dataset
UNION ALL
SELECT 'olist_order_items', COUNT(*) FROM olist_order_items
UNION ALL
SELECT 'olist_order_payments', COUNT(*) FROM olist_order_payments
UNION ALL
SELECT 'olist_order_reviews', COUNT(*) FROM olist_order_reviews
UNION ALL
SELECT 'olist_products', COUNT(*) FROM olist_products
UNION ALL
SELECT 'olist_sellers', COUNT(*) FROM olist_sellers
UNION ALL
SELECT 'olist_geolocation', COUNT(*) FROM olist_geolocation
UNION ALL
SELECT 'product_category_name_translation', COUNT(*) FROM product_category_name_translation;

-- Earlist and latest Date Ranges (for time series context)
SELECT 
  MIN(order_purchase_timestamp) AS min_purchase,
  MAX(order_purchase_timestamp) AS max_purchase
FROM olist_orders;

-- Looking at first few rows of the data
SELECT * FROM olist_orders LIMIT 5;
SELECT * FROM olist_customers_dataset LIMIT 5;
SELECT * FROM olist_order_items LIMIT 5;
SELECT * FROM olist_order_payments LIMIT 5;
SELECT * FROM olist_order_reviews LIMIT 5;
SELECT * FROM olist_products LIMIT 5;
SELECT * FROM olist_sellers LIMIT 5;
SELECT * FROM olist_geolocation LIMIT 5;
SELECT * FROM product_category_name_translation LIMIT 5;

-- Summarize data types and nullable values for some tables
SELECT
  COLUMN_NAME,
  DATA_TYPE,
  IS_NULLABLE,
  CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'olist_orders';

SELECT
  COLUMN_NAME,
  DATA_TYPE,
  IS_NULLABLE,
  CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'olist_products';

SELECT
  COLUMN_NAME,
  DATA_TYPE,
  IS_NULLABLE,
  CHARACTER_MAXIMUM_LENGTH
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'olist_customers_dataset';

-- Step 2: Data Analysis 
-- Step 2a: Calculating basic statistics

-- Distinct values 
SELECT COUNT(DISTINCT customer_id) FROM olist_customers_dataset; -- number of distinct customers
SELECT COUNT(DISTINCT product_category_name) FROM olist_products; -- number of products - 74
SELECT DISTINCT customer_state FROM olist_customers_dataset ORDER BY customer_state; -- 27 states where customer reside
SELECT DISTINCT payment_type FROM olist_order_payments ORDER BY payment_type; -- 5 different types of paymentts

-- Checking distributions (Min, Max, Avg) in price
SELECT
  MIN(price) AS min_price,
  MAX(price) AS max_price,
  AVG(price) AS avg_price
FROM olist_order_items;

-- Finding possible outliers in item_pricing
SELECT product_id, price
FROM olist_order_items
WHERE price > (SELECT AVG(price) + 3 * STD(price) FROM olist_order_items);
-- Comments: out of 32951 distinct products 1966 fall outside 3 standard deviation in the dataset signelling possible outliers

SELECT count(DISTINCT (product_id)) FROM olist_order_items; -- Distinct product_id's 32951

-- Category frequencies 
SELECT product_category_name, COUNT(*) AS cnt
FROM olist_products
GROUP BY product_category_name
ORDER BY cnt DESC;
-- Comments: 74 categories Cama_mesa_banho being top seller with 3029 sales and cds_dvds_musicais being the least sold item

SELECT payment_type, COUNT(*) FROM olist_order_payments GROUP BY payment_type;
-- Comments: mostly used payment method Credit card 76K while debit card is being least used 1.5k and 3 transactions are not defined.

-- Checking the seasonality of the dataset
SELECT
  YEAR(order_purchase_timestamp) AS year,
  MONTH(order_purchase_timestamp) AS month,
  COUNT(*) AS order_count
FROM olist_orders
GROUP BY year, month
ORDER BY year, month;

-- listing the states and their order counts
SELECT customer_state, COUNT(*) AS orders
FROM olist_customers_dataset
GROUP BY customer_state
ORDER BY orders DESC;

-- Top 10 cities by customer city
SELECT customer_city, COUNT(*) AS customers
FROM olist_customers_dataset
GROUP BY customer_city
ORDER BY customers DESC
LIMIT 10;

-- Step 2b: Finding Null values and handling them

SELECT
  COUNT(*) AS total_rows,
  SUM(order_approved_at IS NULL) AS null_approved,
  SUM(order_delivered_carrier_date IS NULL) AS null_delivered_carrier,
  SUM(order_delivered_customer_date IS NULL) AS null_delivered_customer,
  SUM(order_estimated_delivery_date IS NULL) AS null_estimated_delivery
FROM olist_orders;

SELECT
  COUNT(*) AS total_rows,
  SUM(review_score IS NULL) AS null_review_score,
  SUM(review_comment_title IS NULL) AS null_comment_title,
  SUM(review_comment_message IS NULL) AS null_comment_msg,
  SUM(review_creation_date IS NULL) AS null_creation_date,
  SUM(review_answer_timestamp IS NULL) AS null_answer_timestamp
FROM olist_order_reviews;

SELECT
  COUNT(*) AS total_rows,
  SUM(payment_sequential IS NULL) AS null_payment_seq,
  SUM(payment_type IS NULL) AS null_payment_type,
  SUM(payment_installments IS NULL) AS null_installments,
  SUM(payment_value IS NULL) AS null_payment_value
FROM olist_order_payments;

SELECT
  COUNT(*) AS total_rows,
  SUM(order_id IS NULL) AS null_order_id,
  SUM(order_item_id IS NULL) AS null_order_item_id,
  SUM(product_id IS NULL) AS null_product_id,
  SUM(seller_id IS NULL) AS null_seller_id,
  SUM(shipping_limit_date IS NULL) AS null_shipping_limit,
  SUM(price IS NULL) AS null_price,
  SUM(freight_value IS NULL) AS null_freight
FROM olist_order_items;

SELECT
  COUNT(*) AS total_rows,
  SUM(product_category_name IS NULL) AS null_category,
  SUM(product_name_lenght IS NULL) AS null_name_length,
  SUM(product_description_lenght IS NULL) AS null_description_length,
  SUM(product_photos_qty IS NULL) AS null_photos_qty,
  SUM(product_weight_g IS NULL) AS null_weight,
  SUM(product_length_cm IS NULL) AS null_length,
  SUM(product_height_cm IS NULL) AS null_height,
  SUM(product_width_cm IS NULL) AS null_width
FROM olist_products;

SELECT
  COUNT(*) AS total_rows,
  SUM(customer_unique_id IS NULL) AS null_unique_id,
  SUM(customer_zip_code_prefix IS NULL) AS null_zip_prefix,
  SUM(customer_city IS NULL) AS null_city,
  SUM(customer_state IS NULL) AS null_state
FROM olist_customers_dataset;

SELECT
  COUNT(*) AS total_rows,
  SUM(seller_zip_code_prefix IS NULL) AS null_zip_prefix,
  SUM(seller_city IS NULL) AS null_city,
  SUM(seller_state IS NULL) AS null_state
FROM olist_sellers;

SELECT
  COUNT(*) AS total_rows,
  SUM(geolocation_zip_code_prefix IS NULL) AS null_zip_prefix,
  SUM(geolocation_lat IS NULL) AS null_lat,
  SUM(geolocation_lng IS NULL) AS null_lng,
  SUM(geolocation_city IS NULL) AS null_city,
  SUM(geolocation_state IS NULL) AS null_state
FROM olist_geolocation;

SELECT
  COUNT(*) AS total_rows,
  SUM(product_category_name IS NULL) AS null_category_pt,
  SUM(product_category_name_english IS NULL) AS null_category_en
FROM product_category_name_translation;

-- Since no null values are found moving towards next step

-- Step 2c: Using Group by to aggregate data and finding insights
-- Objective of this step is to extract meaningfull insights by grouping the dataset by different dimensions using the Group by clause

-- 1. Orders Per Customer state
SELECT 
  c.customer_state,
  COUNT(o.order_id) AS total_orders
FROM olist_orders o
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
GROUP BY c.customer_state
ORDER BY total_orders DESC;
-- SP, RJ, MG customers have the highest orders, SP having orders more than 41.5K out of 99.4k orders.

-- 2. Average Review Score per Order Status
SELECT 
  o.order_status,
  AVG(r.review_score) AS avg_review_score,
  COUNT(r.review_id) AS total_reviews
FROM olist_orders o
JOIN olist_order_reviews r ON o.order_id = r.order_id
GROUP BY o.order_status
ORDER BY avg_review_score DESC;
-- out of 99.4K orders 95.6K delivered and it has avg_score of 4.15, also need to look at 1k orderes which are only shipped 

-- 3.Total Revenue by Product Category (Top 10 selling product categories)
SELECT 
  p.product_category_name,
  ROUND(SUM(oi.price), 2) AS total_sales
FROM olist_order_items oi
JOIN olist_products p ON oi.product_id = p.product_id
GROUP BY p.product_category_name
ORDER BY total_sales DESC
LIMIT 10;
-- 'beleza_saude', 'relogios_presentes', 'cama_mesa_banho' have the higgest sales at more than 1M.

-- 4. Most Common Payment Methods
SELECT 
  payment_type,
  COUNT(*) AS num_payments,
  ROUND(AVG(payment_value), 2) AS avg_payment
FROM olist_order_payments
GROUP BY payment_type
ORDER BY num_payments DESC;
-- Credit card being the mostly used payment option, also there is a big gap between 1st and 2nd payment option
-- Boleto is a popular payment method in brazil, functioning as a vocher-based system that allows for cash or onlinepayments for goods and services,
-- not need for banck account for this payment type.

-- 5. Top-Performing Sellers by Revenue
SELECT 
  oi.seller_id,
  ROUND(SUM(oi.price), 2) AS total_revenue,
  COUNT(DISTINCT oi.order_id) AS total_orders
FROM olist_order_items oi
GROUP BY oi.seller_id
ORDER BY total_revenue DESC
LIMIT 10;

-- Step 2d: Using joins, Subqueries and CTE's to extract meaningful insights

-- 1. Orders and Average Review Score by Seller and Customer State (Route-level Insight)
 SELECT
  oi.seller_id,
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS total_orders,
  AVG(r.review_score) AS avg_review_score,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days
FROM olist_order_items oi
JOIN olist_orders o ON oi.order_id = o.order_id
JOIN olist_order_reviews r ON o.order_id = r.order_id
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
GROUP BY oi.seller_id, c.customer_state
ORDER BY avg_delivery_days DESC, avg_review_score ASC, total_orders DESC
LIMIT 20;
-- This will give the combinations of seller and customer state combinations which have poor review score with longer delivery times.alter

-- 2. Total Revenue by Seller and Customer State
SELECT
  oi.seller_id,
  c.customer_state,
  ROUND(SUM(oi.price),2) AS total_revenue,
  COUNT(DISTINCT o.order_id) AS total_orders
FROM olist_order_items oi
JOIN olist_orders o ON oi.order_id = o.order_id
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
GROUP BY oi.seller_id, c.customer_state
ORDER BY total_revenue DESC
LIMIT 10;
-- SP state is having the highest orders with maximum revenue 
-- we should focus on prioritizing operational improvements in SP since it is having highest revenue routes.alter

-- 3. Average Delivery Delay Impact on Review Scores (Route Segmentation)
SELECT
  c.customer_state,
  oi.seller_id,
  AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)) AS avg_delivery_delay,
  AVG(r.review_score) AS avg_review_score
FROM olist_orders o
JOIN olist_order_items oi ON o.order_id = oi.order_id
JOIN olist_order_reviews r ON o.order_id = r.order_id
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
GROUP BY c.customer_state, oi.seller_id
HAVING avg_delivery_delay > 0
ORDER BY avg_delivery_delay DESC, avg_review_score ASC
LIMIT 10;
-- the above query isolates routes with late deliveries and assesses how review scores are affected. 

-- 4. Find Top 10 Sellers with Average Delivery Delay, Review Score, total sales, and Delivered State
SELECT
  oi.seller_id,
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)), 2) AS avg_delivery_delay,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(SUM(oi.price), 2) AS total_sales
FROM olist_order_items oi
JOIN olist_orders o ON oi.order_id = o.order_id
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id, c.customer_state
ORDER BY total_orders DESC
LIMIT 10;
-- need to look at improving the functionality of this sellers the top 2 sellers have highest orders and but average review is not looking grate.

-- 5. finding the bottom 10 sellers 
SELECT
  oi.seller_id,
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)), 2) AS avg_delivery_days,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)), 2) AS avg_delivery_delay,
  ROUND(AVG(r.review_score), 2) AS avg_review_score,
  ROUND(SUM(oi.price), 2) AS total_sales
FROM olist_order_items oi
JOIN olist_orders o ON oi.order_id = o.order_id
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id, c.customer_state
ORDER BY avg_delivery_delay DESC, avg_review_score ASC
LIMIT 10;
-- this query is giving the bottom sellers with high delays and lowest average review score but the total orders they have very less.
-- we need to find the proper sellers who have less orders than the average orders. 
-- If we are improving the customer experience we need to look at improving the connection between the sellers and customers we can't take sellers who have sold only once in 2 years.
-- to do that we need CTE's and subqueries

-- first calculating the average number of orders per seller (across all states)
SELECT AVG(order_count) AS avg_orders_per_seller
FROM (
    SELECT oi.seller_id, COUNT(DISTINCT o.order_id) AS order_count
    FROM olist_order_items oi
    JOIN olist_orders o ON oi.order_id = o.order_id
    GROUP BY oi.seller_id
) AS seller_orders;

-- Second Find bottom sellers whose total orders are just below this average (e.g., within ±10% below the average),
-- and report their delivery delays, review score, sales, and total orders.
WITH seller_order_counts AS (
    SELECT 
        oi.seller_id,
        COUNT(DISTINCT o.order_id) AS total_orders
    FROM olist_order_items oi
    JOIN olist_orders o ON oi.order_id = o.order_id
    GROUP BY oi.seller_id
),
avg_orders AS (
    SELECT AVG(total_orders) AS avg_orders FROM seller_order_counts
),
seller_metrics AS (
    SELECT 
        oi.seller_id,
        AVG(r.review_score) AS avg_review_score,
        MAX(DATEDIFF(o.order_delivered_customer_date, o.order_purchase_timestamp)) AS max_delivery_delay
    FROM olist_order_items oi
    JOIN olist_orders o ON oi.order_id = o.order_id
    LEFT JOIN olist_order_reviews r ON o.order_id = r.order_id
    WHERE o.order_delivered_customer_date IS NOT NULL
    GROUP BY oi.seller_id
)

SELECT 
    soc.seller_id,
    soc.total_orders,
    sm.avg_review_score,
    sm.max_delivery_delay
FROM seller_order_counts soc
JOIN avg_orders ao ON 1=1
JOIN seller_metrics sm ON soc.seller_id = sm.seller_id
WHERE soc.total_orders > ao.avg_orders
ORDER BY sm.max_delivery_delay DESC, sm.avg_review_score ASC
LIMIT 10;
-- now these are the sellers we should be prioritizing in improving the quality beacuse they have
-- 1. good enough total orders to worry about alter
-- 2. moderate to high reeview score
-- 3. highest delays

-- Question 1. Which sellers have a delivery delay greater than the average delay across the entire marketplace, and what are their average review scores?
-- to find the relationship between delays and review score
WITH global_avg_delay AS (
  SELECT AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)) AS avg_delay
  FROM olist_orders o
  WHERE o.order_delivered_customer_date IS NOT NULL
),
seller_avg_delays AS (
  SELECT
    oi.seller_id,
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)) AS avg_delivery_delay,
    AVG(r.review_score) AS avg_review_score
  FROM olist_order_items oi
  JOIN olist_orders o ON oi.order_id = o.order_id
  JOIN olist_order_reviews r ON o.order_id = r.order_id
  WHERE o.order_delivered_customer_date IS NOT NULL
  GROUP BY oi.seller_id
)
SELECT seller_id, avg_delivery_delay, ROUND(avg_review_score, 2) AS avg_review_score
FROM seller_avg_delays
WHERE avg_delivery_delay > (SELECT avg_delay FROM global_avg_delay)
ORDER BY avg_delivery_delay DESC;

-- Question 2: For each state, which seller is responsible for the highest total sales, and what is that sales amount?
-- finding out the best sellers in each state
WITH sales_per_seller_state AS (
  SELECT
    oi.seller_id,
    c.customer_state,
    Round(SUM(oi.price),2) AS total_sales
  FROM olist_order_items oi
  JOIN olist_orders o ON oi.order_id = o.order_id
  JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
  GROUP BY oi.seller_id, c.customer_state
),
max_sales_per_state AS (
  SELECT
    customer_state,
    MAX(total_sales) AS max_sales
  FROM sales_per_seller_state
  GROUP BY customer_state
)
SELECT
  sps.seller_id, sps.customer_state, sps.total_sales
FROM sales_per_seller_state sps
JOIN max_sales_per_state msp ON sps.customer_state = msp.customer_state AND sps.total_sales = msp.max_sales
ORDER BY sps.total_sales DESC;

-- Question 3. Which orders had delivery delays larger than the average delay for their seller, and what were the corresponding review scores?
WITH seller_avg_delay AS (
  SELECT
    oi.seller_id,
    AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)) AS avg_delay
  FROM olist_order_items oi
  JOIN olist_orders o ON oi.order_id = o.order_id
  WHERE o.order_delivered_customer_date IS NOT NULL
  GROUP BY oi.seller_id
)
SELECT
  o.order_id,
  oi.seller_id,
  DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) AS delivery_delay,
  r.review_score
FROM olist_orders o
JOIN olist_order_items oi ON o.order_id = oi.order_id
JOIN olist_order_reviews r ON o.order_id = r.order_id
JOIN seller_avg_delay sad ON oi.seller_id = sad.seller_id
WHERE o.order_delivered_customer_date IS NOT NULL
  AND DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > sad.avg_delay
ORDER BY delivery_delay DESC;
-- finding out which orders are having or causing more damage to the review score and it clearly have a corelation with delivery delay
-- need to perform Root cause analysis on why these deliveries actually took such a long time to deliver and if there is anything can be done to improve the review score.alter

-- Step 2e. Using Window Functions to perform calculations

-- Question 4. List sellers who meet the following criterion: their average review score is below the overall average review score, but their total sales exceed the median sales among all sellers.
-- Step 1: Sales and Reviews by Seller
WITH seller_reviews_sales AS (
  SELECT
    oi.seller_id,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(SUM(oi.price), 2) AS total_sales
  FROM olist_order_items oi
  JOIN olist_order_reviews r ON oi.order_id = r.order_id
  GROUP BY oi.seller_id
),
-- Step 2: Add Row Numbers + Total Count to get Median rows
ranked_sales AS (
  SELECT
    *,
    ROW_NUMBER() OVER (ORDER BY total_sales) AS rn_asc,
    ROW_NUMBER() OVER (ORDER BY total_sales DESC) AS rn_desc,
    COUNT(*) OVER () AS total_rows
  FROM seller_reviews_sales
),
-- Step 3: Grab the median value(s)
median_rows AS (
  SELECT total_sales FROM ranked_sales
  WHERE
    rn_asc = FLOOR((total_rows + 1) / 2)  -- If odd
    OR (total_rows % 2 = 0 AND rn_asc IN (total_rows / 2, total_rows / 2 + 1))  -- If even
),
-- Step 4: Calculate median from selected row(s)
median_sales AS (
  SELECT ROUND(AVG(total_sales), 2) AS median_total_sales FROM median_rows
),
-- Step 5: Average review score of all sellers
overall_avg_review AS (
  SELECT AVG(avg_review_score) AS avg_review FROM seller_reviews_sales
)
-- Final Output
SELECT 
  srs.seller_id,
  srs.avg_review_score,
  srs.total_sales
FROM seller_reviews_sales srs
JOIN median_sales ms ON 1=1
JOIN overall_avg_review oar ON 1=1
WHERE srs.avg_review_score < oar.avg_review
  AND srs.total_sales > ms.median_total_sales
ORDER BY srs.avg_review_score ASC, total_sales DESC;
-- this will give us the set of sellers (548) to work with who has lower than average_reveiew score and more sales than medain sales

-- Question 5. For each seller, compute a ranking of their customers based on total purchase value, and list the top 3 customers per seller.
WITH customer_purchases AS (
  SELECT
    oi.seller_id,
    o.customer_id,
    SUM(oi.price) AS total_spent
  FROM olist_order_items oi
  JOIN olist_orders o ON oi.order_id = o.order_id
  GROUP BY oi.seller_id, o.customer_id
),
ranked_customers AS (
  SELECT
    seller_id,
    customer_id,
    total_spent,
    ROW_NUMBER() OVER (PARTITION BY seller_id ORDER BY total_spent DESC) AS ranks
  FROM customer_purchases
)
SELECT seller_id, customer_id, total_spent
FROM ranked_customers
WHERE ranks <= 3
ORDER BY seller_id, ranks;

-- Question 6. Top 10 Underperforming Seller–State Routes (High Delay, Low Reviews)
SELECT
  oi.seller_id,
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)), 2) AS avg_delay,
  ROUND(AVG(r.review_score), 2) AS avg_review,
  ROUND(SUM(oi.price), 2) AS total_sales
FROM olist_order_items oi
JOIN olist_orders o ON oi.order_id = o.order_id
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id, c.customer_state
HAVING avg_delay > 0
ORDER BY total_orders Desc, avg_delay DESC, avg_review ASC
LIMIT 10;
-- -- This query identifies the top 10 seller–state combinations with the longest average delivery delays and lowest average review scores.
-- It also calculates total orders and total sales to ensure these segments have significant business impact.
-- Interpretation: High avg_delay coupled with low avg_review indicates poor customer satisfaction likely driven by late deliveries.
-- Focused improvement on these routes could enhance customer retention and reduce revenue leakage.

-- Question 7. Sellers with Higher-than-Average Orders But Lower-than-Average Reviews
WITH seller_agg AS (
  SELECT
    oi.seller_id,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(r.review_score), 2) AS avg_review_score,
    ROUND(SUM(oi.price), 2) AS total_sales
  FROM olist_order_items oi
  JOIN olist_orders o ON oi.order_id = o.order_id
  JOIN olist_order_reviews r ON o.order_id = r.order_id
  WHERE o.order_delivered_customer_date IS NOT NULL
  GROUP BY oi.seller_id
),
avg_metrics AS (
  SELECT 
    AVG(total_orders) AS avg_orders,
    AVG(avg_review_score) AS avg_review
  FROM seller_agg
)
SELECT *
FROM seller_agg sa
JOIN avg_metrics am ON 1=1
WHERE sa.total_orders > am.avg_orders
  AND sa.avg_review_score < am.avg_review
ORDER BY avg_review_score ASC;
-- This query filters sellers whose number of orders exceed the average number of orders per seller, 
-- but whose average customer review scores fall below the overall average.
-- Interpretation: These sellers generate considerable revenue but struggle with customer satisfaction, 
-- which can signal underlying quality or service issues.
-- Targeting these sellers for operational improvements offers substantial ROI potential.


-- Question 8. % of Orders Delivered Late per Seller (Impact Metric)
SELECT
  oi.seller_id,
  COUNT(*) AS total_orders,
  SUM(CASE WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 THEN 1 ELSE 0 END) AS late_orders,
  ROUND(SUM(CASE WHEN DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date) > 0 THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS percent_late
FROM olist_order_items oi
JOIN olist_orders o ON oi.order_id = o.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id
ORDER BY total_orders DESC, percent_late DESC
LIMIT 10;
-- Computes the percentage of late deliveries per seller based on whether actual delivery date exceeded estimated delivery date.
-- Interpretation: Sellers with high percent_late may be major contributors to delivery-related customer dissatisfaction.
-- This metric can be tracked over time for SLA compliance and logistics optimizations.


-- Question 9. Seller–Customer-State Matrix with Total Metrics
SELECT
  oi.seller_id,
  c.customer_state,
  COUNT(*) AS total_orders,
  ROUND(SUM(oi.price), 2) AS total_sales,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)), 2) AS avg_delay,
  ROUND(AVG(r.review_score), 2) AS avg_review
FROM olist_order_items oi
JOIN olist_orders o ON oi.order_id = o.order_id
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id, c.customer_state
ORDER BY total_orders DESC;
-- Generates a comprehensive matrix with sales volume, delivery delays, order counts, and average review scores 
-- grouped by seller and delivery state.
-- Interpretation: Enables geographical and seller comparisons, identifying strong and weak delivery corridors.
-- Useful for creating heatmap visualizations and prioritizing optimization efforts by region.


-- Question 10. Seller Review Trend Over Time 
SELECT
  oi.seller_id,
  YEAR(o.order_purchase_timestamp) AS year,
  MONTH(o.order_purchase_timestamp) AS month,
  ROUND(AVG(r.review_score), 2) AS avg_monthly_score
FROM olist_order_items oi
JOIN olist_orders o ON oi.order_id = o.order_id
JOIN olist_order_reviews r ON o.order_id = r.order_id
GROUP BY oi.seller_id, year, month
ORDER BY seller_id, year, month;
-- Calculates average monthly review scores per seller, allowing trend analysis over time.
-- Interpretation: Identifies whether seller performance and customer satisfaction are improving or deteriorating.
-- Critical for measuring impact of interventions or seasonal patterns.

-- Step 3: Creating Views for better understanding of the desired KPI's

-- Creating a View for dashboard use which has all KPI's 
CREATE VIEW seller_state_performance AS
SELECT
  oi.seller_id,
  c.customer_state,
  COUNT(DISTINCT o.order_id) AS total_orders,
  ROUND(SUM(oi.price), 2) AS total_sales,
  ROUND(AVG(DATEDIFF(o.order_delivered_customer_date, o.order_estimated_delivery_date)), 2) AS avg_delivery_delay,
  ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM olist_order_items oi
JOIN olist_orders o ON oi.order_id = o.order_id
JOIN olist_customers_dataset c ON o.customer_id = c.customer_id
JOIN olist_order_reviews r ON o.order_id = r.order_id
WHERE o.order_delivered_customer_date IS NOT NULL
GROUP BY oi.seller_id, c.customer_state;

SELECT * FROM seller_state_performance;





















