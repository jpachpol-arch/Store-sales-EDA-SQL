SELECT * FROM `store_sales-sqleda`.sales2;

---- REMOVING DUPLICATES----
select transaction_id ,count(*)
from sales2
group by transaction_id
having count(transaction_id)>1;

WITH CTE AS (
SELECT *,
ROW_NUMBER() OVER (partition by transaction_id ORDER BY transaction_id) AS ROW_NUM
FROM sales2
)
SELECT * FROM CTE
WHERE ROW_NUM>1;

DELETE FROM sales2
WHERE transaction_id IN (
    SELECT transaction_id
    FROM (
        SELECT transaction_id,
               ROW_NUMBER() OVER (PARTITION BY transaction_id ORDER BY transaction_id) AS row_num
        FROM sales2
    ) t
    WHERE row_num > 1
);
 ----- change heaader names---
DESCRIBE sales2;

ALTER TABLE sales2
CHANGE COLUMN prce price FLOAT;

ALTER TABLE sales2
CHANGE COLUMN quantiy quantity int;

#check null - 

select * 
from sales2
where transaction_id IS NULL
OR
customer_id IS NULL
OR
customer_name IS NULL
OR
customer_age IS NULL
OR
gender IS NULL
OR 
product_id IS NULL
OR
product_name IS NULL
OR
product_category IS NULL
OR
quantity IS NULL
OR
price IS NULL
OR
payment_mode IS NULL
OR 
purchase_date IS NULL
OR
time_of_purchase IS NULL
OR
status IS NULL


SELECT 
    SUM(CASE WHEN transaction_id IS NULL THEN 1 ELSE 0 END) AS transaction_id_nulls,
    SUM(CASE WHEN customer_id IS NULL THEN 1 ELSE 0 END) AS customer_id_nulls,
    SUM(CASE WHEN customer_name IS NULL THEN 1 ELSE 0 END) AS customer_name_nulls,
    SUM(CASE WHEN customer_age IS NULL THEN 1 ELSE 0 END) AS customer_age_nulls,
    SUM(CASE WHEN gender IS NULL THEN 1 ELSE 0 END) AS gender_nulls,
    SUM(CASE WHEN product_id IS NULL THEN 1 ELSE 0 END) AS product_id_nulls,
    SUM(CASE WHEN product_name IS NULL THEN 1 ELSE 0 END) AS product_name_nulls,
    SUM(CASE WHEN product_category IS NULL THEN 1 ELSE 0 END) AS product_category_nulls,
    SUM(CASE WHEN quantity IS NULL THEN 1 ELSE 0 END) AS quantity_nulls,
    SUM(CASE WHEN price IS NULL THEN 1 ELSE 0 END) AS price_nulls,
    SUM(CASE WHEN payment_mode IS NULL THEN 1 ELSE 0 END) AS payment_mode_nulls,
    SUM(CASE WHEN purchase_date IS NULL THEN 1 ELSE 0 END) AS purchase_date_nulls,
    SUM(CASE WHEN time_of_purchase IS NULL THEN 1 ELSE 0 END) AS time_of_purchase_nulls,
    SUM(CASE WHEN status IS NULL THEN 1 ELSE 0 END) AS status_nulls
FROM sales2;

SELECT *
FROM sales2
WHERE transaction_id IS NULL OR transaction_id = ''
   OR customer_id IS NULL OR customer_id = ''
   OR customer_name IS NULL OR customer_name = ''
   OR customer_age IS NULL
   OR gender IS NULL OR gender = ''
   OR product_id IS NULL OR product_id = ''
   OR product_name IS NULL OR product_name = ''
   OR product_category IS NULL OR product_category = ''
   OR quantity IS NULL
   OR price IS NULL
   OR payment_mode IS NULL OR payment_mode = ''
   OR purchase_date IS NULL
   OR time_of_purchase IS NULL
   OR status IS NULL OR status = '';
   
   SELECT *
FROM sales2
WHERE customer_name IS NULL;

select * from sales2
where customer_name ='Damini Raju';  # #

update sales2
set customer_id ='CUST1401'
where transaction_id ='TXN985663';



select * from sales2
where transaction_id ='TXN432798'; 
SELECT * FROM sales2;

SELECT COUNT(*) FROM SALES2;

## FORMAT f TO FEMALE

