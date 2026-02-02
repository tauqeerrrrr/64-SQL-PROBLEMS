CREATE DATABASE SUPERSTORDATA;
USE SUPERSTORDATA;
-- 🔹 Basic Filtering & Aggregation
select * FROM superstore;

CREATE TABLE superstore (
    Row_ID INT,
    Order_ID VARCHAR(20),
    Order_Date DATE,
    Order_Priority VARCHAR(20),
    Order_Quantity INT,
    Sales DECIMAL(10,2),
    Discount DECIMAL(5,2),
    Ship_Mode VARCHAR(50),
    Profit DECIMAL(10,2),
    Unit_Price DECIMAL(10,2),
    Shipping_Cost DECIMAL(10,2),
    Customer_Name VARCHAR(100),
    City VARCHAR(50),
    Zip_Code VARCHAR(10),
    State VARCHAR(50),
    Region VARCHAR(50),
    Customer_Segment VARCHAR(50),
    Product_Category VARCHAR(50),
    Product_Sub_Category VARCHAR(50),
    Product_Name VARCHAR(150),
    Product_Container VARCHAR(50),
    Product_Base_Margin DECIMAL(5,2),
    Ship_Date DATE
);

SELECT count(*) FROM sample_data;


-- 1.	Total sales and total profit by year.
select extract(year from `Order Date`) as year, sum(`Order Quantity`* `Unit Price`) as Total_Sales ,sum(Profit)as Profit from sample_data
group by extract(year from `Order Date`) order by 2 desc ;

UPDATE sample_data
SET `Order Date` = STR_TO_DATE(`Order Date`, '%d-%m-%Y');


alter table  sample_data
modify `Order Date` date;

ALTER TABLE sample_data 
MODIFY `Order Date` DATE;

delete from sample_data
where `Order Date`='07-01-2009';
alter table sample_data
modify `Order Date` varchar(50);

SELECT `Order Date`
FROM sample_data
WHERE STR_TO_DATE(`Order Date`, '%d-%m-%Y') IS NULL
  AND `Order Date` IS NOT NULL
  AND `Order Date` != '';

-- 2.	Total sales by region and state.
select Region,State,sum(`Order Quantity`* `Unit Price`) as Total_Sales from sample_data
group by 1 ,2 order by 3 desc ;

-- 3.	Average discount by product category.
select `Product Category`, avg(Discount) as discount from sample_data
group by 1;

-- 4.	Count total orders per customer segment.
select `Customer Segment`, count(`Order ID`) total_order from sample_data
group by 1 order by 2 desc;

-- 5.	Find top 10 cities by total sales
select City , sum(`Order Quantity`* `Unit Price`) as Total_Sales from sample_data
group by 1 order by 2 desc limit 10;


-- 6.	Show total profit by ship mode.
select `Ship Mode`, sum(Profit) as Total_profit from sample_data
group by 1 order by 2 desc ;

-- 7.	Find average shipping cost per region.

select * from sample_data;
select `Ship Mode`, avg(`Shipping Cost`) as avg_shiping from sample_data
group by 1 order by 2 desc ;


-- 8.	Calculate total order quantity per product category
select `Product Category`, sum(`Order Quantity`) Total_quantity  from sample_data
group by 1 order by 2 desc ;

-- 9.	List products with negative profit.
select `Product name` from sample_data
where Profit<0;


-- 10.	Find monthly sales trend.
select extract(month from `Order Date`) as month ,sum(`Order Quantity`* `Unit Price`) as Total_Sales  from sample_data
group by 1 order by 1  ;


select * from sample_data;

-- 11.	Regions where total profit is negative.
select Region, sum(Profit) as Total_profit from sample_data
group by Region

having sum(Profit) <0;
-- 🔹 GROUP BY + HAVING
-- 12.	Customers with more than 10 orders.
select `Customer Name`,count(`Order ID`) Total_order from sample_data
group by  `Customer Name` having count(`Order ID`) > 5;

-- 13.	Product sub-categories with average profit > 20%.


