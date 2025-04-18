# 🛒 Sales Analysis SQL Project

## 📚 Project Overview

This project focuses on **Sales Analysis** using SQL queries on a dataset containing information about **Orders**, **Products**, and **Locations**.  
It includes tasks like data cleaning, view creation, aggregation queries, stored procedures, and detailed sales reporting based on different dimensions like product type, location, month, and day type (Weekdays/Weekends).

---

## 📂 Dataset Structure

- **Orders**  
- **Products**  
- **Location**


## 📊 Key Tasks Performed

### 1. Retrieve Full Order Details
- Joined **Orders**, **Products**, and **Location** tables.

### 2. Create and Alter a View
- Created a view `OrderDetails` that includes a new calculated column `sales_amt` (`transaction_qty * unit_price`).

### 3. Sales Analysis by Location
- Total Orders
- Total Sales Amount
- Average Sales Amount
- Sales figures formatted as **$ Currency**.

### 4. Top 5 Most Sold Products
- Listed and ranked products based on the quantity sold.

### 5. 4th Top Sold Product
- Retrieved the 4th ranked product based on quantity sold.

### 6. Month-on-Month Sales
- Aggregated sales data month-wise.

### 7. Orders in Last 7 Days
- Two approaches to fetch recent orders:
  - Using `MAX(transaction_date)`
  - Using `CURRENT_DATE - INTERVAL 7 DAY`

### 8. Sales for a Specific Product
- Sales performance of "Ethiopia Rg" across all store locations.

### 9. Orders with Higher Sales
- Retrieved orders where the `sales_amt` is greater than the average.

### 10. Products with Unit Price Less Than $5
- Two methods used:
  - Sub-query with `IN`
  - Sub-query with `EXISTS`

---

## 🛠 Stored Procedures Created

- **Top5sales**  
  → Displays Top 5 products based on total sales.

- **Top5sales_date(IN p_tdate DATE)**  
  → Displays Top 5 products sold on a specific date.

- **totalorders_date(IN p_tdate DATE, OUT total_orders INTEGER)**  
  → Returns total number of orders placed on a specific date.

---

## 📌 Tools and Technologies

- MySQL / MariaDB
- SQL Queries
- Views
- Stored Procedures
- Data Aggregations and Window Functions

