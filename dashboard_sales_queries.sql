1. Revenue and Sales Metrics
Total Revenue

SELECT 
    SUM(total_sale) AS total_revenue,
    COUNT(*) AS total_transactions,
    AVG(total_sale) AS avg_transaction_value
FROM transactions;
Revenue by Time Period

SELECT 
    YEAR(sale_date) AS year,
    MONTH(sale_date) AS month,
    SUM(total_sale) AS monthly_revenue,
    COUNT(*) AS transactions_count
FROM transactions
GROUP BY YEAR(sale_date), MONTH(sale_date)
ORDER BY year, month;
2. Product Category Analysis
Revenue by Category

SELECT 
    category,
    SUM(total_sale) AS category_revenue,
    COUNT(*) AS transactions_count,
    SUM(quantiy) AS total_quantity,
    ROUND(SUM(total_sale) * 100.0 / SUM(SUM(total_sale)) OVER(), 2) AS revenue_percentage
FROM transactions
WHERE total_sale IS NOT NULL
GROUP BY category
ORDER BY category_revenue DESC;
Top Selling Products by Category

SELECT 
    category,
    price_per_unit,
    SUM(quantiy) AS total_quantity,
    SUM(total_sale) AS total_revenue
FROM transactions
WHERE quantiy IS NOT NULL
GROUP BY category, price_per_unit
ORDER BY category, total_revenue DESC;
3. Customer Analysis
Customer Segmentation by Spending

SELECT 
    customer_id,
    gender,
    age,
    COUNT(*) AS purchase_count,
    SUM(total_sale) AS total_spent,
    AVG(total_sale) AS avg_purchase_value
FROM transactions
WHERE total_sale IS NOT NULL
GROUP BY customer_id, gender, age
ORDER BY total_spent DESC;
New vs Returning Customers

WITH customer_orders AS (
    SELECT 
        customer_id,
        MIN(sale_date) AS first_purchase,
        MAX(sale_date) AS last_purchase,
        COUNT(*) AS total_orders,
        SUM(total_sale) AS total_spent
    FROM transactions
    GROUP BY customer_id
)
SELECT 
    CASE 
        WHEN total_orders = 1 THEN 'New Customer'
        ELSE 'Returning Customer'
    END AS customer_type,
    COUNT(*) AS customer_count,
    SUM(total_spent) AS total_revenue,
    AVG(total_orders) AS avg_orders_per_customer
FROM customer_orders
GROUP BY customer_type;
4. Time Analysis
Daily Sales Pattern

SELECT 
    EXTRACT(HOUR FROM sale_time) AS hour_of_day,
    COUNT(*) AS transaction_count,
    SUM(total_sale) AS total_revenue,
    AVG(total_sale) AS avg_transaction_value
FROM transactions
WHERE sale_time IS NOT NULL
GROUP BY EXTRACT(HOUR FROM sale_time)
ORDER BY hour_of_day;
Day of Week Analysis

SELECT 
    DAYNAME(sale_date) AS day_of_week,
    COUNT(*) AS transaction_count,
    SUM(total_sale) AS total_revenue,
    AVG(total_sale) AS avg_transaction_value
FROM transactions
GROUP BY DAYNAME(sale_date), DAYOFWEEK(sale_date)
ORDER BY DAYOFWEEK(sale_date);
5. Geographic/Demographic Analysis
Sales by Gender

SELECT 
    gender,
    COUNT(*) AS transaction_count,
    SUM(total_sale) AS total_revenue,
    AVG(total_sale) AS avg_transaction_value,
    AVG(age) AS avg_age
FROM transactions
WHERE gender IS NOT NULL AND total_sale IS NOT NULL
GROUP BY gender;
Sales by Age Group

SELECT 
    CASE 
        WHEN age < 20 THEN 'Teen (Below 20)'
        WHEN age BETWEEN 20 AND 29 THEN '20s'
        WHEN age BETWEEN 30 AND 39 THEN '30s'
        WHEN age BETWEEN 40 AND 49 THEN '40s'
        WHEN age BETWEEN 50 AND 59 THEN '50s'
        WHEN age >= 60 THEN '60+'
        ELSE 'Unknown'
    END AS age_group,
    COUNT(*) AS transaction_count,
    SUM(total_sale) AS total_revenue,
    AVG(total_sale) AS avg_transaction_value
