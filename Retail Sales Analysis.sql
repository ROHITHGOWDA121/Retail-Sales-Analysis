-- RETAIL SALES ANALYSIS.

-- Set up a retail sales database: Create and populate a retail sales database with the provided sales data.

CREATE DATABASE retail_database;

use retail_database;

CREATE TABLE retail_sales
(
    transactions_id INT PRIMARY KEY,
    sale_date DATE,	
    sale_time TIME,
    customer_id INT,	
    gender VARCHAR(10),
    age INT,
    category VARCHAR(35),
    quantity INT,
    price_per_unit FLOAT,	
    cogs FLOAT,
    total_sale FLOAT
);

select * from retail_sales;

drop table retail_sales;

-- Generate entries
DELIMITER $$

CREATE PROCEDURE GenerateSalesData()
BEGIN
    DECLARE v_counter INT DEFAULT 1; -- Starting from the next transaction ID
    WHILE v_counter <= 2000 DO
        INSERT INTO retail_sales (transactions_id, sale_date, sale_time, customer_id, gender, age, category, quantity, price_per_unit, cogs)
        VALUES (
            v_counter,
            DATE_ADD('2024-01-01', INTERVAL FLOOR(RAND() * 300) DAY),
            SEC_TO_TIME(FLOOR(RAND() * 86400)),
            FLOOR(RAND() * 200) + 100,
            IF(RAND() < 0.5, 'Female', 'Male'),
            FLOOR(RAND() * 50) + 18,
            CASE
                WHEN RAND() < 0.3 THEN 'Electronics'
                WHEN RAND() < 0.6 THEN 'Appliances'
                WHEN RAND() < 0.8 THEN 'Furniture'
                ELSE 'Books'
            END,
            FLOOR(RAND() * 10) + 1,
            ROUND(RAND() * 1000, 2),
            ROUND(RAND() * 500, 2)
        );
        SET v_counter = v_counter + 1;
    END WHILE;
END$$

DELIMITER ;

CALL GenerateSalesData();
DROP PROCEDURE GenerateSalesData;

-- Calculate total_sale;
DELIMITER $$

Create Procedure GenerateTotalSales()
Begin
	Declare counter INT Default 1;
    while counter<=2000 DO
		UPDATE retail_sales set total_sale = (quantity * price_per_unit) where transactions_id = counter;
        SET counter = counter + 1;
	END WHILE;
END$$

DELIMITER ;

CALL GenerateTotalSales;
Drop Procedure GenerateTotalSales;

-- Exploratory Data Analysis (EDA): Perform basic exploratory data analysis to understand the dataset.
-- Record Count: Determine the total number of records in the dataset.
Select Count(*) as Total_Records 
from retail_sales;


-- Customer Count: Find out how many unique customers are in the dataset.
Select Count(Distinct(customer_id)) as No_of_Unique_Customers
from retail_sales;


-- Category Count: Identify all unique product categories in the dataset.
Select Distinct(category) as Categories
from retail_sales;

-- Data Cleaning: Identify and remove any records with missing or null values.
-- Null Value Check: Check for any null values in the dataset and delete records with missing data.
Delete from retail_sales
where transactions_id Is Null or
 sale_date is null or
 sale_time is null or
 customer_id is null or
 gender is null or
 age is null or
 category is null or
 quantity is null or
 price_per_unit is null or
 cogs is null or
 total_sale is null;
 
 -- Verifing the count of records after deleting the records with missing data.
 select count(*) as Remaining_Records from retail_sales;


-- Write a SQL query to retrieve all columns for sales made on '2024-10-05'.
Select * from retail_sales
where sale_date = "2024-10-05";


-- Write a SQL query to retrieve all transactions where the category is 'Furniture' and the quantity sold is more than 5 in the month of Oct-2024.
Select * from retail_sales
where category = "Furniture"
and quantity > 5
and sale_date between "2024-10-01" and "2024-10-30";


-- Write a SQL query to calculate the total sales (total_sale) for each category.
Select category, sum(total_sale) as TotalSalesForEachCategory
from retail_sales
group by category;


-- Write a SQL query to find the average age of customers who purchased items from the 'Books' category.
Select category, avg(age) as AverageAgeOfCustomers
from retail_sales
where category = "Books";


-- Write a SQL query to find all transactions where the total_sale is greater than 1000.
Select * from retail_sales
where total_sale > 1000;


-- Write a SQL query to find the total number of transactions (transaction_id) made by each gender in each category.
Select category, gender, count(transactions_id) as TotalTransactionByEachGender
from retail_sales
group by category, gender
order by category, gender;


-- Write a SQL query to calculate the average sale for each month. Find out best selling month.
Create view BestSellingMonth as
select monthname(sale_date) as Month, avg(total_sale) as AvgOfEachMonth,
Rank() over (order by avg(total_sale) desc) as ranking
from retail_sales
group by Month;

select Month as BestMonth, AvgOfEachMonth
from BestSellingMonth
where Ranking = 1;



-- Write a SQL query to find the top 5 customers based on the highest total sales.
Select customer_id, total_sale
from retail_sales
order by total_sale desc limit 5 offset 0;


-- Write a SQL query to find the number of unique customers who purchased items from each category.
Select category, count(Distinct(customer_id)) as NumberOfUniqueCustomers
from retail_sales
group by category
order by NumberOfUniqueCustomers;


-- Write a SQL query to create each shift and number of orders (Example Morning <12, Afternoon Between 12 & 17, Evening >17).
Select count(transactions_id) as NumberOfOrders,
case
when sale_time between "05:00:00" and "11:59:59" Then "Morning" 
when sale_time between "12:00:00" and "16:59:59" Then "Afternoon"
when sale_time between "17:00:00" and "23:59:59" Then "Evening"
else "Midnight"
end 
as Shifts
from retail_sales
group by Shifts;

-- Write a SQL query to find out best selling category.
Create view BestSellingCategory as
select Category, sum(total_sale) as TotalSales,
rank() over (order by sum(total_sale) desc) as Ranking
from retail_sales
group by Category;

select Category as BestSoldCategory, TotalSales
from BestSellingCategory
where Ranking = 1;


-- Write a SQL query to find the average age of customers who purchased items from the 'Electronics' category.
Select category, avg(age) as AverageAgeOfCustomers
from retail_sales
where category = "Electronics";

