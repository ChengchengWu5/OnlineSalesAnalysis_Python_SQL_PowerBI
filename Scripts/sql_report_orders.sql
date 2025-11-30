/*
==================================================================================
Order Report
------------
Purpose:
	- This report gathers main attributes from the fact_orders table:
	   - Order ID
	   - Order Date
	   - Amount
	   - Profit
	   - Quantity
	   - Customer Key
	   - Product Key
==================================================================================
*/

-- Create a view for the order report
CREATE OR ALTER VIEW report_orders AS
SELECT 
	order_id, 
	order_date,
	amount,
	profit,
	quantity,
	customer_key,
	product_key
FROM fact_orders;
