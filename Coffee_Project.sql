SELECT * FROM location;
SELECT * FROM orders;
SELECT * FROM products;

DESCRIBE LOCATION;
DESCRIBE products;
DESCRIBE orders;

# Topics
-- trigers
-- index
-- temp table
-- stored routine
-- veriables
-- Customer Score , based on new order score shoud be increase

# DATA TYPE CHANGE

SET SQL_SAFE_UPDATES=0;
UPDATE orders
SET transaction_date = str_to_date(transaction_date,'%d-%m-%Y');

ALTER TABLE orders
MODIFY COLUMN transaction_date DATE;

UPDATE orders 
SET transaction_time = str_to_date(transaction_time,'%H:%i:%s');

ALTER TABLE orders
MODIFY COLUMN transaction_time TIME;
SET SQL_SAFE_UPDATES=1;


# 1. Retrieve all order details including product and location names.

SELECT 
	O.transaction_id , O.transaction_date, O.transaction_time , O.transaction_qty, O.store_id,O.product_id,
	L.store_location,
	P.unit_price, P.product_category, P.product_type, P.product_detail
FROM
	Orders AS O
INNER JOIN 
	location AS L ON L.store_id = O.store_id
INNER JOIN
	products as P ON P.product_id=O.product_id
ORDER BY O.transaction_id;


# 2. Create and ALter VIEW
  # i) Create a View by joinging all the table to reuse in other queries
  # ii) Update the VIEW by creating a new sales_amt column by Multipling the transaction_qty and unit_price   

-- Creating a VIEW to reuse the query
CREATE VIEW OrderDetails AS
SELECT 
	O.transaction_id , O.transaction_date, O.transaction_time , O.transaction_qty, O.store_id,O.product_id,
	L.store_location,
	P.unit_price, P.product_category, P.product_type, P.product_detail,
	O.transaction_qty*P.unit_price AS sales_amt
FROM
	Orders AS O
INNER JOIN 
	location AS L ON L.store_id = O.store_id
INNER JOIN
	products as P ON P.product_id=O.product_id
ORDER BY
	O.transaction_id;

-- Altering the VIEW
ALTER VIEW OrderDetails AS
SELECT 
	O.transaction_id , O.transaction_date, O.transaction_time , O.transaction_qty, O.store_id,O.product_id,
	L.store_location,
	P.unit_price, P.product_category, P.product_type, P.product_detail,
	O.transaction_qty*P.unit_price as sales_amt
FROM
	Orders AS O
INNER JOIN 
	location AS L ON L.store_id = O.store_id
INNER JOIN
	products as P ON P.product_id=O.product_id
ORDER BY
	O.transaction_id;

SELECT * FROM orderdetails;

# 3. Find the total orders , sales amount and average sales amount per location. 
# Note: Convert the sales amount to $ Currency format


SELECT
	store_id, store_location ,
    FORMAT(COUNT(transaction_id),0) AS Total_Order,
    CONCAT('$ ', format(SUM(sales_amt),0)) AS Sales_Amount,
    CONCAT('$ ', format(Avg(sales_amt),2)) AS Avg_Sales_Amount
FROM
	orderdetails
GROUP BY
	store_id,store_location
ORDER BY
	Sales_Amount DESC;

# 4. List the top 5 most sold products and RANK based on sold Qty

SELECT 
	product_id,
    product_type,
    SUM(transaction_qty) AS Sold_Qty,
    RANK() OVER (ORDER BY SUM(transaction_qty) DESC) AS Rank_Sold_Qty
FROM
	orderdetails
GROUP BY
	product_id, product_type
ORDER BY
	Sold_Qty DESC
LIMIT 5;

# 5. Find the 4th top most sold products and RANK based on sold Qty

SELECT 
	product_id,
    product_type,
    SUM(transaction_qty) AS Sold_Qty,
    RANK() OVER (ORDER BY SUM(transaction_qty) DESC) AS Rank_Sold_Qty
FROM
	orderdetails
GROUP BY
	product_id, product_type
ORDER BY
	Sold_Qty DESC
LIMIT 1
OFFSET 3;


# 6. Find the Month on month sales

SELECT 
	date_format(transaction_date,'%M-%Y') as Sales_Month,
    CONCAT('$ ', format(SUM(sales_amt),0)) as Sales_Amount
FROM
	orderdetails
GROUP BY
	date_format(transaction_date,'%M-%Y')
ORDER BY 
	MIN(transaction_date);
    
# 7.  Retrieve the details of orders placed in the last 7 days
SELECT *
FROM orderdetails
WHERE transaction_date >= (SELECT max(transaction_date) FROM orderdetails)-7
ORDER BY transaction_date;

-- Alternative Method
SELECT * 
FROM orderdetails
WHERE transaction_date >= CURRENT_DATE - INTERVAL 7 DAY
ORDER BY transaction_date;


#8. Find the total sales amount for a specific product across all locations.

SELECT 
	product_detail,
    store_location,
	SUM(sales_amt) AS Sales_Amount
FROM
	orderdetails
WHERE
	product_detail = 'Ethiopia Rg'
GROUP BY 
	product_detail, store_location;
    
# 9. Retrieve all orders where the sales amount is greater than the average sales amount.

SELECT *
FROM 
orderdetails
WHERE
sales_amt > (SELECT Avg(sales_amt) FROM orderdetails);

# 10. Retrieve all orders where the unit price is < 5.
-- Write 2 Different Query to get the same output using the Sub-query with EXISTS & IN)

-- SUB-QUERY with IN:

SELECT O.*
FROM orderdetails o
WHERE o.product_id IN (
	SELECT product_id
	FROM products
    WHERE unit_price < 5
);

-- SUB-QUERY with EXISTS:

SELECT O.*
FROM orderdetails o
WHERE 
	EXISTS
		(
        SELECT p.product_id
		FROM products p
        WHERE unit_price < 5
		AND o.product_id=p.product_id
);

# 11. Create a stored procedure to get the top 5 sold products

Delimiter $$
CREATE PROCEDURE Top5sales()
BEGIN
SELECT 
product_detail , format(sum(sales_amt),0) as Total_Sales
FROM orderdetails
GROUP BY product_detail
ORDER BY format(sum(sales_amt),0) DESC
limit 5;
END $$
DELIMITER ;

CALL Top5sales;

SELECT * FROM orderdetails;
# 12. Create a stored procedure with input parameter to get the top 5 sold products in a particular date

DELIMITER $$
CREATE PROCEDURE Top5sales_date(IN p_tdate DATE)
BEGIN
SELECT 
transaction_date,
product_detail,
format(sum(sales_amt),0) as Total_sales
FROM orderdetails
WHERE transaction_date=p_tdate
GROUP BY transaction_date, product_detail
ORDER BY sum(sales_amt) DESC
LIMIT 5;
END $$
DELIMITER ;

CALL Top5sales_date('2023-03-01');

# 13. Create a stored procedure with input & output parameter to get the total orders in a particular date

DROP PROCEDURE IF EXISTS totalorders_date;

	DELIMITER $$
	CREATE PROCEDURE totalorders_date(IN p_tdate DATE, OUT total_orders INTEGER)
	BEGIN
	SELECT 
	COUNT(transaction_id) INTO total_orders
	FROM orderdetails
	WHERE transaction_date=p_tdate;
	END $$
	DELIMITER ;

	CALL totalorders_date('2023-03-01',@total_orders);
    SELECT @total_orders as TOTAL_ORDERS;