SELECT 
    `Product Sub-Category`,
    AVG(Profit) AS average_profit,
    (SUM(Profit) * 100.0) / (SELECT SUM(Profit) FROM sample_data) AS profit_percentage
FROM sample_data
GROUP BY `Product Sub-Category`
having (SUM(Profit) * 100.0) / (SELECT SUM(Profit) FROM sample_data) >20;
-- 14.	States with total sales greater than average sales.
select State, sum(Sales) as Total_Sales, avg(Sales) as Avrage_sales from sample_data
group by State 
having sum(Sales)>avg(Sales);


-- 15.	Cities contributing more than 5% of total sales.
select City, sum(Sales) as Total_sales , (sum(Sales)*100.0)/(select sum(Sales) from sample_data) from sample_data
group by 1 having (sum(Sales)*100.0)/(select sum(Sales) from sample_data) >5;


-- 🔹 Date Functions

-- 16.	Extract year and month from Order Date
select `Order Date`, extract(year from `Order Date`) as year , extract(month from `Order Date`) as month from sample_data;

-- 17.	Calculate delivery time (Ship Date – Order Date).
update  sample_data
set Ship_Date_New=
    DATE_ADD('1899-12-30', INTERVAL `Ship Date` DAY) ;



alter table sample_data
drop column `Ship Date`;

select * from sample_data;

select datediff( Ship_Date_New,`Order Date`) as difference from sample_data;

-- 18.	Find orders shipped in less than 2 days.
select `Order ID`, datediff( Ship_Date_New,`Order Date`) as day_dif from sample_data
where datediff( Ship_Date_New,`Order Date`) <2;

-- 19.	Quarterly sales trend.
select extract(quarter from `Order Date`) as quarter_number , sum(Sales) as Total_Sales from sample_data
where    extract(quarter from `Order Date`) is not null
group by extract(quarter from `Order Date`) order by 2 desc;


-- 20.	Year-wise profit growth.

select extract(year from `Order Date`) as year , sum(Profit) as Total_profit from sample_data
where extract(year from `Order Date`) is not null
group by 1 order by 2 desc ;

select * from sample_data;
-- 41.	Rank products by sales within each category.
select * from
(select * ,
dense_rank() over(partition by `Product Category` order by Total_Sales desc )as "rank_product" from
(select `Product Category`,`Product name`, sum(Sales) as Total_Sales from sample_data
group by `Product Category`,`Product name`) as t
) as  tr
where rank_product=1;

-- 42.	Top 3 customers by profit in each region.
with new_table as 
(select Region,`Customer Name`, sum(Profit) as Total_Profit from sample_data
group by Region,`Customer Name`),
second_table as (
select * ,
dense_rank() over (partition by Region order by Total_Profit desc) as "rank_customer"
from new_table)
select * from second_table
where 
rank_customer <4;

-- 43.	Running total of sales by date.
SELECT
    `Order Date`,
    SUM(Sales) AS Daily_Sales,
    SUM(SUM(Sales)) OVER (ORDER BY `Order Date`) AS Running_Total_Sales
FROM sample_data
GROUP BY `Order Date`
ORDER BY `Order Date`;

-- 44.	Year-over-year sales growth using LAG().

select year ,Total_sales, lag(Total_sales,1) over (order by year asc) as "lag_fun",
(Total_sales-lag(Total_sales,1) over (order by year asc))*100.0/Total_sales from
(select  extract(year from  `Order Date`) year , sum(Sales) as Total_sales from sample_data
where extract(year from  `Order Date`) is not null
group by extract(year from  `Order Date`) ) as t;

-- 45.	Compare current month vs previous month sales.
select Month, Total_sales, lag(Total_sales) over (order by Month asc) as "previous_month",
(Total_sales-lag(Total_sales) over (order by Month asc) ) as Campare
 from
(select extract(month from `Order Date`) as Month , sum(Sales) as Total_sales from 
sample_data

group by extract(month from `Order Date`) ) as t
where Month is not null;

