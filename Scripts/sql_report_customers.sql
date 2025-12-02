/*
==================================================================================
Customer Report
---------------
Purpose:
	- This report presents key customer metrics and behaviors

Heightlights: 
	1. Gather essential attributes from the fact_orders and dim_customers tables
	2. Categorize customers into segments, such as VIP, Regular, and New Customers
	3. Summarize key metrics at the customer level:
	   - total orders
	   - total sales
	   - total quantity
	   - total products
	   - total profit
	   - last order date
	   - liftspan (in months)
	4. Calculate KPIs:
	   - recency (months since last order)
	   - average order value
	   - average monthly spending
==================================================================================
*/

-- Create a view for the customer report
CREATE OR ALTER VIEW report_customers AS

-- Create a Base Query CTE: Retrieve main attributes from the fact_orders and dim_customers tables 
WITH customers_base_query AS (
	SELECT 
		o.order_id, 
		o.amount,
		o.order_date,
		o.quantity,
		o.product_key,
		o.profit,
		c.customer_key,
		c.customer_name,
		c.state,
		c.city
	FROM fact_orders AS o
	LEFT JOIN dim_customers AS c
		ON o.customer_key = c.customer_key
	),

-- Create a customer Aggregations CTE: Summarize key metrics at the customer level
customer_aggregations AS (
SELECT 
	customer_key,
	customer_name,
	state,
	city,
	COUNT(DISTINCT order_id) AS total_orders,
	SUM(amount) AS total_sales,
	SUM(quantity) AS total_quantity, 
	COUNT(DISTINCT product_key) AS total_products,
	SUM(profit) AS total_profit,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM customers_base_query
GROUP BY 
	customer_key,
	customer_name,
	state,
	city
)

-- Calculate Customer KPIs
SELECT
	customer_key,
	customer_name,
	state,
	city,
	CASE WHEN lifespan >= 2 AND total_sales > 800 THEN 'VIP'
         WHEN lifespan >= 2 AND total_sales <= 800 THEN 'Regular'
         ELSE 'New'
    END AS customer_segment,
	last_order_date,
	lifespan,
	total_orders,
	total_sales,
	total_quantity, 
	total_products,
	total_profit,
	-- Calculate recency
	DATEDIFF(MONTH, last_order_date, GETDATE()) AS recency,
	-- Calculate average order value
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders
	END AS average_order_value,
	-- Calculate average monthly spending 
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales / lifespan
	END AS average_monthly_spending
FROM customer_aggregations
