-- SQL Ratail Sales Analysis
CREATE DATABASE retail_sales_p1;


-- Create TABLE
DROP TABLE IF EXISTS retail_sales;
CREATE TABLE retail_sales
            (
                transaction_id INT PRIMARY KEY,	
                sale_date DATE,	 
                sale_time TIME,	
                customer_id	INT,
                gender	VARCHAR(15),
                age	INT,
                category VARCHAR(15),	
                quantity	INT,
                price_per_unit FLOAT,	
                cogs	FLOAT,
                total_sale FLOAT
            );

-- CLEANING STAGE
SELECT * FROM retail_sales LIMIT 10

SELECT COUNT(1) FROM retail_sales


-- CHECK NULL
SELECT * FROM retail_sales 
WHERE 
	price_per_unit IS NULL 
	OR sale_date IS NULL
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR age IS NULL
	OR category IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL 
	OR total_sale IS NULL

-- DELETE NULL ROWS
DELETE FROM retail_sales
WHERE
	price_per_unit IS NULL 
	OR sale_date IS NULL
	OR sale_time IS NULL
	OR customer_id IS NULL
	OR gender IS NULL
	OR age IS NULL
	OR category IS NULL
	OR price_per_unit IS NULL
	OR cogs IS NULL 
	OR total_sale IS NULL

-- check duplicates
SELECT * FROM (SELECT ROW_NUMBER() OVER(PARTITION BY sale_date, sale_time, customer_id) as dup, * FROM retail_sales)
WHERE dup > 1



-- EXPLORATION 

-- Total sales
SELECT COUNT(1) total_sales FROM retail_sales

-- How many unique customers
SELECT COUNT(DISTINCT customer_id) as amount_unique_customers FROM retail_sales

-- Our category
SELECT DISTINCT category FROM retail_sales

-- DATA ANALYSIS QUESTIONS

-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05
-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the quantity sold is more than 10 in the month of Nov-2022
-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.
-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.
-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.
-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year
-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 
-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.
-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)





-- Q.1 Write a SQL query to retrieve all columns for sales made on '2022-11-05

SELECT * FROM retail_sales WHERE sale_date = '2022-11-05'

-- Q.2 Write a SQL query to retrieve all transactions where the category is 'Clothing' and the month of Nov-2022

SELECT * FROM retail_sales 
WHERE category = 'Clothing' 
AND TO_CHAR(sale_date, 'YYYY-MM') = '2022-11'

-- Q.3 Write a SQL query to calculate the total sales (total_sale) for each category.

SELECT category, SUM(total_sale), COUNT(1) as total_orders FROM retail_sales 
GROUP BY 1

-- Q.4 Write a SQL query to find the average age of customers who purchased items from the 'Beauty' category.

SELECT category, AVG(age)::int average_age, COUNT(1) as total_orders FROM retail_sales 
WHERE category = 'Beauty'
GROUP BY 1

-- Q.5 Write a SQL query to find all transactions where the total_sale is greater than 1000.

SELECT transaction_id, total_sale FROM retail_sales 
WHERE total_sale > 1000

-- Q.6 Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.

SELECT gender, category, COUNT(transaction_id) FROM retail_sales 
GROUP BY 1,2

-- Q.7 Write a SQL query to calculate the average sale for each month. Find out best selling month in each year

WITH CTE as (
	SELECT 
		ROUND(AVG(total_sale)::numeric, 2) as average_sale, 
		TO_CHAR(sale_date, 'YYYY') as year,
		TO_CHAR(sale_date, 'MM') as month FROM retail_sales
	GROUP BY 2, 3
	ORDER BY 2
)
SELECT average_sale, month, year FROM CTE
ORDER BY 1 DESC LIMIT 2

WITH CTE as (
	SELECT 
		EXTRACT(YEAR FROM sale_date) as year,
		EXTRACT(MONTH FROM sale_date) as month,
		ROUND(AVG(total_sale)::numeric, 2) as average_sale,
		RANK() OVER(PARTITION BY EXTRACT(YEAR FROM sale_date) ORDER BY ROUND(AVG(total_sale)::numeric, 2) DESC )
	FROM retail_sales
	GROUP BY 1, 2
)
SELECT year, month, average_sale, rank FROM CTE
WHERE rank = 1
ORDER BY 3 DESC


-- Q.8 Write a SQL query to find the top 5 customers based on the highest total sales 

SELECT customer_id, SUM(total_sale)
FROM retail_sales
GROUP BY 1
ORDER BY 2 DESC
LIMIT 5

-- Q.9 Write a SQL query to find the number of unique customers who purchased items from each category.

SELECT category, COUNT(DISTINCT customer_id)
FROM retail_sales
GROUP BY 1
ORDER BY 1

-- Q.10 Write a SQL query to create each shift and number of orders (Example Morning <=12, Afternoon Between 12 & 17, Evening >17)

SELECT *,
	CASE WHEN EXTRACT(HOUR from sale_time) < 12 THEN 'Morning'
	WHEN EXTRACT(HOUR from sale_time) BETWEEN 12 AND 17 THEN 'Afternoon'
	ELSE 'Evening'
	END as shift
FROM retail_sales
	

WITH shift as(
	SELECT *,
		CASE WHEN CAST(TO_CHAR(sale_time, 'HH24') AS INT) < 12 THEN 'Morning'
		WHEN CAST(TO_CHAR(sale_time, 'HH24') AS INT) BETWEEN 12 AND 17 THEN 'Afternoon'
		ELSE 'Evening'
		END as shift
	FROM retail_sales
)
SELECT shift, COUNT(*) as total_sales
FROM shift
GROUP BY 1