-- 46.	Cumulative profit by state.
select Region,sum(Profit) as Total_profit,
sum(sum(Profit)) over (order by Region asc) as "cumulative"
 from sample_data 
 group by Region;
 
--  47.	Rank cities by average discount.
select City,avg_discount ,
dense_rank() over (order by avg_discount desc )as rank_discount 
from
(select City,avg(Discount) as avg_discount from sample_data
where Discount>0
group by City ) as t;

-- 48.	Find customers whose profit is decreasing YoY
SELECT *
FROM (
    SELECT
        year,
        `Customer Name`,
        Total_profit,
        LAG(Total_profit) OVER (
            PARTITION BY `Customer Name`
            ORDER BY year
        ) AS previous_year_profit,
        (Total_profit - LAG(Total_profit) OVER (
            PARTITION BY `Customer Name`
            ORDER BY year
        )) * 100.0
        / LAG(Total_profit) OVER (
            PARTITION BY `Customer Name`
            ORDER BY year
        ) AS YoY_Change_Percentage
    FROM (
        SELECT
            EXTRACT(YEAR FROM `Order Date`) AS year,
            `Customer Name`,
            SUM(Profit) AS Total_profit
        FROM sample_data
        GROUP BY year, `Customer Name`
    ) t1
) t2
WHERE Total_profit < previous_year_profit;


