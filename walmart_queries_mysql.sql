Create Database Walmart;
use Walmart; 
show tables;
select count(*) from walmart_tb;
Select * from walmart_tb;

SELECT DISTINCT payment_method, count(*) from walmart_tb
group by payment_method;

Select count(distinct branch) from walmart_tb;
select min(quantity) from walmart_tb;


-- Business Problems
#Find different payment method and number of transaction, number of quantity sold 
Select payment_method, count(*) as no_of_transactions, sum(quantity) as Qty_sold
from walmart_tb
group by payment_method;

#, max(round(avg(rating),2))
-- Identify the highest rated category in each branch , displaying the branch, category
-- AVG rating

Select branch, category, avrg from 	
	(select  branch,category, round(avg(rating),2) as avrg,
	rank() over(partition by branch order by round(avg(rating),2)DESC) as ranks
	from walmart_tb
	group by branch, category) as  A
where ranks = 1
order by avrg Desc;

-- Identify the busiest day for each branch based on the number of transactions
select * from

(select branch, DAYNAME(STR_TO_DATE(date, '%d-%m-%Y')) AS day_name, count(*) as no_of_transaction,
rank () over(partition by branch order by count(*) desc) as ranks
from walmart_tb
group by 1, 2
order by 1,3 desc) as B
where ranks = 1;

-- calculate the total quantity of items sold  per payment method. List payment method and total quantity
Select payment_method,  sum(quantity) as Qty_sold
from walmart_tb
group by payment_method;

-- What are the average, minimum, and maximum ratings for each category in each city?
select * from walmart_tb;

select city, category, round(avg(rating),2) as avrg, min(rating) as minimum, max(rating) as maximum
from walmart_tb
group by 1,2
order by 1;

-- What is the total profit for each category, ranked from highest to lowest?
select category,round(sum(total),0) as revenue, round(sum(profit_margin*total),0) as total_profit
from walmart_tb
 group by 1
 order by total_profit desc;
 
 
 

 
 -- What is the most frequently used payment method in each branch?
With cte as (

 select branch, payment_method, count(*) as total_transactions,
 rank() over(partition by branch order by count(*) DESC) as ranks
 from walmart_tb
 group by 1,2)
 
 select * from cte
 where ranks = 1;
 
 
 
 select * from walmart_tb;
 -- How many transactions occur in each shift (Morning, Afternoon, Evening) across branches?
 Select branch,
 CASE
	WHEN Hour(STR_TO_DATE(time, '%H:%i:%s')) THEN 'Morning'
        WHEN Hour(STR_TO_DATE(time, '%H:%i:%s')) BETWEEN 12 AND 17 THEN 'Afternoon'
        ELSE 'Evening'
 END as shift,
 COUNT(*) AS num_invoices
FROM walmart_tb
GROUP BY branch, shift
ORDER BY branch, num_invoices DESC;


-- Identify 5 Branches with Highest Revenue Decline Year-Over-Year
WITH revenue_2022 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart_tb
    WHERE YEAR(STR_TO_DATE(date, '%d-%m-%Y')) = 2022
    GROUP BY branch
),
revenue_2023 AS (
    SELECT 
        branch,
        SUM(total) AS revenue
    FROM walmart_tb
    WHERE YEAR(STR_TO_DATE(date, '%d-%m-%Y')) = 2023
    GROUP BY branch
)
SELECT 
    r2022.branch,
    r2022.revenue AS last_year_revenue,
    r2023.revenue AS current_year_revenue,
    ROUND(((r2022.revenue - r2023.revenue) / r2022.revenue) * 100, 2) AS revenue_decrease_ratio
FROM revenue_2022 AS r2022
JOIN revenue_2023 AS r2023 
ON r2022.branch = r2023.branch
WHERE r2022.revenue > r2023.revenue
ORDER BY revenue_decrease_ratio DESC
LIMIT 5;