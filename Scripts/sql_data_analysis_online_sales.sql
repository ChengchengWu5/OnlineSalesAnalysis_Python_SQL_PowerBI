/*
================================================================================
Data Analysis in SQL Server
================================================================================
Script Purpose:
    - tracking monthly trends, growth, and KPIs
    - measuring the performance of products against targets
    - measuring the contribution of products and states/cities to overall sales
    - measuring customer behaviors by segments defined
  
Main SQL Techniques/Functions Used:
    - CTEs
    - LAG(): Accesses data from previous rows
    - CASE: Defines conditional logic for trend analysis
    - SUM() OVER(): Computes average values within partitions
================================================================================
*/


--------------------------------------------------------------------------------
-- Change-over-time trends: to track trends and identify seasonality in the data
--------------------------------------------------------------------------------

-- Total customers made purchase, total products sold, total quantity sold, total sales, and total profit by month
SELECT 
    FORMAT(order_date, 'yyyy-MM') AS order_date,
    COUNT(DISTINCT customer_key) AS total_customers_made_purchase,
    COUNT(DISTINCT product_key) AS total_products_sold,
    SUM(quantity) AS total_quantity_sold,
    SUM(amount) AS total_sales,
    SUM(profit) AS total_profit
FROM fact_orders
GROUP BY FORMAT(order_date, 'yyyy-MM');


----------------------------------------------------------------------------------
-- Cumulative Analysis: to understand whether our business is growing or declining 
----------------------------------------------------------------------------------

-- What are the total sales per month and the running total of sales over time?
WITH total_sales_per_month AS (
    SELECT 
        MONTH(order_date) AS order_month,
        SUM(amount) AS total_sales
    FROM fact_orders
    GROUP BY MONTH(order_date)
    )
SELECT 
    order_month,
    total_sales,
    -- Window function
    SUM(total_sales) OVER (ORDER BY order_month) AS running_total_sales
FROM total_sales_per_month;

-- What are the average number of orders per month and the moving average number of orders over time
WITH avg_orders AS (
    SELECT 
        MONTH(order_date) AS order_month,
        AVG(DISTINCT orders_key) AS avg_orders
    FROM fact_orders
    GROUP BY MONTH(order_date)
    )
SELECT
    order_month,
    avg_orders,
    AVG(avg_orders) OVER (ORDER BY order_month) AS moving_avg_orders
FROM avg_orders;


----------------------------------------------------------------------------------
-- Performance Analysis: to compare performance against targets
----------------------------------------------------------------------------------

-- What is monthly sales of each category of products comparing to its average sales and previous month's sales?
WITH monthly_sales_category AS (
    SELECT
        MONTH(o.order_date) AS order_month,
        p.category,
        SUM(o.amount) AS current_month_sales
    FROM fact_orders AS o
    LEFT JOIN dim_products AS p
        ON o.product_key = p.product_key
    GROUP BY 
        MONTH(o.order_date),
        p.category
    ) 
SELECT 
    order_month, 
    category, 
    current_month_sales,
    AVG(current_month_sales) OVER (PARTITION BY category) AS avg_sales, 
    current_month_sales - AVG(current_month_sales) OVER (PARTITION BY category) AS diff_avg,
    CASE WHEN current_month_sales - AVG(current_month_sales) OVER (PARTITION BY category) > 0 THEN 'Above Average'
         WHEN current_month_sales - AVG(current_month_sales) OVER (PARTITION BY category) < 0 THEN 'Below Average'
         ELSE 'Average'
    END AS 'avg_change',
    LAG(current_month_sales) OVER (PARTITION BY category ORDER BY order_month) AS previous_month_sales,
    current_month_sales - LAG(current_month_sales) OVER (PARTITION BY category ORDER BY order_month) AS diff_previous_month,
    CASE 
        WHEN LAG(current_month_sales) OVER (PARTITION BY category ORDER BY order_month) IS NULL THEN NULL
        ELSE
            ROUND((current_month_sales - CAST(LAG(current_month_sales) OVER (PARTITION BY category ORDER BY order_month) AS FLOAT)) /
            CAST(LAG(current_month_sales) OVER (PARTITION BY category ORDER BY order_month) AS FLOAT)* 100, 2)
    END AS percent_monthly_growth
