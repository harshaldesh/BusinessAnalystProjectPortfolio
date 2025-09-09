--Create Table
CREATE TABLE ecommerce_data1 (
    order_id VARCHAR(50),
    customer_id VARCHAR(50),
    age INT,
    product_id VARCHAR(50),
    country VARCHAR(100),
    signup_date DATE,
    last_purchase_date DATE,
    cancellations_count INT,
    subscription_status VARCHAR(20),
    order_date DATE,
    unit_price DECIMAL(10,2),
    quantity INT,
    purchase_frequency INT,
    preferred_category VARCHAR(100),
    product_name VARCHAR(200),
    product_category VARCHAR(100),
    gender VARCHAR(10)
);

--inserting data into table
COPY ecommerce_data1(
    order_id,
    customer_id,
    age,
    product_id,
    country,
    signup_date,
    last_purchase_date,
    cancellations_count,
    subscription_status,
    order_date,
    unit_price,
    quantity,
    purchase_frequency,
    preferred_category,
    product_name,
    product_category,
    gender
)
FROM 'C:\Users\ADMIN\Desktop\ecommerce_data1.csv'
DELIMITER ','
CSV HEADER;

--checking data
select * from ecommerce_data1;



/*Data Cleaning*/


--  1) Check for missing values in each column

SELECT 
    COUNT(*) FILTER (WHERE order_id IS NULL) AS missing_order_id,
    COUNT(*) FILTER (WHERE customer_id IS NULL) AS missing_customer_id,
    COUNT(*) FILTER (WHERE age IS NULL) AS missing_age,
    COUNT(*) FILTER (WHERE product_id IS NULL) AS missing_product_id,
    COUNT(*) FILTER (WHERE signup_date IS NULL) AS missing_signup_date,
    COUNT(*) FILTER (WHERE last_purchase_date IS NULL) AS missing_last_purchase_date
FROM ecommerce_data1;


-- 2) Find duplicate orders
SELECT order_id, COUNT(*) 
FROM ecommerce_churn
GROUP BY order_id
HAVING COUNT(*) > 1;


--3) Check for invalid ages (e.g., negative values or unrealistically high values)

select age from ecommerce_data1 where age<0 or age>100;

--4) Check for invalid unit price or quantity

select unit_price,quantity from ecommerce_data1 where unit_price<0 or quantity<0;

-- 5) Standardize gender values

SELECT DISTINCT gender FROM ecommerce_churn;

--6) Check for invalid subscription status values

SELECT DISTINCT subscription_status FROM ecommerce_churn;

--7) Check for invalid date formats

SELECT signup_date, last_purchase_date, order_date from ecommerce_data1
WHERE signup_date IS NULL OR last_purchase_date IS NULL OR order_date IS NULL;



/*Data Analysis*/

--1) total Customers,orders,Revenue

select 
    count(DISTINCT customer_id) as total_customers,
    count(DISTINCT order_id) as total_orders,
    round(sum(unit_price*quantity)) as total_revenue
    from ecommerce_data1;

--2) Churn Rate (inactive or cancelled Subscription )

select 
    subscription_status,
    count(DISTINCT customer_id) as customer_count,
    round(100.0*count (DISTINCT customer_id) / (select count(DISTINCT customer_id) from ecommerce_data1),2) as percentage
    FROM ecommerce_data1
    GROUP BY subscription_status;

--3)  Average order Value (AOV)

select 
    round(avg(unit_price*quantity),1) as avg_order_value
    from ecommerce_data1;

--4) Orders by Country

select country,count(order_id) as Total_orders ,
    round(sum(unit_price*quantity)) as Total_revenue
       from ecommerce_data1 
       group by country
       order by total_revenue desc;


--5) Top 10 Products By revenue

select count(product_id) as total_products,
    product_name,
    round(sum(unit_price*quantity)) as Total_revenue
    from ecommerce_data1
    group by product_name
    order by total_revenue desc limit 10;



--6) Customer Purchase Frequency

select  
    count(DISTINCT customer_id) as customers,
    purchase_frequency,
    sum(unit_price*quantity) as revenue
    from ecommerce_data1
    group by purchase_frequency
    order by purchase_frequency;

--7)  Age group Distribution

select 
    case 
        when age <20 then 'Under 20'
        when age between 21 and 30 then '20-30'
        when age between 31 and 40 then '31-40'
        when age between 41 and 50 then '41-50'
        when age between 51 and 60 then '51-60'
        when age >60 then 'Above 60'
        else  '60+'
        end as age_group,
        count(DISTINCT customer_id) as total_customers
        from ecommerce_data1
        group by age_group
        order by total_customers ;

--8) "Age Group-wise Churn Analysis"

select SUBSCRIPTION_status,
 case 
        when age <20 then 'Under 20'
        when age between 21 and 30 then '20-30'
        when age between 31 and 40 then '31-40'
        when age between 41 and 50 then '41-50'
        when age between 51 and 60 then '51-60'
        when age >60 then 'Above 60'
        else  '60+'
        end as age_group
        from ecommerce_data1   
         group by subscription_status
        , age_group ;

--9) Monthly Revenue Trend 



SELECT 
    TO_CHAR(order_date, 'Mon-YYYY') AS month,
    SUM(unit_price * quantity) AS monthly_revenue
FROM ecommerce_data1
GROUP BY TO_CHAR(order_date, 'Mon-YYYY')
ORDER BY MIN(order_date);

--10) Customers With More than 2 Cancellations

SELECT customer_id, COUNT(*) AS orders, SUM(cancellations_count) AS total_cancels
FROM ecommerce_data1
GROUP BY customer_id
HAVING SUM(cancellations_count) > 2;

--11) Gender-Wise Revenue 

select gender,
    round(sum(unit_price*quantity)) as Total_revenue
    from ecommerce_data1
    group by gender
    order by total_revenue desc;

--12) prefereed categoory by Country

select country,preferred_category,
    count(*) as Total_orders
    from ecommerce_data1
    group by country,preferred_category
    order by total_orders desc;

--13) Customer Lifetime Value (CLV)

select customer_id,
    sum(unit_price*quantity) as  Lifetime_value
    from ecommerce_data1
    group by customer_id
    order by Lifetime_value desc limit 10;

--14) Churned customers with High Purchase Frequency

select customer_id,
     purchase_frequency,
     SUBSCRIPTION_status
from ecommerce_data1
where subscription_status='cancelled'
order by purchase_frequency desc LIMIT 10;

--15) Revenue Loss By cancellations

select 
    sum(unit_price*quantity) as revenue_loss
    from ecommerce_data1
    where subscription_status='cancelled';

--16) Top Countries By Churn Rate

SELECT 
    country,
    COUNT(DISTINCT customer_id) FILTER (WHERE LOWER(TRIM(subscription_status)) = 'cancelled') AS churned_customers,
    COUNT(DISTINCT customer_id) AS total_customers,
    ROUND(
        100.0 * COUNT(DISTINCT customer_id) FILTER (WHERE LOWER(TRIM(subscription_status)) = 'cancelled') 
        / NULLIF(COUNT(DISTINCT customer_id),0), 2
    ) AS churn_rate
FROM ecommerce_data1
GROUP BY country
ORDER BY churn_rate DESC;
