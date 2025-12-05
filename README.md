# **Online Sales ETL and Analytics Project — README**

## **Overview**

This project analyzes online sales data to uncover insights that support data-driven decision-making. Using a dataset of two initial tables (Orders and Details), the analysis explores trends in **revenue, orders, and profit** across different time periods, locations, customer segments, and product categories and segments.

The workflow includes Extract, Transform and Load (ETL) and data modeling in Python, Exploratory Data Analysis (EDA) and advanced analysis in SQL Server, and the creation of an interactive report in Power BI.

---

## **Datasets**

The project uses two raw datasets:

* **Orders Table**
  Contains high-level order information such as order date, customer type, city, and state.

* **Details Table**
  Contains details such as product category, subcategory, price, quantity, and profit.

* **Data Source** https://www.kaggle.com/datasets/samruddhi4040/online-sales-data?select=Orders.csv

After modeling, the project produces three structured tables:

* **Fact Orders**
* **Dim Customers**
* **Dim Products**

---

## **Tools & Technologies**

* **Python (Jupyter Notebook in VS Code)**
  Data loading, cleaning, transformation, modelling, table creation, and pushing to SQL Server using Pandas.
* **SQL Server**
  Data storage, EDA, analytical SQL queries, and view creation.
* **Power BI**
  Interactive report building.

---

## **Process & Steps**

### **1. Data Loading**

* Loaded the Orders and Details tables using Pandas.
* Inspected data types and verified keys before merging.

### **2. Initial Exploration**

* Checked dataframe structure, missing values, main attributes, and key uniqueness.
* Understood relationships between orders, customers, and products.

### **3. Column Standardization**

* Renamed and standardized column names to improve readability and consistency.

### **4. Data Modeling**

Created a star schema consisting of:

* **Customers Dimension**
  Standardized customer attributes and added a surrogate key.

* **Products Dimension**
  Consolidated product information and added a surrogate key.

* **Orders Fact Table**
  Merged relevant attributes from the two raw tables and the two dimension tables and added a surrogate key.

### **5. Pushing Modeled Tables**

* Pushed all three tables (fact and dimensions) to SQL Server.

### **6. SQL Server Integration**

* Connected to a SQL Server database.
* Ensured key fields were marked as NOT NULL.
* Set primary and foreign key constraints.
* Created a star shema setup stored procedure for the process.

### **7. SQL EDA and Advanced Analysis**

* Performed EDA to explore the database and the tables in the database by:
    - identifying tables and columns in the database;
    - identifying unique values/categories in each dimension;
    - calculating key metrics and building a report for the calculations;
    - comparing the measure values by different categories;
    - identifying the Top N performers and Bottom N performers.

* Performed advanced analysis in the database to:
    - track trends and growth over time;
    - compare performance against targets;
    - measure the contribution of dimensions to overall sales;
    - measure behaviors/performance by segments defined.

* Created views to be used for visualization in Power BI, including:
    - views based on the analysis;
    - views for two reports, the Customer Report and the Product Report.

### **8. Power BI Reporting**

* Imported the views from SQL Server into Power BI.
* Created a date table using a date table function in Advanced Editor.
* Built an interative Online Sales report, including **Overview**, **Customers**, and **Products** pages.

---

## **Results**

* Calculated total customers made purchase, total products sold, total quantity sold, total sales, and total profit by month.
* Calculated the total sales per month and the running total of sales over time.
* Calculated the average number of orders per month and the moving average number of orders over time.
* Compared monthly sales of each category of products to its average sales and previous month's sales.
* Identified the categories that contribute the most to overall sales.
* Identified the states and cities that contribute the most to overall sales.
* Calculated the total number of customers by customer segments, i.e. VIP, Regular, and New Customers.
* Calculated the average selling price of products by product segments, i.e. Lower, Mid, and High Performers.
*(Detailed visual results are included in the Power BI report.)*

---

## **How to Run the Project**

### **Prerequisites**

* Python 3.x
* Jupyter Notebook or VS Code
* SQL Server
* Power BI Desktop

### **Steps**

1. Clone the repository
2. Open the Jupyter Notebook
3. Install required Python libraries:
   pip install pandas sqlalchemy pyodbc
4. Run the notebook to:
   * load raw data
   * perform data cleaning and transformation
   * build dimension and fact tables
   * push the tables to SQL Server
5. Use the stored procedure to set key fields as NOT NULL and primary and foreign key constraints in SQL Server
6. Execute the SQL queries to perform EDA and advanced analysis to reproduce business insights
8. Open the Power BI file to explore the final interactive report.

---
