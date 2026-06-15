-- =============================================================
-- RETAILCO CUSTOMER ANALYTICS - SQL ANALYSIS WORKBOOK
-- Project 1: E-Commerce Customer Analytics
-- BA: Shweta Goyal | Date: May 2026
-- =============================================================
-- HOW TO USE THIS FILE:
-- 1. Go to https://sqliteonline.com (free, no install needed)
-- 2. Click "File > Import CSV" and load all 3 CSV files
-- 3. Run each query block one at a time
-- 4. Screenshot your results for the portfolio
-- =============================================================


-- =============================================================
-- MODULE 1: DATA EXPLORATION (Run these first)
-- =============================================================

-- 1.1 How many customers do we have? What's the breakdown?
SELECT 
    COUNT(*) AS total_customers,
    SUM(CASE WHEN is_churned = 1 THEN 1 ELSE 0 END) AS churned_customers,
    SUM(CASE WHEN is_churned = 0 THEN 1 ELSE 0 END) AS active_customers,
    ROUND(SUM(CASE WHEN is_churned = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS churn_rate_pct
FROM retailco_customers;

-- 1.2 Customer breakdown by loyalty tier
SELECT 
    loyalty_tier,
    COUNT(*) AS customer_count,
    ROUND(AVG(total_spend_gbp), 2) AS avg_lifetime_spend,
    ROUND(AVG(total_orders), 1) AS avg_orders,
    SUM(CASE WHEN is_churned = 1 THEN 1 ELSE 0 END) AS churned_count,
    ROUND(SUM(CASE WHEN is_churned = 1 THEN 1 ELSE 0 END) * 100.0 / COUNT(*), 1) AS churn_rate_pct
FROM retailco_customers
GROUP BY loyalty_tier
ORDER BY avg_lifetime_spend DESC;

-- 1.3 Geographic distribution - which cities have the most customers?
SELECT 
    city,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_spend_gbp), 2) AS total_revenue,
    ROUND(AVG(total_spend_gbp), 2) AS avg_spend_per_customer
FROM retailco_customers
GROUP BY city
ORDER BY total_revenue DESC
LIMIT 10;


-- =============================================================
-- MODULE 2: CHURN ANALYSIS (Core BA insight)
-- =============================================================

