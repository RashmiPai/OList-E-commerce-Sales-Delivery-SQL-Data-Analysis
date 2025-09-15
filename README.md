
# 🛒 Olist E-commerce Sales & Delivery Analysis

## 📌 Project Overview

This project analyzes the Olist e-commerce dataset to uncover insights into customer behavior, seller performance, product trends, and delivery logistics. The analysis is based on real transaction data from a Brazilian marketplace platform and involves structured data from multiple related tables.

The key focus areas include:

- Identifying best-selling products and high-performing sellers  
- Understanding geographic distribution of customers and sellers  
- Analyzing delivery timelines and customer satisfaction  
- Highlighting seasonal trends and revenue drivers  
- Deriving actionable business insights and recommendations

## 🗂️ Dataset Description

The project uses multiple CSV files provided by Olist, each representing a different entity:

| Table Name                  | Description                                      | Key Relationships                                  |
|----------------------------|--------------------------------------------------|----------------------------------------------------|
| `olist_orders_dataset`     | Order lifecycle information                      | Links to customers, reviews, payments, items       |
| `olist_customers_dataset`  | Unique customer data with location               | Linked via `customer_id`                           |
| `olist_order_items_dataset`| Details on individual products in each order     | Links to orders, products, and sellers             |
| `olist_products_dataset`   | Metadata about products                          | Linked to items via `product_id`                   |
| `olist_sellers_dataset`    | Seller location and identifiers                  | Linked to items via `seller_id`                    |
| `olist_order_payments_dataset` | Payment method and value per order         | Linked via `order_id`                              |
| `olist_order_reviews_dataset`  | Customer reviews for each order            | Linked via `order_id`                              |
| `olist_geolocation_dataset`   | Zip code–level location mapping             | Linked via zip code prefix                         |

---

## 🧪 Tools & Technologies

- **MySQL** – for data modeling, cleaning, and advanced querying  
- **SQL** – complex joins, aggregations, window functions  
- **Python / Pandas (optional)** – for dataset loading 

---

## 📊 Key Business Insights

**1. Best-Selling Products Are the Backbone of Sales**

The top 5 most sold products contribute disproportionately to overall order volume. This suggests a strong product-market fit in certain categories and indicates that these items should be prioritized in marketing campaigns and inventory forecasting.

**2. A Small Number of Sellers Drive Most Revenue**

Revenue isn't evenly distributed. A few sellers account for the lion's share, making them crucial partners. Retaining and supporting these power sellers can stabilize the platform’s financial base.

**3. Geography Matters: Zip Codes as Commerce Hubs**

Certain zip code regions repeatedly appear as hotspots for both buyers and sellers. These areas can be targeted for localized promotions, faster delivery promises, or even last-mile fulfillment hubs.

**4. Sales Are Seasonally Influenced**

Monthly order trends reveal peaks and dips that align with local holidays or sales seasons. Understanding these patterns helps in aligning ad spend, seller stocking, and customer engagement efforts.

**5. Product Ratings Influence Perception**

Some products consistently receive higher average reviews. These are not only better quality but are also more likely to generate word-of-mouth recommendations and repeat purchases. Highlight them prominently.

**6. Delivery Time Is a Critical UX Factor**

Analyzing delivery durations shows significant variance. Faster delivery correlates with positive reviews; delayed deliveries likely hurt retention. This insight pushes for better logistics SLAs and seller education.

**7. Who Are the Top Sellers?**

Using window functions to rank sellers unveils a clear hierarchy. This can be the basis for a seller loyalty program or tiered incentives to keep top performers engaged and growing.

**8. Many Orders Are Collaborative**

Multiple sellers often fulfill a single order, which showcases Olist’s strength in combining supply. But it also complicates logistics. Coordinated delivery and bundled shipping offers could reduce friction and cost.

**9. Late Deliveries Are a Reputation Risk**

A measurable chunk of orders are delivered late. Even a 5–10% delay rate can erode trust. Addressing these with predictive alerts or delivery time transparency is essential for improving CSAT scores.

**10. Loyal Customers Deserve Focus**

Customers with repeat purchases form the core of long-term revenue. Identifying, nurturing, and personalizing their experience through loyalty programs can significantly increase lifetime value.

**11. Reorder Time = Retention Indicator**

The average time between customer orders tells you how "sticky" the experience is. If the gap is widening, churn may be rising. Use this to pre-emptively engage users with timely nudges.

**12. Silent Orders = Missed Feedback**

Orders with no review leave the platform blind to user satisfaction. Nudging for reviews or incentivizing them with small perks could boost overall data quality and build trust with future buyers.


---

## ✅ Conclusions

- Top-Selling Products and Sellers Drive the Majority of Revenue
- Delivery Speed Directly Impacts Customer Satisfaction
- Geographic Hotspots Offer Strategic Growth Opportunities
- Seasonality and Repeat Behavior Inform Demand Planning
- Customer Feedback and Review Rates Need Strengthening


In summary, data-backed prioritization of products, sellers, and delivery excellence, combined with customer-focused strategies, will be key to boosting productivity, retention, and profitability on the platform.

---

---

## 💡 Future Enhancements

- Build an interactive dashboard using **Streamlit** or **Power BI**  
- Use **predictive modeling** to forecast delivery delays  
- Cluster analysis for customer segmentation  
- Sentiment analysis on textual reviews  


