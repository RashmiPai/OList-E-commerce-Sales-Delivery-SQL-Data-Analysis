USE OList;

-- Case Study 1: Top 5 Most Sold Products (by quantity)
-- → Finds the top 5 products sold in the highest quantity across all orders.
SELECT 
    p.product_id,
    p.product_category_name,
    t.product_category_name_english,
    COUNT(*) AS total_quantity_sold
FROM 
    olist_order_items AS oi
JOIN 
    olist_products AS p ON oi.product_id = p.product_id
LEFT JOIN 
    product_category_name_translation AS t 
    ON p.product_category_name = t.product_category_name
GROUP BY 
    p.product_id, p.product_category_name, t.product_category_name_english
ORDER BY 
    total_quantity_sold DESC
LIMIT 5;

-- Case Study 2: Top 10 Sellers with Highest Revenue
-- → Finds the top 10 sellers who generated highest revenue 
SELECT 
    s.seller_id,
    s.seller_city,
    s.seller_state,
    COUNT(*) AS total_items_sold,
    ROUND(SUM(oi.price), 2) AS total_revenue
FROM 
    olist_order_items AS oi
JOIN 
    olist_sellers AS s ON oi.seller_id = s.seller_id
GROUP BY 
    s.seller_id, s.seller_city, s.seller_state
ORDER BY 
    total_revenue DESC
LIMIT 10;

-- Case Study 3a: Most Active Zip Code Prefixes (Customer)
-- → Identifies zip code regions with the highest number of unique customers.
SELECT 
    c.customer_zip_code_prefix,
    COUNT(DISTINCT c.customer_id) AS active_customers
FROM 
    olist_customers AS c
GROUP BY 
    c.customer_zip_code_prefix
ORDER BY 
    active_customers DESC
LIMIT 5;

-- Case Study 3b: Most Active Zip Code Prefixes (Seller)
-- → Identifies zip code regions with the highest number of active sellers.
SELECT 
    s.seller_zip_code_prefix,
    COUNT(DISTINCT s.seller_id) AS active_sellers
FROM 
    olist_sellers AS s
GROUP BY 
    s.seller_zip_code_prefix
ORDER BY 
    active_sellers DESC
LIMIT 5;

-- Case Study 4: Monthly Sales Trend
-- → Tracks the total number of orders placed each month to observe sales trends over time.
SELECT 
	DATE_FORMAT(o.order_purchase_timestamp, '%Y-%m-01') AS month,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM 
    olist_orders AS o
GROUP BY 
    month
ORDER BY 
    month;

-- Case Study 5: Average Review Score by Product
-- → Computes the average customer review score received per product.
SELECT 
    oi.product_id,
    op.product_category_name,
    ROUND(AVG(r.review_score), 2) AS avg_review_score
FROM 
    olist_order_items AS oi
JOIN 
    olist_order_reviews AS r ON oi.order_id = r.order_id
JOIN
	olist_products AS op ON oi.product_id = op.product_id
GROUP BY 
    oi.product_id
ORDER BY 
    avg_review_score DESC
LIMIT 10;

-- Case Study 6: Time from Order to Delivery
-- → Measures how long it took each order to be delivered from purchase date.
SELECT 
    order_id,
    order_purchase_timestamp,
    order_delivered_customer_date,
    (order_delivered_customer_date - order_purchase_timestamp) AS delivery_days
FROM 
    olist_orders
WHERE 
    order_status = 'delivered'
ORDER BY 
    delivery_days DESC
LIMIT 10;

-- Case Study 7: Rank Sellers by Sales Using Window Functions
-- → Ranks sellers by total revenue using a window function for comparative analysis.
SELECT 
    seller_id,
    SUM(price + freight_value) AS revenue,
    RANK() OVER (ORDER BY SUM(price + freight_value) DESC) AS seller_rank
FROM 
    olist_order_items
GROUP BY 
    seller_id
LIMIT 10;

-- Case Study 8: Payment Method Usage Analysis
-- → Shows the usage frequency and total value of each payment method type.
SELECT 
    payment_type,
    COUNT(*) AS total_transactions,
    SUM(payment_value) AS total_payment
FROM 
    olist_order_payments
GROUP BY 
    payment_type
ORDER BY 
    total_payment DESC;

-- Case Study 9: Find Orders with Multiple Sellers
-- → Lists orders that included items from more than one seller, indicating cross-seller purchases.
SELECT 
    order_id,
    COUNT(DISTINCT seller_id) AS seller_count
FROM 
    olist_order_items
GROUP BY 
    order_id
HAVING 
    COUNT(DISTINCT seller_id) > 1
LIMIT 10;

-- Case Study 10: Customer Lifetime Value (CLV)
SELECT 
    c.customer_id,
    SUM(oi.price + oi.freight_value) AS lifetime_value
FROM 
    olist_orders o
JOIN 
    olist_customers c ON o.customer_id = c.customer_id
JOIN 
    olist_order_items oi ON o.order_id = oi.order_id
GROUP BY 
    c.customer_id
ORDER BY 
    lifetime_value DESC
LIMIT 10;

-- Case Study 11: Percentage of Orders Delivered Late
-- → Calculates what percentage of delivered orders arrived after the estimated delivery date.
SELECT 
    100.0 * SUM(CASE 
                  WHEN order_delivered_customer_date > order_estimated_delivery_date 
                  THEN 1 
                  ELSE 0 
               END) / COUNT(*) AS percent_late_deliveries
FROM 
    olist_orders
WHERE 
    order_status = 'delivered';

-- Case Study 12: Identify Customers with Repeat Purchases
-- → Identifies customers who placed more than one unique order.
SELECT 
    customer_id,
    COUNT(DISTINCT order_id) AS total_orders
FROM 
    olist_orders
GROUP BY 
    customer_id
HAVING 
    total_orders > 1
ORDER BY 
    total_orders DESC;

-- Case Study 13: Average Time Between Orders per Customer (Window Function + LAG)
SELECT 
    customer_id,
    order_id,
    order_purchase_timestamp,
    LAG(order_purchase_timestamp) OVER (PARTITION BY customer_id ORDER BY order_purchase_timestamp) AS previous_order_time,
    order_purchase_timestamp - LAG(order_purchase_timestamp) OVER (PARTITION BY customer_id ORDER BY order_purchase_timestamp) 
		AS time_between_orders
FROM 
    olist_orders;
    
-- Case Study 14: Orders Without Any Review
SELECT 
    o.order_id
FROM 
    olist_orders o
LEFT JOIN 
    olist_order_reviews r ON o.order_id = r.order_id
WHERE 
    r.review_id IS NULL;
