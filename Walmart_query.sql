select * from walmart;

select count(*) from walmart;

-- Count payment methods and number of transactions by payment method
select payment_method,
count(*) no_transactions
from walmart
group by payment_method;

-- Count distinct branch 
select count(distinct(Branch)) no_branch from walmart;

-- Find the minimum quantity sold
select min(quantity) min_quantity from walmart;

-- Q1: Find different payment methods, number of transactions, and quantity sold by payment method

select payment_method,
count(*) no_transaction,
SUM(quantity) AS no_qty_sold
from walmart
group by payment_method;

-- Q2: Identify the highest-rated category in each branch Display the branch, category, and avg rating
select Branch,
category,
round(avg_rating,2) avg_rating
from (
select Branch, 
category,
avg(rating) avg_rating,
rank() over(partition by Branch order by avg(rating) desc) rnk
from walmart
group by Branch,category
) t
where rnk =1;

-- Q3: Identify the busiest day for each branch based on the number of transactions
select Branch,
no_transaction,
day_name 
from(
select 
Branch,
count(*) no_transaction,
dayname(str_to_date(date,'%d/%m/%y')) day_name,
rank() over(partition by Branch order by count(*)desc) rnk
from walmart
group by Branch,day_name
) t where t.rnk=1;

-- Q4: Calculate the total quantity of items sold per payment method
select 
payment_method,
sum(quantity) total_qty_sold
from walmart
group by payment_method;

-- Q5: Determine the average, minimum, and maximum rating of categories for each city
select
city,category,
round(avg(rating),2) avg_rating,
min(rating) min_rating,
max(rating) max_rating
from walmart
group by city,category;

-- Q6: Calculate the total profit for each category
select 
category,
round(sum(total_amount),2) total_amount,
round(sum(total_amount*profit_margin),2) total_profit
from walmart
group by category;

-- Q7: Determine the most common payment method for each branch
select Branch, payment_method
from (
select Branch,
payment_method,
count(*) total_count,
rank() over(partition by Branch order by count(*) desc) rnk
from walmart
group by Branch, payment_method
)t 
where rnk=1;

-- Q8: Categorize sales into Morning, Afternoon, and Evening shifts
select shift,
count(*) sales_count
from
(SELECT 
    CASE
        WHEN TIME(STR_TO_DATE(time, '%H:%i:%s')) < '12:00:00' THEN 'Morning'
        WHEN TIME(STR_TO_DATE(time, '%H:%i:%s')) BETWEEN '12:00:00' AND '17:59:59' THEN 'Afternoon'
        ELSE 'Evening'
    END AS shift
FROM walmart
)t
group by shift;

-- Q9: Identify the 5 branches with the highest revenue decrease ratio from last year to current year (e.g., 2022 to 2023)

select 
year(str_to_date(date,'%d/%m/%y'))
from walmart;

with revenue_2022 as
(
select Branch, 
sum(total_amount) revenue
from 
walmart
where year(str_to_date(date,'%d/%m/%y')) = 2022
group by Branch
),

revenue_2023 as
(
select Branch,
sum(total_amount) revenue
from walmart
where year(str_to_date(date,'%d/%m/%y')) =2023
group by Branch
)


select 
ls.Branch,
ls.revenue lst_yr,
cs.revenue crnt_yr,
round((ls.revenue-cs.revenue)/ls.revenue*100,2) decrese_ratio
from revenue_2022 ls
join revenue_2023 cs 
on ls.Branch = cs.Branch
where ls.revenue > cs.revenue
order by 4 desc
limit 5