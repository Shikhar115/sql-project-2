use dannys_diner;

CREATE TABLE sales (
  customer_id VARCHAR(1),
  order_date DATE,
  product_id INTEGER
);

INSERT INTO sales
  
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  product_id INTEGER,
  product_name VARCHAR(5),
  price INTEGER
);

INSERT INTO menu

VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  customer_id VARCHAR(1),
  join_date DATE
);

INSERT INTO members

VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');
  
 select * from sales; 
   select * from menu; 
    select * from members; 
  
  -- What is the total amount each customer spent at the restaurant? 
  
 select customer_id, sum(price) from sales join menu using(product_id) group by customer_id;
 
 -- How many days has each customer visited the restaurant?
 
 select customer_id , count(distinct(order_date)) from sales group by customer_id;
 
 -- What was the first item from the menu purchased by each customer?
 
 with cte as 
 ( select *,product_name as pd, row_number() over(partition by customer_id order by order_date) as rn 
 from sales join menu using(product_id) )
 select customer_id, product_name from cte where rn=1 group by customer_id;
 
 -- What is the most purchased item on the menu and how many times was it purchased by all customers?
 
 select product_name, count(product_id) as no_of_sales from sales join menu using(product_id) 
 group by product_id order by no_of_sales desc limit 1;
 
 -- Which item was the most popular for each customer?
 
 with cte as (
 select * ,row_number() over(partition by customer_id,product_id  ) as rn from sales join menu using(product_id))
 select customer_id, product_name from cte where (customer_id,rn) in (select customer_id, max(rn) from cte 
 group by customer_id) group by customer_id, product_name ;
 
-- Which item was purchased first by the customer after they became a member?

with cte as (
select * ,join_date-order_date as days from sales join menu using(product_id) join members using(customer_id) 
where join_date-order_date <=0 order by customer_id,order_date)
select customer_id, product_name from cte where (customer_id,days) in (select customer_id,max(days) from cte 
group by customer_id) group by customer_id, product_name order by customer_id;

-- Which item was purchased just before the customer became a member?

with cte as (
select * ,join_date-order_date as days from sales join menu using(product_id) join members using(customer_id) where join_date-order_date >0
order by customer_id,order_date)
select customer_id, product_name from cte where (customer_id,days) in (select customer_id,min(days) from cte group by customer_id) 
group by customer_id, product_name order by customer_id;

-- What is the total items and amount spent for each member before they became a member?

with cte as (
select * ,join_date-order_date as days from sales join menu using(product_id) join members using(customer_id) where join_date-order_date >0
order by customer_id,order_date)
select customer_id,count(product_id) as no_of_items_purchased,sum(price) as amount_spent from cte group by customer_id order by customer_id;

-- If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?

select customer_id,sum(case when product_name='sushi' then 2*price else price end ) as points 
 from sales join menu using(product_id) group by customer_id;

-- In the first week after a customer joins the program (including their join date) they earn 2x points on all items,
-- not just sushi - how many points do customer A and B have at the end of January?

with cte as (
select *,join_date-order_date as days , 2*price as points  
from sales join menu using(product_id) 
join members using (customer_id) where join_date-order_date <=0 and join_date-order_date >-7 order by customer_id )
select customer_id, sum(points) as total_points from cte group by customer_id order by customer_id;