-- 2.1 Churn rate by loyalty tier - WHERE is churn highest?
SELECT 
    loyalty_tier,
    COUNT(*) AS total_customers,
    SUM(is_churned) AS churned,
    ROUND(SUM(is_churned) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    ROUND(AVG(days_since_last_order), 0) AS avg_days_since_order
FROM retailco_customers
GROUP BY loyalty_tier
ORDER BY churn_rate_pct DESC;

-- 2.2 Churn by age group - which demographics churn most?
SELECT 
    CASE 
        WHEN age < 25 THEN '18-24'
        WHEN age BETWEEN 25 AND 34 THEN '25-34'
        WHEN age BETWEEN 35 AND 44 THEN '35-44'
        WHEN age BETWEEN 45 AND 54 THEN '45-54'
        ELSE '55+'
    END AS age_group,
    COUNT(*) AS total_customers,
    SUM(is_churned) AS churned,
    ROUND(SUM(is_churned) * 100.0 / COUNT(*), 1) AS churn_rate_pct,
    ROUND(AVG(total_spend_gbp), 2) AS avg_lifetime_spend
FROM retailco_customers
GROUP BY age_group
ORDER BY churn_rate_pct DESC;

-- 2.3 Early warning: customers at risk (active but not ordered in 180+ days)
SELECT 
    customer_id,
    first_name || ' ' || last_name AS customer_name,
    city,
    loyalty_tier,
    total_orders,
    ROUND(total_spend_gbp, 2) AS lifetime_spend,
    last_order_date,
    days_since_last_order,
    CASE 
        WHEN days_since_last_order BETWEEN 180 AND 270 THEN 'At Risk'
        WHEN days_since_last_order BETWEEN 271 AND 365 THEN 'High Risk'
        WHEN days_since_last_order > 365 THEN 'Almost Lost'
        ELSE 'Healthy'
    END AS risk_status
FROM retailco_customers
WHERE is_churned = 0
    AND days_since_last_order > 180
ORDER BY days_since_last_order DESC;

-- 2.4 What was the typical spend of churned vs active customers?
SELECT 
    CASE WHEN is_churned = 1 THEN 'Churned' ELSE 'Active' END AS customer_status,
    COUNT(*) AS count,
    ROUND(AVG(total_spend_gbp), 2) AS avg_lifetime_spend,
    ROUND(AVG(total_orders), 1) AS avg_orders,
    MIN(total_spend_gbp) AS min_spend,
    MAX(total_spend_gbp) AS max_spend
FROM retailco_customers
GROUP BY is_churned;


-- =============================================================
-- MODULE 3: REVENUE ANALYSIS (Business impact)
-- =============================================================

-- 3.1 Total revenue and average order value by category
SELECT 
    product_category,
    COUNT(*) AS total_orders,
    ROUND(SUM(total_amount_gbp), 2) AS total_revenue,
    ROUND(AVG(total_amount_gbp), 2) AS avg_order_value,
    ROUND(AVG(discount_pct), 1) AS avg_discount_pct
FROM retailco_orders
GROUP BY product_category
ORDER BY total_revenue DESC;

-- 3.2 Revenue by sales channel (Mobile App vs Website)
SELECT 
    channel,
    COUNT(*) AS total_orders,
    ROUND(SUM(total_amount_gbp), 2) AS total_revenue,
    ROUND(AVG(total_amount_gbp), 2) AS avg_order_value,
    ROUND(SUM(total_amount_gbp) * 100.0 / (SELECT SUM(total_amount_gbp) FROM retailco_orders), 1) AS revenue_share_pct
FROM retailco_orders
GROUP BY channel
ORDER BY total_revenue DESC;

-- 3.3 Revenue by payment method
SELECT 
    payment_method,
    COUNT(*) AS transaction_count,
    ROUND(SUM(total_amount_gbp), 2) AS total_revenue,
    ROUND(AVG(total_amount_gbp), 2) AS avg_transaction_value
FROM retailco_orders
GROUP BY payment_method
ORDER BY total_revenue DESC;

-- 3.4 Top 10 highest value orders
SELECT 
    o.order_id,
    o.customer_id,
    c.first_name || ' ' || c.last_name AS customer_name,
    c.loyalty_tier,
    o.product_name,
    o.product_category,
    o.order_date,
    o.total_amount_gbp,
    o.discount_pct || '%' AS discount_applied,
    o.channel
FROM retailco_orders o
JOIN retailco_customers c ON o.customer_id = c.customer_id
ORDER BY o.total_amount_gbp DESC
LIMIT 10;


-- =============================================================
-- MODULE 4: CUSTOMER SEGMENTATION (RFM Analysis)
-- =============================================================
-- RFM = Recency, Frequency, Monetary
-- This is a classic BA/analyst framework for segmenting customers

-- 4.1 Build RFM scores (1-4 scale, 4 = best)
SELECT 
    customer_id,
    first_name || ' ' || last_name AS customer_name,
    loyalty_tier,
    days_since_last_order AS recency_days,
    total_orders AS frequency,
    ROUND(total_spend_gbp, 2) AS monetary_value,
    -- Recency Score: lower days = better (score 4)
    CASE 
        WHEN days_since_last_order <= 60 THEN 4
        WHEN days_since_last_order <= 120 THEN 3
        WHEN days_since_last_order <= 240 THEN 2
        ELSE 1
    END AS recency_score,
    -- Frequency Score: more orders = better
    CASE 
        WHEN total_orders >= 35 THEN 4
        WHEN total_orders >= 20 THEN 3
        WHEN total_orders >= 10 THEN 2
        ELSE 1
    END AS frequency_score,
    -- Monetary Score: higher spend = better
    CASE 
        WHEN total_spend_gbp >= 4000 THEN 4
        WHEN total_spend_gbp >= 1500 THEN 3
        WHEN total_spend_gbp >= 500 THEN 2
        ELSE 1
    END AS monetary_score
FROM retailco_customers
WHERE is_churned = 0
ORDER BY monetary_value DESC;

-- 4.2 Segment customers by RFM combination (business labels)
SELECT 
    customer_id,
    first_name || ' ' || last_name AS customer_name,
    recency_score + frequency_score + monetary_score AS rfm_total,
    CASE 
        WHEN recency_score + frequency_score + monetary_score >= 10 THEN 'Champions'
        WHEN recency_score + frequency_score + monetary_score >= 8 THEN 'Loyal Customers'
        WHEN recency_score + frequency_score + monetary_score >= 6 THEN 'Potential Loyalists'
        WHEN recency_score + frequency_score + monetary_score >= 4 THEN 'At Risk'
        ELSE 'Lost Customers'
    END AS customer_segment
FROM (
    SELECT 
        customer_id,
        first_name,
        last_name,
        CASE WHEN days_since_last_order <= 60 THEN 4 WHEN days_since_last_order <= 120 THEN 3 WHEN days_since_last_order <= 240 THEN 2 ELSE 1 END AS recency_score,
        CASE WHEN total_orders >= 35 THEN 4 WHEN total_orders >= 20 THEN 3 WHEN total_orders >= 10 THEN 2 ELSE 1 END AS frequency_score,
        CASE WHEN total_spend_gbp >= 4000 THEN 4 WHEN total_spend_gbp >= 1500 THEN 3 WHEN total_spend_gbp >= 500 THEN 2 ELSE 1 END AS monetary_score
    FROM retailco_customers
    WHERE is_churned = 0
)
ORDER BY rfm_total DESC;

-- 4.3 Count by segment - key insight for your BRD
SELECT 
    customer_segment,
    COUNT(*) AS customer_count,
    ROUND(COUNT(*) * 100.0 / SUM(COUNT(*)) OVER(), 1) AS percentage
FROM (
    SELECT 
        CASE 
            WHEN rfm_total >= 10 THEN 'Champions'
            WHEN rfm_total >= 8 THEN 'Loyal Customers'
            WHEN rfm_total >= 6 THEN 'Potential Loyalists'
            WHEN rfm_total >= 4 THEN 'At Risk'
            ELSE 'Lost Customers'
        END AS customer_segment
    FROM (
        SELECT 
            (CASE WHEN days_since_last_order <= 60 THEN 4 WHEN days_since_last_order <= 120 THEN 3 WHEN days_since_last_order <= 240 THEN 2 ELSE 1 END
            + CASE WHEN total_orders >= 35 THEN 4 WHEN total_orders >= 20 THEN 3 WHEN total_orders >= 10 THEN 2 ELSE 1 END
            + CASE WHEN total_spend_gbp >= 4000 THEN 4 WHEN total_spend_gbp >= 1500 THEN 3 WHEN total_spend_gbp >= 500 THEN 2 ELSE 1 END) AS rfm_total
        FROM retailco_customers
        WHERE is_churned = 0
    )
)
GROUP BY customer_segment
ORDER BY customer_count DESC;


-- =============================================================
-- MODULE 5: PRODUCT INSIGHTS
-- =============================================================

-- 5.1 Best selling products by revenue
SELECT 
    p.product_name,
    p.category,
    p.sub_category,
    p.rating_avg,
    p.review_count,
    COUNT(o.order_id) AS times_ordered,
    ROUND(SUM(o.total_amount_gbp), 2) AS total_revenue,
    ROUND(AVG(o.discount_pct), 1) AS avg_discount_given
FROM retailco_products p
JOIN retailco_orders o ON p.product_name = o.product_name
GROUP BY p.product_name, p.category, p.sub_category, p.rating_avg, p.review_count
ORDER BY total_revenue DESC
LIMIT 15;

-- 5.2 Category performance summary
SELECT 
    category,
    COUNT(*) AS product_count,
    ROUND(AVG(rating_avg), 2) AS avg_rating,
    SUM(review_count) AS total_reviews,
    ROUND(AVG(unit_price_gbp), 2) AS avg_unit_price
FROM retailco_products
WHERE is_active = 1
GROUP BY category
ORDER BY avg_rating DESC;

-- 5.3 Low stock alert - items that may need reordering (< 50 units)
SELECT 
    product_id,
    product_name,
    category,
    stock_qty,
    unit_price_gbp,
    CASE 
        WHEN stock_qty < 30 THEN 'CRITICAL - Reorder Now'
        WHEN stock_qty < 50 THEN 'LOW - Monitor Closely'
        ELSE 'OK'
    END AS stock_status
FROM retailco_products
WHERE is_active = 1 AND stock_qty < 50
ORDER BY stock_qty ASC;


-- =============================================================
-- BONUS: EXECUTIVE SUMMARY QUERY (for BRD headline metrics)
-- =============================================================
-- Run this last — it gives you the key numbers for your BRD

SELECT '=== RETAILCO EXECUTIVE SUMMARY ===' AS metric, '' AS value
UNION ALL SELECT 'Total Customers', CAST(COUNT(*) AS TEXT) FROM retailco_customers
UNION ALL SELECT 'Active Customers', CAST(SUM(CASE WHEN is_churned=0 THEN 1 ELSE 0 END) AS TEXT) FROM retailco_customers
UNION ALL SELECT 'Churned Customers', CAST(SUM(is_churned) AS TEXT) FROM retailco_customers
UNION ALL SELECT 'Churn Rate', CAST(ROUND(SUM(is_churned)*100.0/COUNT(*),1) AS TEXT) || '%' FROM retailco_customers
UNION ALL SELECT 'Total Revenue (Orders Table)', '£' || CAST(ROUND((SELECT SUM(total_amount_gbp) FROM retailco_orders),2) AS TEXT)
UNION ALL SELECT 'Avg Order Value', '£' || CAST(ROUND((SELECT AVG(total_amount_gbp) FROM retailco_orders),2) AS TEXT)
UNION ALL SELECT 'Mobile App Revenue Share', CAST(ROUND((SELECT SUM(total_amount_gbp) FROM retailco_orders WHERE channel='Mobile App')*100.0/(SELECT SUM(total_amount_gbp) FROM retailco_orders),1) AS TEXT) || '%'
UNION ALL SELECT 'Top Category by Revenue', (SELECT product_category FROM retailco_orders GROUP BY product_category ORDER BY SUM(total_amount_gbp) DESC LIMIT 1);
