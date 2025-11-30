/*
==================================================================================
Product Report
--------------
Purpose:
	- This report presents key product metrics and performance

Heightlights: 
	1. Gather essential attributes from the fact_orders and dim_products tables
	2. Categorize products by revenue to identify high, mid, and low performers
	3. Summarize key metrics at the product level:
	   - total orders
	   - total sales
	   - total quantity
	   - total customers
	   - total profit
	   - last order date
	   - liftspan (in months)
	4. Calculate KPIs:
	   - average selling price
	   - average order revenue
	   - average monthly revenue
==================================================================================
*/

-- Create a view for the product report
CREATE OR ALTER VIEW report_products AS

-- Create a Base Query CTE: Retrieve main attributes from the fact_orders and dim_products tables 
WITH products_base_query AS (
	SELECT 
		o.order_id, 
		o.amount,
		o.order_date,
		o.quantity,
		o.customer_key,
		o.profit,
		p.product_key,
		p.category,
		p.sub_category
	FROM fact_orders AS o
	LEFT JOIN dim_products AS p
		ON o.product_key = p.product_key
	),

-- Create a product Aggregations CTE: Summarize key metrics at the product level
product_aggregations AS (
SELECT 
	product_key,
	category,
	sub_category,
	COUNT(DISTINCT order_id) AS total_orders,
	SUM(amount) AS total_sales,
	SUM(quantity) AS total_quantity, 
	COUNT(DISTINCT customer_key) AS total_customers,
	SUM(profit) AS total_profit,
	MAX(order_date) AS last_order_date,
	DATEDIFF(MONTH, MIN(order_date), MAX(order_date)) AS lifespan
FROM products_base_query
GROUP BY 
	product_key,
	category,
	sub_category
)

-- Calculate Product KPIs
SELECT
	product_key,
	category,
	sub_category,
	-- Categorize products by revenue to identify high, mid, and low performers
	CASE WHEN total_sales < 10000 THEN 'Low Performer'
         WHEN total_sales <= 40000 THEN 'Mid Performer'
         ELSE 'High Performer'
    END AS product_segment,
	last_order_date,
	lifespan,
	total_orders,
	total_sales,
	total_quantity, 
	total_customers,
	total_profit,
	-- Calculate average selling price
	CASE WHEN total_quantity = 0 THEN 0
		 ELSE total_sales / total_quantity 
	END AS average_selling_price,
	-- Calculate average order value
	CASE WHEN total_orders = 0 THEN 0
		 ELSE total_sales / total_orders
	END AS average_order_value,
	-- Calculate average monthly revenue 
	CASE WHEN lifespan = 0 THEN total_sales
		 ELSE total_sales / lifespan
	END AS average_monthly_revenue
FROM product_aggregations
