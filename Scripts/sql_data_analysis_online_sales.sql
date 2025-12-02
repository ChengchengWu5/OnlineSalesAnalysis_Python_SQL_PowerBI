/*
================================================================================
Data Analysis in SQL Server
---------------------------
Script Purpose:
    - tracking trends and growth over time
    - comparing performance against targets
    - measuring the contribution of dimensions to overall sales
    - measuring behaviors/performance by segments defined
================================================================================
*/


--------------------------------------------------------------------------------
-- Change-over-time trends: to track trends and identify seasonality in the data
--------------------------------------------------------------------------------

-- Total customers made purchase, total products sold, total quantity sold, total sales, and total profit by month

-- Create a view
CREATE OR ALTER VIEW main_aggregations AS
SELECT 
    MONTH(order_date) AS order_month,
    COUNT(DISTINCT customer_key) AS customer_count,
    COUNT(DISTINCT product_key) AS product_count,
    SUM(quantity) AS total_quantity,
    SUM(amount) AS total_sales,
    SUM(profit) AS total_profit
FROM fact_orders
GROUP BY MONTH(order_date);

----------------------------------------------------------------------------------
-- Cumulative Analysis: to understand whether our business is growing or declining 
----------------------------------------------------------------------------------

-- What are the total sales per month and the running total of sales over time?

-- Create a view
CREATE OR ALTER VIEW sales_over_time AS
-- Create a CTE
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
    SUM(total_sales) OVER (ORDER BY order_month) AS running_total_sales
FROM total_sales_per_month;

-- What are the average number of orders per month and the moving average number of orders over time

-- Create a view
CREATE OR ALTER VIEW avg_orders_over_time AS
-- Create a CTE
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

-- Create a view
CREATE OR ALTER VIEW monthly_sales_category AS
-- Create a CTE
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

-- Create a view
CREATE OR ALTER VIEW category_contribution_total_sales AS
-- Create a CTE
WITH category_contribution_total_sales AS (                 
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
FROM category_contribution_total_sales;

-- Which states and cities contribute the most to overall sales?

-- Create a view
CREATE OR ALTER VIEW state_city_contribution_total_sales AS
-- Create a CTE
WITH state_city_contribution_total_sales AS (
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
FROM state_city_contribution_total_sales;

-----------------------------------------------------------------------------------
-- Segmentation Analysis: to understand the behavior/performace by segments defined
-----------------------------------------------------------------------------------

/* What is the total number of customers by the following group?
    - VIP: customers with at least 2 months of order history (lifespan) and spending more than 100
    - Regular: customers with at least 2 months of order history but spending 100 or less
    - New: customers with the order history of less than 3 months */

-- Create a view
CREATE OR ALTER VIEW customer_segmentation_behavior AS
-- Create a CTE
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
        CASE WHEN lifespan >= 2 AND total_spending > 800 THEN 'VIP'
             WHEN lifespan >= 2 AND total_spending <=800 THEN 'Regular'
             ELSE 'New'
        END AS customer_segment
    FROM customer_lifespan
)
SELECT 
    customer_segment,
    COUNT(DISTINCT customer_key) AS total_customers
FROM customer_segmentation
GROUP BY customer_segment;

/* What is the average selling price of products by the following segments?
    - Low Performer: products with the total sales value less than 10000
    - Mid Performer: products with the total sales value between 10000 and 40000
    - High Performer: products with the total sales value more than 40000 */

-- Create a view
CREATE OR ALTER VIEW product_segmentation_performance AS
-- Create a CTE
WITH product_sales_quantity AS (                                
    SELECT 
        p.product_key, 
        p.category,
        p.sub_category,
        SUM(o.amount) AS total_sales,
        SUM(o.quantity) AS total_quantity
    FROM fact_orders AS o
    LEFT JOIN dim_products AS p
        ON o.product_key = p.product_key
    GROUP BY 
        p.product_key, 
        p.category,
        p.sub_category
    ),
product_segmentation AS (
	SELECT 
        product_key, 
        category,
        sub_category,
        CASE WHEN total_sales < 10000 THEN 'Low Performer'
             WHEN total_sales <= 40000 THEN 'Mid Performer'
             ELSE 'High Performer'
        END AS product_segment,
        total_sales,
        total_quantity
    FROM product_sales_quantity
    )
SELECT 
    product_key, 
    category,
    sub_category,
    product_segment,
    CASE WHEN total_quantity = 0 THEN 0
		 ELSE total_sales / total_quantity 
    END AS average_selling_price
FROM product_segmentation;
