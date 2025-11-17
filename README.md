# **Online Sales Analytics Project — README**

## **Overview**

This project analyzes online sales data to uncover insights that support data-driven decision-making. Using a dataset of **500 orders** across two initial tables (Orders and Details), the analysis explores trends in **revenue, orders, and profit** across different time periods, locations, customer types, payment modes, and product categories.

The workflow includes Exploratory Data Analysis (EDA) and data modeling in Python, SQL-based analytics, and the creation of an interactive Power BI report.

---

## **Datasets**

The project uses two raw datasets:

* **Orders Table**
  Contains high-level order information such as order date, customer type, city/state, and payment mode.

* **Details Table**
  Contains details such as product category, subcategory, price, quantity, and profit.

After modeling, the project produces four structured tables:

* **Fact Orders**
* **Dim Customer**
* **Dim Product**
* **Dim Date**

---

## **Tools & Technologies**

* **Python (Jupyter Notebook in VS Code)**
  Data loading, cleaning, transformation, modelling, table creation, and pushing to SQL Server.
* **Pandas**
  EDA and data modeling.
* **SQL Server**
  Data storage, relational modeling, and analytical SQL queries.
* **Power BI**
  Visual analytics and interactive reporting.

---

## **Process & Steps**

### **1. Data Loading**

* Loaded the Orders and Details tables using `pandas`.
* Inspected data types and verified keys before merging.

### **2. Initial Exploration**

* Checked dataframe structure, missing values, and key uniqueness.
* Understood relationships between orders, customers, products, and date.

### **3. Column Standardization**

* Renamed and standardized column names to improve readability and consistency.

### **4. Data Modeling**

Created a star schema consisting of:

* **Customer Dimension**
  Generated a surrogate key and standardized customer attributes.

* **Product Dimension**
  Added a surrogate key and consolidated product information.

* **Date Dimension**
  Built a full date table with year, quarter, month, and weekday attributes.

* **Orders Fact Table**
  Merged all relevant attributes from the two raw tables and dimensions, including a surrogate fact key.

### **5. Pushing Modeled Tables**

* Pushed all four tables (fact and dimensions) to SQL Server

### **6. SQL Server Integration**

* Connected to a SQL Server database.
* Ensured key fields were marked as `NOT NULL`.
* Set primary and foreign key constraints.

### **7. SQL Analysis**

Answered key business questions such as:

1. Top five months by revenue
2. Highest-performing quarter
3. Most profitable states and cities
4. Quantity sold on weekends vs. weekdays
5. Revenue comparison: returning vs. new customers
6. Three most popular payment modes by city
7. Top revenue-generating product categories and subcategories per month

### **8. Power BI Reporting**

* Imported the tables from SQL Server into Power BI.
* Performed additional analysis using DAX.
* Built the **Online Sales 2018 Interactive Report** for visualization.

---

## **Results (High-Level Summary)**

* Identified monthly and quarterly sales trends.
* Highlighted geographic areas generating the greatest profit.
* Compared customer segments (returning vs. new).
* Analyzed payment mode behavior by location.
* Ranked product categories and subcategories contributing most to revenue.

*(Detailed visual results are included in the Power BI report.)*

---

## **How to Run the Project**

### **Prerequisites**

* Python 3.x
* Jupyter Notebook or VS Code
* SQL Server
* Power BI Desktop

### **Steps**

1. Clone the repository.
2. Open the Jupyter Notebook.
3. Install required Python libraries:

   ```bash
   pip install pandas sqlalchemy pyodbc
   ```
4. Run the notebook to:
   * Load raw data
   * Perform EDA
   * Build dimension and fact tables
   * Push the tables to SQL Server
5. Ensured key fields were marked as `NOT NULL` in SQL Server.
6. Apply primary and foreign key constraints in SQL Server.
7. Execute the SQL queries to reproduce business insights.
8. Open the Power BI file to explore the final interactive report.

---