SELECT DISTINCT GENDER FROM SALES2;


UPDATE SALES2
SET GENDER = 'F'
WHERE GENDER ='Female';

UPDATE SALES2
SET GENDER = 'M'
WHERE GENDER ='Male';

 SELECT DISTINCT payment_mode FROM SALES2;
UPDATE SALES2
SET payment_mode = 'Credit Card'
WHERE payment_mode ='CC';

#-----BUSINESS INSIGHTS --
# what are the top 5 most selling  products by quantity

select product_name, sum(quantity) as total_quantity
from sales2
where status ='Delivered'
group by product_name
order by total_quantity desc
limit 5;

# which products are most frequently cancelled

select product_name,  count(*) as total_cancelled
from sales2
where status ='cancelled'
group by product_name
order by total_cancelled desc
limit 5;

# -- what time ofthe day had highest no of purchase
select 
   case
       when hour(time_of_purchase) between 0 and 5  then 'NIGHT'
       when hour(time_of_purchase) between 6 and 11  then 'Morning'
       when hour(time_of_purchase) between 12 and 17  then 'NOON'
       when hour(time_of_purchase) between 18 and 23 then 'Evening'
	END AS TIME_OF_DAY,
    count(*) as total_orders
from sales2
group by
	  case
       when hour(time_of_purchase) between 0 and 5  then 'NIGHT'
       when hour(time_of_purchase) between 6 and 11  then 'Morning'
       when hour(time_of_purchase) between 12 and 17  then 'NOON'
       when hour(time_of_purchase) between 18 and 23 then 'Evening'
	END
order by total_orders desc;

SELECT * FROM sales2;
# --- who are the most top 5 highest spending customers

select customer_name, 
concat( '₹ ' , FORMAT(sum(price*quantity),2)) as total_spend
from sales2
group by customer_name
order by sum(price*quantity) desc
limit 5;

#---- WHICH PRODUCT CATEGORY GENERATES THE HIGHEST REVENUE
SELECT product_category, 
concat('₹ ', format(sum(price*quantity),2)) as Revenue
from sales2
group by product_category
order by sum(price*quantity) desc;


# -- what is the return / rate  cancellation rate per category

select product_category,
CONCAT(ROUND(count(case when status = 'cancelled' then 1 END)* 100.0 / COUNT(*),0), ' %') AS  CANCELLED_PERCENT
FROM SALES2
GROUP BY product_category
ORDER BY CANCELLED_PERCENT DESC;

select product_category,
CONCAT(ROUND(count(case when status = 'RETURNED' then 1 END)* 100.0 / COUNT(*),0),' %') AS  RETURN_PERCENT
FROM SALES2
GROUP BY product_category
ORDER BY RETURN_PERCENT DESC;

# -WHAT IS THE MOST PREFERRED PAYMENT MODE
SELECT * FROM SALES2;

SELECT PAYMENT_MODE, COUNT(*) As most_preferred
FROM SALES2
group by PAYMENT_MODE
order by most_preferred desc;

# -- how does age group affect business behavior
select min(customer_age), max(customer_age)
from sales2;

select 
     case 
     when customer_age between 18 and 25 then '18-25'
     when customer_age between 26 and 35 then '26-35'
      when customer_age between 36 and 50 then '36-50'
     else '51+'
  END AS cutomer_age,
concat('₹ ', format(SUM(price*quantity),2)) as total_purchase
from sales2
group by  cutomer_age
order by total_purchase desc;

# -- WHATS MONTHLY SALES TREND
SELECT 
date_format(PURCHASE_DATE,'%Y-%m') AS MONTH_YEAR,
concat(' ₹', format( SUM(PRICE*QUANTITY),2)) AS TOTAL_SALES,
format(SUM(quantity), 2) AS TOTAL_QUANTITY
FROM SALES2
GROUP BY MONTH_YEAR
order by MONTH_YEAR;

select
   year(purchase_date) as years,
   month(purchase_date) as months,
   concat(' ₹', format( SUM(PRICE*QUANTITY),2)) AS TOTAL_SALES,
format(SUM(quantity), 2) AS TOTAL_QUANTITY
FROM SALES2
GROUP BY years , months
order by months;

# are certain genders buying more specific categories
select * from sales2;
select gender , product_category, count(product_category) as total_purchase
from sales2
group by  gender,product_category
order by gender
   
;