FROM monthly_sales_category;


----------------------------------------------------------------------------------
-- Part-to-Whole Analysis: to understand which category has the greatest impact
----------------------------------------------------------------------------------

-- Which categories contribute the most to overall sales?
WITH total_sales_category AS (
SELECT
    p.category,
    SUM(o.amount) AS total_sales
FROM fact_orders AS o
LEFT JOIN dim_products AS p
    ON o.product_key = p.product_key
GROUP BY p.category
)
SELECT
    category, 
    total_sales,
    SUM(total_sales) OVER() AS overall_sales,
    ROUND(total_sales / CAST(SUM(total_sales) OVER() AS FLOAT) * 100, 2) AS percent_sales_category
FROM total_sales_category
ORDER BY percent_sales_category DESC;

-- Which states and cities contribute the most to overall sales?
WITH total_sales_state_city AS (
SELECT
    c.state,
    c.city,
    SUM(o.amount) AS total_sales
FROM fact_orders AS o
LEFT JOIN dim_customers AS c
    ON o.customer_key = c.customer_key
GROUP BY 
    c.state,
    c.city
)
SELECT
    state, 
    city,
    total_sales,
    SUM(total_sales) OVER() AS overall_sales,
    ROUND(total_sales / CAST(SUM(total_sales) OVER() AS FLOAT) * 100, 2) AS percent_sales_state_city
FROM total_sales_state_city
ORDER BY percent_sales_state_city DESC;


-----------------------------------------------------------------------------------
-- Segmentation Analysis: to understand the performace/behavior by segments defined
-----------------------------------------------------------------------------------

-- What is the number of returning and new customers and their total revenue contributions and average revenue?

WITH customer_orders AS (
    SELECT 
        c.customer_key,
        COUNT(DISTINCT o.order_id) AS order_count,
        SUM(o.amount) AS total_revenue,
        AVG(o.amount) AS avg_revenue
    FROM fact_orders AS o
    LEFT JOIN dim_customers AS c
        ON o.customer_key = c.customer_key
    GROUP BY c.customer_key
),
customer_segmentation AS (
    SELECT 
        customer_key,
        CASE WHEN order_count > 1 THEN 'Returning'
             ELSE 'New'
        END AS customer_segment,
        total_revenue
    FROM customer_orders
)
SELECT 
    customer_segment,
    COUNT(DISTINCT customer_key) AS customer_count,
    SUM(total_revenue) AS total_revenue,
    AVG(total_revenue) AS avg_revenue_per_customer
FROM customer_segmentation
GROUP BY customer_segment;

/* What is the total number of customers by the following group?
    - VIP: customers with at least 2 months of order history (lifespan) and spending more than 100
    - Regular: customers with at least 2 months of order history but spending 100 or less
    - New: customers with the order history of less than 3 months */

WITH customer_lifespan AS (
    SELECT 
        c.customer_key, 
        MIN(o.order_date) AS first_order_date,
        MAX(o.order_date) AS last_order_date,
        DATEDIFF(MONTH, MIN(o.order_date), MAX(o.order_date)) AS lifespan,
        SUM(amount) AS total_spending
    FROM fact_orders AS o
    LEFT JOIN dim_customers AS c
        ON o.customer_key = c.customer_key
    GROUP BY c.customer_key
    ),
customer_segmentation AS (
    SELECT 
        customer_key,
        CASE WHEN lifespan >= 2 AND total_spending > 100 THEN 'VIP'
             WHEN lifespan >= 2 AND total_spending <= 100 THEN 'Regular'
             ELSE 'New'
        END AS customer_segment
    FROM customer_lifespan
)
SELECT 
    customer_segment,
    COUNT(DISTINCT customer_key) AS total_customers
FROM customer_segmentation
GROUP BY customer_segment
ORDER BY total_customers DESC;
