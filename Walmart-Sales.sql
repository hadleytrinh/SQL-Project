-- 1. Data Wrangling: This is the first step where inspection of data is done to make sure NULL values and missing values are detected and data replacement methods are used to replace, missing or NULL values.
-- 1.a Create Database WalmartSales
CREATE DATABASE IF NOT EXISTS walmartSales;

use walmartSales;
-- 1.b Create table and insert the data.
-- Import WalmartSale datasets 
ALTER TABLE sales
Rename COLUMN `Invoice ID` to invoice_id;

ALTER TABLE sales
Rename COLUMN `Customer type` to customer_type;

ALTER TABLE sales
Rename COLUMN `Product line` to product_line;

ALTER TABLE sales
Rename COLUMN `Unit price` to unit_price;

ALTER TABLE sales
Rename COLUMN `Tax 5%` to tax_pct;

ALTER TABLE sales
Rename COLUMN `gross margin percentage` to  gross_margin_pct;

ALTER TABLE sales
Rename COLUMN `gross income` to  gross_income;

-- We could also create a table named Sales with all the columns that match with the columns in the dataset and import only data from the dataset
-- 1.c Select columns with null values in them
-- There are no null values in our database as in creating the tables, we set NOT NULL for each field, hence null values are filtered out.

select * from sales;

-- 2. Feature Engineering: This will help use generate some new columns from existing ones.
-- 2.a Add a new column named time_of_day to give insight of sales in the Morning, Afternoon and Evening. This will help answer the question on which part of the day most sales are made.
select Time, 
(CASE
WHEN Time BETWEEN '00:00:00' AND '12:00:00' THEN "Morning"
WHEN Time BETWEEN '12:01:00' AND '6:00:00' THEN "Afternoon"
ELSE "Evening"
END
) AS time_of_day
from sales;
 
ALTER TABLE sales
ADD COLUMN time_of_day VARCHAR(20);

UPDATE Sales
SET time_of_day = (CASE
WHEN Time BETWEEN '00:00:00' AND '12:00:00' THEN "Morning"
WHEN Time BETWEEN '12:01:00' AND '16:00:00' THEN "Afternoon"
ELSE "Evening"
END);


-- 2.b Add a new column named day_name that contains the extracted days of the week on which the given transaction took place (Mon, Tue, Wed, Thur, Fri). This will help answer the question on which week of the day each branch is busiest.
select Date, DAYNAME(Date) AS day_name
from sales;

ALTER TABLE sales
ADD COLUMN day_name VARCHAR(10);

UPDATE Sales
SET day_name = DAYNAME(Date);

-- 2.c Add a new column named month_name that contains the extracted months of the year on which the given transaction took place (Jan, Feb, Mar). Help determine which month of the year has the most sales and profit.
select Date, MONTHNAME(Date) AS month_name
from sales;

ALTER TABLE sales
ADD COLUMN month_name VARCHAR(10);

UPDATE Sales
SET month_name = MONTHNAME(Date);

-- 3. Exploratory Data Analysis (EDA): Exploratory data analysis is done to answer the listed questions and aims of this project.
-- ------ GENERIC QUESTIONS -----------
-- How many unique cities does the data have? --
Select DISTINCT City
from sales;

-- In which city is each branch? --
Select DISTINCT City, Branch
from sales;

-- ------ PRODUCT -----------
-- How many unique product lines does the data have? --
Select DISTINCT product_line
from sales;

-- What is the most common payment method? -- 
Select Payment, Count(Payment) as count
from sales
group by Payment
order by count DESC;

-- What is the most selling product line? -- 
Select product_line, Count(product_line) as count
from sales
group by product_line
order by count DESC;

-- What is the total revenue by month? --
select month_name, sum(total) as total_revenue
from sales
group by month_name
order by total_revenue;

-- What month had the largest COGS? --
select month_name, sum(cogs) as total_cogs
from sales
group by month_name
order by total_cogs DESC;

-- What product line had the largest revenue? --
Select product_line, sum(total) as total_revenue
from sales
group by product_line
order by total_revenue DESC;

-- What is the city with the largest revenue? --
Select City, sum(total) as total_revenue
from sales
group by city
order by total_revenue DESC;

-- What product line had the largest VAT? --
Select product_line, avg(tax_pct) as avg_vat
from sales
group by product_line
order by avg_vat DESC;

-- Fetch each product line and add a column to those product line showing "Good", "Bad". Good if its greater than average sales --
Select product_line, avg(Quantity) as avg_sales, 
(CASE 
WHEN avg(Quantity) > (select avg(Quantity) from sales) then "Good"
ELSE "Bad"
END) as rating
from sales
group by product_line;

-- avg sale of all the product lines is 5.51 (select avg(Quantity) from sales)

-- Which branch sold more products than average product sold? -- 
select branch, sum(Quantity) as qty
from sales
group by branch
having sum(Quantity) > (select avg(Quantity) from sales);

-- What is the most common product line by gender? -- 
select Gender, product_line, count(product_line) as count_product_line
from sales
group by Gender, product_line
order by count_product_line DESC;

-- What is the average rating of each product line? --
select product_line, avg(Rating)
from sales
group by product_line;

-- ------- SALES -------
-- Number of sales made in each time of the day per weekday --
Select time_of_day, day_name, sum(Quantity) as total_sales
from sales
WHERE NOT day_name = "Saturday"
AND NOT day_name = "Sunday"
GROUP BY time_of_day, day_name
ORDER BY time_of_day DESC;

-- Which of the customer types brings the most revenue? -- 
select customer_type, sum(total) as total_revenue
from sales
GROUP BY customer_type
ORDER BY total_revenue DESC;

-- Which city has the largest tax percent/ VAT (Value Added Tax)? -- 
select City, avg(tax_pct) as avg_vat
from sales
group by City
order by avg_vat DESC;

-- Which customer type pays the most in VAT? -- 
select customer_type, avg(tax_pct) as avg_vat
from sales
GROUP BY customer_type
order by avg_vat DESC;

-- ------------ CUSTOMER ---------------
-- How many unique customer types does the data have
SELECT DISTINCT customer_type
from sales;

-- How many unique payment methods does the data have? -- 
SELECT DISTINCT Payment
from sales;

-- What is the most common customer type? -- 
SELECT customer_type, count(*) num_customer
from sales
group by customer_type
order by num_customer;

-- Which customer type buys the most? -- 
SELECT customer_type, sum(Quantity) as total_sales
from sales
group by customer_type
order by total_sales;

-- What is the gender of most of the customers? -- 
select Gender, count(*)
from sales
group by Gender;

-- What is the gender distribution per branch? -- 
select Branch, Gender, count(Gender) as num_gender
from sales
group by Branch, Gender
order by Branch;

-- Which time of the day do customers give most ratings? -- 
select time_of_day, avg(Rating) avg_rating
from sales
group by time_of_day
order by avg_rating DESC;

-- Which day fo the week has the best avg ratings?
select day_name, avg(Rating) avg_rating
from sales
group by day_name
order by avg_rating DESC;

-- Which day of the week has the best average ratings per branch?
select day_name, Branch, avg(Rating) avg_rating
from sales
group by day_name, Branch
order by avg_rating DESC;