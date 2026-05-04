
-- E-Commerce Sales Analysis SQL Queries
-- Dataset: Olist Brazilian E-Commerce

-- Query 1: Top 10 Categories by Revenue
SELECT 
    ct.product_category_name_english AS category,
    ROUND(SUM(op.payment_value), 2) AS total_revenue,
    COUNT(DISTINCT oi.order_id) AS total_orders
FROM order_items oi
JOIN order_payments op ON oi.order_id = op.order_id
JOIN products p ON oi.product_id = p.product_id
JOIN category_translation ct ON p.product_category_name = ct.product_category_name
GROUP BY category
ORDER BY total_revenue DESC
LIMIT 10;

-- Query 2: Revenue by State
SELECT 
    c.customer_state AS state,
    ROUND(SUM(op.payment_value), 2) AS total_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders
FROM orders o
JOIN order_payments op ON o.order_id = op.order_id
JOIN customers c ON o.customer_id = c.customer_id
WHERE o.order_status = 'delivered'
GROUP BY state
ORDER BY total_revenue DESC
LIMIT 10;

-- Query 3: Monthly Revenue Trend
SELECT 
    strftime('%Y', o.order_purchase_timestamp) AS year,
    strftime('%m', o.order_purchase_timestamp) AS month,
    ROUND(SUM(op.payment_value), 2) AS monthly_revenue,
    COUNT(DISTINCT o.order_id) AS total_orders,
    ROUND(AVG(op.payment_value), 2) AS avg_order_value
FROM orders o
JOIN order_payments op ON o.order_id = op.order_id
WHERE o.order_status = 'delivered'
GROUP BY year, month
ORDER BY year, month;

-- Query 4: Customer Segmentation by Revenue
SELECT 
    CASE 
        WHEN total_revenue <= 100 THEN 'Low (0-100)'
        WHEN total_revenue <= 500 THEN 'Mid (100-500)'
        WHEN total_revenue <= 1000 THEN 'High (500-1000)'
        ELSE 'Premium (1000+)'
    END AS segment,
    COUNT(*) AS customer_count,
    ROUND(SUM(total_revenue), 2) AS segment_revenue
FROM (
    SELECT c.customer_unique_id, 
           SUM(op.payment_value) AS total_revenue
    FROM orders o
    JOIN order_payments op ON o.order_id = op.order_id
    JOIN customers c ON o.customer_id = c.customer_id
    WHERE o.order_status = 'delivered'
    GROUP BY c.customer_unique_id
) customer_totals
GROUP BY segment
ORDER BY segment_revenue DESC;