-- 49.	Identify first and last order date per customer.
SELECT
    `Customer Name`,
    `Order Date`,
    FIRST_VALUE(`Order Date`) OVER (
        PARTITION BY `Customer Name`
        ORDER BY `Order Date`
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS First_Order_Date,
    LAST_VALUE(`Order Date`) OVER (
        PARTITION BY `Customer Name`
        ORDER BY `Order Date`
        ROWS BETWEEN UNBOUNDED PRECEDING AND UNBOUNDED FOLLOWING
    ) AS Last_Order_Date
FROM sample_data;


select * from sample_data;

-- 50.	Percent contribution of each region to total sales.
select Region , Total_Sales, (Total_Sales)*100.0/sum(Total_Sales) over() as percetange    from (
select Region, sum(Sales) as Total_Sales from sample_data
group by Region ) as t
group by Region 
;

-- 51.	Products with sales higher than category average.
SELECT 
    `Product Name`,
    `Product Category`,
    SUM(Sales) AS Total_Sales
FROM sample_data s1
GROUP BY `Product Name`, `Product Category`
HAVING SUM(Sales) > (
    SELECT AVG(Sales)
    FROM sample_data s2
    WHERE s2.`Product Category` = s1.`Product Category`
);


-- 52.	Customers whose total sales exceed overall average.
select `Customer Name`, sum(Sales) as Total_Sales
from sample_data
group by `Customer Name` 
having sum(Sales) >(select avg(Sales) from sample_data);
-- 53.	Regions with profit less than global profit.
SELECT 
    Region,
    SUM(Profit) AS Region_Profit
FROM sample_data
GROUP BY Region
HAVING SUM(Profit) < (
    SELECT SUM(Profit)
    FROM sample_data
);

-- 54.	Orders where discount is higher than average discount of that product.
-- 55.	Cities with maximum sales in each state.
SELECT 
    State,
    City,
    Total_Sales
FROM (
    SELECT 
        State,
        City,
        SUM(Sales) AS Total_Sales
    FROM sample_data
    GROUP BY State, City
) t
WHERE (State, Total_Sales) IN (
    SELECT 
        State,
        MAX(Total_Sales)
    FROM (
        SELECT 
            State,
            City,
            SUM(Sales) AS Total_Sales
        FROM sample_data
        GROUP BY State, City
    ) s
    GROUP BY State
);


select * from sample_data;

-- 56.	Create CTE for yearly sales and calculate growth.
with new_table as 
(select extract(year from `Order Date`) as year , sum(Sales) as Total_sales 
from 
sample_data
where extract(year from `Order Date`) is not null
group by extract(year from `Order Date`))
select year , Total_sales,
lag(Total_sales,1) over (order by year asc) as Previous_year,
(Total_sales-lag(Total_sales,1) over (order by year asc))*100.0/Total_sales
from new_table ;

-- 57.	CTE to calculate profit margin per product
with new_table as 
(select `Product name`  , sum(Sales) as Total_sales ,sum(Profit) as Total_profit from sample_data
group by `Product name`)
select `Product name`, Total_sales,Total_profit, 
(Total_profit*100.0/Total_sales)   as Profit_mergin
 from new_table ;

-- 58.	Identify loss-making products using CTE.
with new_table as 
(select `Product name`  , sum(Sales) as Total_sales ,sum(Profit) as Total_profit from sample_data
group by `Product name`) ,new_table2 as (
select `Product name`, Total_sales,Total_profit, 
(Total_profit*100.0/Total_sales)   as Profit_mergin
 from new_table )
 select * from new_table2
 where Profit_mergin<0;
 
 
--  59.	Multi-CTE to calculate customer lifetime value.
WITH customer_orders AS (
    SELECT
        `Customer ID`,
        `Customer Name`,
        COUNT(DISTINCT `Order ID`) AS total_orders,
        SUM(Sales) AS total_sales,
        SUM(Profit) AS total_profit
    FROM sample_data
    GROUP BY `Customer ID`, `Customer Name`
),

customer_lifespan AS (
    SELECT
        `Customer ID`,
        MIN(`Order Date`) AS first_order_date,
        MAX(`Order Date`) AS last_order_date,
        DATEDIFF(MAX(`Order Date`), MIN(`Order Date`)) / 365.0 AS customer_lifetime_years
    FROM sample_data
    GROUP BY `Customer ID`
),

clv_calculation AS (
    SELECT
        co.`Customer ID`,
        co.`Customer Name`,
        co.total_orders,
        co.total_sales,
        co.total_profit,
        cl.customer_lifetime_years,
        (co.total_sales / NULLIF(cl.customer_lifetime_years, 0)) AS revenue_clv,
        (co.total_profit / NULLIF(cl.customer_lifetime_years, 0)) AS profit_clv
    FROM customer_orders co
    JOIN customer_lifespan cl
        ON co.`Customer ID` = cl.`Customer ID`
)

SELECT *
FROM clv_calculation
ORDER BY profit_clv DESC;

-- 60.	CTE to find top 5 profitable products per year.
WITH yearly_profit AS (
    SELECT
        EXTRACT(YEAR FROM `Order Date`) AS year,
        `Product name` AS product_name,
        SUM(Profit) AS total_profit
    FROM sample_data
    GROUP BY year, product_name
),
ranked_products AS (
    SELECT
        year,
        product_name,
        total_profit,
        DENSE_RANK() OVER (
            PARTITION BY year
            ORDER BY total_profit DESC
        ) AS profit_rank
    FROM yearly_profit
)
SELECT
    year,
    product_name,
    total_profit
FROM ranked_products
WHERE profit_rank <= 5
ORDER BY year, total_profit DESC;

-- 61.	Create view for region-wise sales summary.
create view first_view as  (
select Region, sum(Sales) as Total_Sales from sample_data
group by Region);
 
 select * from first_view;
 
 
--  62.	Create view for customer performance.
CREATE VIEW customer_performance AS(
SELECT
    `Customer Name`,
    COUNT(DISTINCT `Order ID`) AS total_orders,
    SUM(Sales) AS total_sales,
    SUM(Profit) AS total_profit,
    AVG(Sales) AS avg_order_value
FROM sample_data
GROUP BY `Customer Name`);


select * from customer_performance;


-- 63.	Index optimization for Order Date queries.
CREATE INDEX idx_order_date
ON sample_data (`Order Date`);

-- 64.	Composite index on (Region, Order Date).
create index first_index on
sample_data(`Region`, `Order Date`);



select * from sample_data;

alter table sample_data
add column Discount_1 float4;

alter table sample_data
drop column Discount;


