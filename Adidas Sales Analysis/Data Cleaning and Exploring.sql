--CREATE TABLE adidas_sales 
CREATE TABLE adidas_sales (
    retailer VARCHAR(100),
    retailer_id INT,
    invoice_date DATE,
    region VARCHAR(50),
    state VARCHAR(50),
    city VARCHAR(50),
    product VARCHAR(100),
    price_per_unit DECIMAL(10,2),
    units_sold INT,
    total_sales VARCHAR(12),
    operating_profit VARCHAR(12),
    operating_margin VARCHAR(5),
    sales_method VARCHAR(50),
    gender VARCHAR(10),
    product_category VARCHAR(50)
);

-- Load data into the table from a CSV file
 COPY adidas_sales FROM '/path/to/your/adidas_sales_data.csv' DELIMITER ','
  
--SELECTING DATA
--View the first 10 rows of the dataset to understand its structure and contents.

select * from adidas_sales limit 10;

--CLEANING DATA

SELECT
    SUM(CASE WHEN retailer IS NULL THEN 1 ELSE 0 END) AS missing_retailer,
    SUM(CASE WHEN invoice_date IS NULL THEN 1 ELSE 0 END) AS missing_invoice_date,
    SUM(CASE WHEN product_category IS NULL THEN 1 ELSE 0 END) AS missing_product_category
FROM adidas_sales;
 
SELECT region, product_category, gender, SUM(total_sales) AS revenue
FROM adidas_sales
GROUP BY region, product_category, gender
ORDER BY revenue DESC;




---Which regions and states contribute the most to total sales and total profit?

select  state, region , sum(total_sales ) as revenue  , sum(operating_profit) as total_profit from adidas_sales group by  city,region, state  order by revenue, total_profit  desc ;


--What are the top 5 most profitable products, and what is their total profit?

select product ,sum(operating_profit) AS total_profit
from adidas_sales
GROUP BY product order by total_profit desc limit 5;

--How does the sales performance of online channels compare to in-store and outlet sales?


SELECT
    sales_method,
    ROUND(SUM(total_sales)) AS total_sales,
    SUM(units_sold) AS total_units_sold,
    SUM(operating_profit) AS total_profit
FROM
    adidas_sales
GROUP BY
    sales_method
ORDER BY
    total_sales DESC;



--What are the monthly sales trends over time, and are there any seasonal patterns?

SELECT
    DATE_TRUNC('month', invoice_date) AS sales_month,
    SUM(total_sales) AS total_monthly_sales
FROM
    adidas_sales
GROUP BY
    sales_month
ORDER BY
    sales_month;

--What is the average price of a unit sold, and how does it vary by product category?

select product_category, 
    ROUND(
         AVG(price_per_unit) )AS avg_unit_price
    from adidas_sales
    group by product_category 
    order by avg_unit_price desc;

--How does the profit margin differ between various product categories (e.g., Men's Apparel vs. Women's Footwear)?

SELECT product_category,gender,
    ROUND(
        (SUM(operating_profit) / NULLIF(SUM(total_sales), 0)) * 100
    ) AS profit_margin_percentage from adidas_sales GROUP BY gender,product_category order by profit_margin_percentage desc;


--Which retailers are performing above the overall average in terms of total sales?

select retailer,
    sum(total_sales) as retailer_total_sales FROM adidas_sales
    GROUP BY retailer 
    having sum(total_sales) > (select avg(total_sales) from adidas_sales)
    order by retailer_total_sales desc; 

--identifying retailers who have not made a purchase in the last 12 months?

select  retailer ,
    max(invoice_date) as last_purchase_date
    from adidas_sales 
    group by retailer
    having 
    max(invoice_date) < current_date - interval '12 months' 
    order by last_purchase_date asc;


--Calculating the Year-over-Year (YOY) growth from total sales for each product category.

 /* 1) Calculating total sales per product category per year */

WITH yearly_sales AS (
    SELECT
        EXTRACT(YEAR FROM invoice_date) AS sales_year,
        product_category,
        SUM(COALESCE(total_sales)) AS total_category_sales
    FROM
        adidas_sales
    GROUP BY
        sales_year,
        product_category
),

/* 2) comparing each year's sales to the previous year's sales 
using window fumction*/

yoy_comparison AS (
    SELECT
        sales_year,
        product_category,
        total_category_sales,
        LAG(total_category_sales, 1) OVER (
            PARTITION BY product_category
            ORDER BY sales_year
        ) AS previous_year_sales
    FROM
        yearly_sales
)
/* 3) calculating the YOY growth percentage */
 
select 
    sales_year,
    product_category,
    total_category_sales,
    previous_year_sales,
    Case 
        when previous_year_sales is null then null-- no growth first year 
        else 
          round( 
            (total_category_sales-previous_year_sales)*100.0 / nullif(previous_year_sales,0),2
          ) 
          end 
          as yoy_growth_percentage
    from yoy_comparison
    order by  
    product_category,sales_year ;