FROM transactions
WHERE age IS NOT NULL
GROUP BY age_group
ORDER BY 
    CASE age_group
        WHEN 'Teen (Below 20)' THEN 1
        WHEN '20s' THEN 2
        WHEN '30s' THEN 3
        WHEN '40s' THEN 4
        WHEN '50s' THEN 5
        WHEN '60+' THEN 6
        ELSE 7
    END;
6. Product Performance
Profitability Analysis (using COGS)

SELECT 
    category,
    SUM(total_sale) AS total_revenue,
    SUM(cogs) AS total_cogs,
    SUM(total_sale) - SUM(cogs) AS total_profit,
    ROUND((SUM(total_sale) - SUM(cogs)) * 100.0 / SUM(total_sale), 2) AS profit_margin_percentage
FROM transactions
WHERE cogs IS NOT NULL AND total_sale IS NOT NULL
GROUP BY category
ORDER BY total_profit DESC;
7. Key Performance Indicators (KPIs)
Dashboard KPIs

WITH metrics AS (
    SELECT 
        COUNT(DISTINCT customer_id) AS unique_customers,
        COUNT(*) AS total_transactions,
        SUM(total_sale) AS total_revenue,
        SUM(quantiy) AS total_items_sold,
        AVG(total_sale) AS avg_transaction_value,
        SUM(CASE WHEN sale_date >= DATE_SUB(MAX(sale_date), INTERVAL 30 DAY) THEN total_sale END) AS last_30_days_revenue
    FROM transactions
    WHERE total_sale IS NOT NULL
)
SELECT 
    unique_customers,
    total_transactions,
    total_revenue,
    total_items_sold,
    avg_transaction_value,
    ROUND(total_revenue / NULLIF(unique_customers, 0), 2) AS revenue_per_customer,
    ROUND(total_revenue / NULLIF(total_transactions, 0), 2) AS revenue_per_transaction,
    last_30_days_revenue
FROM metrics;
8. Trend Analysis
Monthly Growth Rate

WITH monthly_revenue AS (
    SELECT 
        YEAR(sale_date) AS year,
        MONTH(sale_date) AS month,
        SUM(total_sale) AS revenue
    FROM transactions
    WHERE total_sale IS NOT NULL
    GROUP BY YEAR(sale_date), MONTH(sale_date)
),
monthly_growth AS (
    SELECT 
        year,
        month,
        revenue,
        LAG(revenue) OVER (ORDER BY year, month) AS prev_month_revenue
    FROM monthly_revenue
)
SELECT 
    year,
    month,
    revenue,
    ROUND(((revenue - prev_month_revenue) * 100.0 / NULLIF(prev_month_revenue, 0)), 2) AS growth_percentage
FROM monthly_growth
ORDER BY year, month;
9. Customer Lifetime Value (CLV)

WITH customer_stats AS (
    SELECT 
        customer_id,
        COUNT(*) AS total_purchases,
        SUM(total_sale) AS total_spent,
        MIN(sale_date) AS first_purchase,
        MAX(sale_date) AS last_purchase,
        DATEDIFF(MAX(sale_date), MIN(sale_date)) + 1 AS customer_lifetime_days
    FROM transactions
    WHERE total_sale IS NOT NULL
    GROUP BY customer_id
)
SELECT 
    ROUND(AVG(total_spent), 2) AS avg_clv,
    ROUND(AVG(total_spent / NULLIF(customer_lifetime_days, 0) * 365), 2) AS avg_annual_clv,
    COUNT(*) AS customers_with_clv
FROM customer_stats
WHERE customer_lifetime_days > 0;
10. Inventory/Product Analysis
Stock Turnover Analysis

SELECT 
    category,
    price_per_unit,
    SUM(quantiy) AS total_quantity_sold,
    SUM(total_sale) AS total_revenue,
    ROUND(SUM(quantiy) / COUNT(DISTINCT DATE(sale_date)), 2) AS avg_daily_sales
FROM transactions
WHERE quantiy IS NOT NULL
GROUP BY category, price_per_unit
ORDER BY category, total_quantity_sold DESC;