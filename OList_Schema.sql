-- CREATE DATABASE OList;
USE OList;

CREATE TABLE olist_customers (
    customer_id VARCHAR(50) PRIMARY KEY,
    customer_unique_id VARCHAR(50),
    customer_zip_code_prefix INT,
    customer_city VARCHAR(100),
    customer_state VARCHAR(5)
);
SELECT COUNT(*) FROM olist_customers;
SELECT * FROM olist_customers LIMIT 1;

CREATE TABLE olist_geolocation (
    geolocation_zip_code_prefix INT,
    geolocation_lat FLOAT,
    geolocation_lng FLOAT,
    geolocation_city VARCHAR(100),
    geolocation_state VARCHAR(5)
);
SELECT COUNT(*) FROM olist_geolocation;
SELECT * FROM olist_geolocation LIMIT 1;

CREATE TABLE olist_order_items (
    order_id VARCHAR(50),
    order_item_id INT,
    product_id VARCHAR(50),
    seller_id VARCHAR(50),
    shipping_limit_date DATETIME,
    price FLOAT,
    freight_value FLOAT,
    PRIMARY KEY (order_id, order_item_id)
);
SELECT COUNT(*) FROM olist_order_items;
SELECT * FROM olist_order_items LIMIT 1;

CREATE TABLE olist_order_payments (
    order_id VARCHAR(50),
    payment_sequential INT,
    payment_type VARCHAR(50),
    payment_installments INT,
    payment_value FLOAT
);
SELECT COUNT(*) FROM olist_order_payments;
SELECT * FROM olist_order_payments LIMIT 1;

CREATE TABLE olist_order_reviews (
    review_id VARCHAR(50) PRIMARY KEY,
    order_id VARCHAR(50),
    review_score INT,
    review_comment_title TEXT,
    review_comment_message TEXT,
    review_creation_date DATETIME,
    review_answer_timestamp DATETIME
);
SELECT COUNT(*) FROM olist_order_reviews;
SELECT * FROM olist_order_reviews LIMIT 1;

CREATE TABLE olist_orders (
    order_id VARCHAR(50) PRIMARY KEY,
    customer_id VARCHAR(50),
    order_status VARCHAR(20),
    order_purchase_timestamp DATETIME,
    order_approved_at DATETIME,
    order_delivered_carrier_date DATETIME,
    order_delivered_customer_date DATETIME,
    order_estimated_delivery_date DATETIME
);
SELECT COUNT(*) FROM olist_orders;
SELECT * FROM olist_orders LIMIT 1;

CREATE TABLE olist_products (
    product_id VARCHAR(50) PRIMARY KEY,
    product_category_name VARCHAR(100),
    product_name_lenght INT,
    product_description_lenght INT,
    product_photos_qty INT,
    product_weight_g FLOAT,
    product_length_cm FLOAT,
    product_height_cm FLOAT,
    product_width_cm FLOAT
);
SELECT COUNT(*) FROM olist_products;
SELECT * FROM olist_products LIMIT 1;

CREATE TABLE olist_sellers (
    seller_id VARCHAR(50) PRIMARY KEY,
    seller_zip_code_prefix INT,
    seller_city VARCHAR(100),
    seller_state VARCHAR(5)
);
SELECT COUNT(*) FROM olist_sellers;
SELECT * FROM olist_sellers LIMIT 1;

CREATE TABLE product_category_name_translation (
	product_category_name VARCHAR(100),
    product_category_name_english VARCHAR(100)
);
SELECT COUNT(*) FROM product_category_name_translation;
SELECT * FROM product_category_name_translation LIMIT 1;

ALTER TABLE olist_orders
ADD CONSTRAINT fk_orders_customer
FOREIGN KEY (customer_id) REFERENCES olist_customers(customer_id);

ALTER TABLE olist_order_items
ADD CONSTRAINT fk_order_items_order
FOREIGN KEY (order_id) REFERENCES olist_orders(order_id);

ALTER TABLE olist_order_items
ADD CONSTRAINT fk_order_items_product
FOREIGN KEY (product_id) REFERENCES olist_products(product_id);

ALTER TABLE olist_order_items
ADD CONSTRAINT fk_order_items_seller
FOREIGN KEY (seller_id) REFERENCES olist_sellers(seller_id);

ALTER TABLE olist_order_reviews
MODIFY COLUMN order_id VARCHAR(50);

ALTER TABLE olist_order_reviews
ADD CONSTRAINT fk_reviews_order
FOREIGN KEY (order_id) REFERENCES olist_orders(order_id);

ALTER TABLE olist_order_payments
ADD CONSTRAINT fk_payments_order
FOREIGN KEY (order_id) REFERENCES olist_orders(order_id);

-- 1. Understanding the structure of the dataset

-- View all tables in the schema
SHOW TABLES;

-- Get table descriptions
DESCRIBE olist_customers;
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
SELECT 'olist_customers', COUNT(*) FROM olist_customers
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