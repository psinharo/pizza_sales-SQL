create database pizzahut;

create  table orders(
order_id int not null,
order_time time not null,
primary key(order_id));

create  table orders_details(
order_details_id int not null,
order_id int not null,
pizza_id text not null,
quantity int not null,
primary key(order_details_id));

select * from orders;
select * from orders_details;
select * from pizza_types;
select * from pizzas;

-- Retrieve the total number of orders placed.

select count(order_id) as total_orders from orders;

-- Calculate the total revenue generated from pizza sales
SELECT 
    ROUND(SUM(orders_details.quantity * pizzas.price),
            2) AS Total_revenue
FROM
    orders_details
        JOIN
    pizzas ON pizzas.pizza_id = orders_details.pizza_id

-- Identify the highest priced pizza
SELECT 
    pizza_types.name, pizzas.price
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
ORDER BY pizzas.price DESC
LIMIT 1;

-- Identify the most common pizza side ordered.
SELECT 
    pizzas.size,
    COUNT(orders_details.order_details_id) AS order_count
FROM
    pizzas
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizzas.size
ORDER BY order_count DESC
LIMIT 1;

-- list the top 5 most ordered pizza types 
-- along with their quantities
SELECT 
    pizza_types.name,
    SUM(orders_details.quantity) AS total_quantities
FROM
    pizza_types
        JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
        JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.name
ORDER BY total_quantities DESC
LIMIT 5;
    
-- Join the necessary tables to find the 
-- total quantity of each pizza category ordered


SELECT 
    pizza_types.category,
    SUM(orders_details.quantity) AS total_quantities
FROM
    pizza_types
       JOIN
    pizzas ON pizza_types.pizza_type_id = pizzas.pizza_type_id
    JOIN
    orders_details ON orders_details.pizza_id = pizzas.pizza_id
GROUP BY pizza_types.category;

-- determine the distribution of orders by hour of the day
select hour(order_time) as hour , count(order_id) AS order_count from orders
group by hour(order_time);

-- join the relevant tables to find the
--  category wise distribution of pizza
select category , count(name) from pizza_types
group by category;

--  group the orders by time and calculate the average 
-- number of pizzas ordered per hour 

select round(avg(avg_pizza_ordered_per_hour),0)  from (
select orders.order_time,sum(orders_details.quantity) as avg_pizza_ordered_per_hour
from orders join 
orders_details on orders.order_id=orders_details.order_id
group by orders.order_time) as ordered_per_hour;

-- determine the top 3 most ordered pizza types based on revenue
select pizza_types.name, sum(orders_details.quantity*pizzas.price) as total_revenue
from pizza_types join
pizzas
on pizzas.pizza_type_id= pizza_types.pizza_type_id join
orders_details on pizzas.pizza_id=orders_details.pizza_id
group by pizza_types.name order by total_revenue desc
limit 3;

-- Calculate the percentage contribution of each
-- pizza type to total revenue 
SELECT 
    pizza_types.category,
    ROUND(SUM(orders_details.quantity * pizzas.price) / (SELECT 
                    ROUND(SUM(orders_details.quantity * pizzas.price),
                                2) AS total_sales
                FROM
                    orders_details
                        JOIN
                    pizzas ON pizzas.pizza_id = orders_details.pizza_id) * 100,
            0) AS total_revenue
FROM
    pizza_types
        JOIN
    pizzas ON pizzas.pizza_type_id = pizza_types.pizza_type_id
        JOIN
    orders_details ON pizzas.pizza_id = orders_details.pizza_id
GROUP BY pizza_types.category
ORDER BY total_revenue DESC;

-- Analyze the cummlative revenue generated over time.

select order_time,
sum(total_revenue)over (order by order_time) as cum_revenue
from
(select orders.order_time,
sum(orders_details.quantity*pizzas.price) as total_revenue
from orders_details join pizzas on
orders_details.pizza_id=pizzas.pizza_id join
orders on orders.order_id= orders_details.order_id
group by orders.order_time) as sales;

-- Determine the top 3 most ordered pizza types
-- based on revenue for each pizza category.
select name, total_revenue from 
(select category,name,total_revenue,
rank() over (partition by category order by total_revenue desc) as rn 
from 
(select pizza_types.category,pizza_types.name, 
sum(orders_details.quantity* pizzas.price) as total_revenue
from pizza_types join pizzas on
pizza_types.pizza_type_id=pizzas.pizza_type_id join
orders_details on 
orders_details.pizza_id= pizzas.pizza_id
group by pizza_types.category,pizza_types.name) as a)as b
where rn<=3;

