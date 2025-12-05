# **Online Sales Analytics Project — README**

## **Overview**

This project analyzes online sales data to uncover insights that support data-driven decision-making. Using a dataset of **500 orders** across two initial tables (Orders and Details), the analysis explores trends in **revenue, orders, and profit** across different time periods, locations, customer types, and product categories.

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
* **Dim Customer**
* **Dim Product**

---

## **Tools & Technologies**

* **Python (Jupyter Notebook in VS Code)**
  Data loading, cleaning, transformation, modelling, table creation, and pushing to SQL Server.
* **Pandas**
  EDA and data modeling.
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
  Generated a surrogate key and standardized customer attributes.

* **Products Dimension**
  Added a surrogate key and consolidated product information.

* **Orders Fact Table**
  Merged all relevant attributes from the two raw tables and the two dimension tables and added a surrogate fact key.

### **5. Pushing Modeled Tables**

* Pushed all three tables (fact and dimensions) to SQL Server.

### **6. SQL Server Integration**

* Connected to a SQL Server database.
* Ensured key fields were marked as NOT NULL.
* Set primary and foreign key constraints.

### **7. SQL EDA and Advanced Analysis**

Performed EDA, such as: 

1. 

Answered key business questions such as:

1. Top five months by revenue
2. Highest-performing quarter
3. Most profitable states and cities
4. Quantity sold on weekends vs. weekdays
5. Revenue comparison: returning vs. new customers
6. Three most popular payment modes by city
7. Top revenue-generating product categories and subcategories per month

### **8. Power BI Reporting**

* Imported the views created from SQL Server into Power BI.
* Created a date table using ... 
* Built an interative Online Sales report, including **Overview**, **Customers**, and **Products** pages.

---

## **Results (High-Level Summary)**

* Identified monthly and quarterly sales trends.
* Highlighted geographic areas generating the greatest profit.
* Compared customer segments (VIP, Regular, and New Cusotmers).
* ...
* ...

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

   ```
   pip install pandas sqlalchemy pyodbc
   ```
4. Run the notebook to:
   * Load raw data
   * Perform data cleaning and transformation
   * Build dimension and fact tables
   * Push the tables to SQL Server
5. Use the stored procedure to set key fields as NOT NULL and set primary and foreign key constraintsin in SQL Server
6. Execute the SQL queries to perform EDA and advanced analysis to reproduce business insights
8. Open the Power BI file to explore the final interactive report.

---
