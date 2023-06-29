USE magist;

-- Question 1: How many orders are there in the dataset
select * from orders;
select count(order_id) from orders;
select count(distinct customer_id) from orders;

-- Question 2: Are the orders actually delivered?
select * from orders;
select distinct order_status from orders;
select order_status, count(order_id) from orders group by order_status order by count(order_id) desc;

-- Question 3: Is Magist having user growth?
select * from orders;
select year(order_purchase_timestamp) as Year_, 
month(order_purchase_timestamp) as Month_, count(customer_id) from orders group by Year_, Month_ order by Year_, Month_;
select year(order_purchase_timestamp) as Year_, month(order_purchase_timestamp) as Month_, count(order_id) from orders group by Year_, Month_ order by Year_, Month_;
-- no differences in counts by customers or order id

-- Question 4: How many products are there in the products table?
select * from products;
select count( distinct product_id) from products;
select count(product_id) from products;

-- Question 5: Which are the categories with the most products?
select product_category_name, count(product_id) from products group by product_category_name;
select product_category_name_english, products.product_category_name, count( distinct product_id) from products 
left join product_category_name_translation on products.product_category_name = product_category_name_translation.product_category_name 
group by product_category_name order by count(distinct product_id) desc;

-- Question 6: How many of those products were present in the actual transactions?
select * from order_items order by order_id;
select count(product_id) from order_items;
select count(distinct product_id) from order_items;

-- Question 7: What's the price for the most expensive and cheapest products?
select * from order_items;
select oi.product_id, max(price), product_category_name_english from order_items oi
Left JOIN products p ON oi.product_id = p.product_id
LEFT JOIN product_category_name_translation pc ON  p.product_category_name = pc.product_category_name
group by product_id order by max(price) desc
;
select product_id, min(price) from order_items group by product_id order by min(price);
select min(price) as cheapest, max(price) as most_expensive from order_items;

-- Question 8: What are the higest and lowest payment values?
select * from order_payments;
select order_id, max(payment_value) from order_payments group by order_id order by max(payment_value) desc;
select order_id, min(payment_value) from order_payments group by order_id order by min(payment_value);
select min(payment_value), max(payment_value) from order_payments;


-- MY QUESTIONS
-- How many customers are there
select count(customer_id) from customers;
select * from customers; 

-- Reviews
select * from order_reviews order by review_score;
select count(*) from order_reviews;
select * from order_reviews where review_comment_title like('% n_o entregue%');
select count(*) from order_reviews where review_comment_title like('% n_o entregue%');
-- > 75  comments with no delivery

select review_score, review_comment_title, review_comment_message, product_category_name_english from order_reviews ore
LEFT JOIN order_items oi ON ore.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
 where review_comment_title like('% n_o entregue%');
 
 select count(review_score) as amount_reviews, product_category_name_english from order_reviews ore
LEFT JOIN order_items oi ON ore.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
 where review_comment_title like('% n_o entregue%')
 group by product_category_name_english
 order by amount_reviews desc;
 
 select count(review_score) as amount_reviews, product_category_name_english from order_reviews ore
 LEFT JOIN order_items oi ON ore.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
 where review_score between 1 and 2 and review_comment_title like('% n_o entregue%')
   group by product_category_name_english
   order by amount_reviews desc;

select * from order_reviews order by review_score;
select count(*) from order_reviews where review_score between 1 and 3;
select count(*) from order_reviews; 
-- 98371 reviwes in total and 22849 reviews between 1-3, 14729 reviews between 1 and 2 --> 23% reviews between 1-3
select count(*) from order_reviews where review_score between 1 and 2;
select count(*) from order_reviews where review_score between 4 and 5;

select * from order_reviews where review_score like('5');

select * from orders; 
select *from orders where order_status NOT IN('delivered') order by order_status;
-- generell lange Lieferzeiten (~ 3 Wochen?!)

-- ANSWER BUSINESS QUESTIONS
-- In relation to the products:
-- What categories of tech products does Magist have?
select product_category_name_english, products.product_category_name, count( distinct product_id) from products 
left join product_category_name_translation on products.product_category_name = product_category_name_translation.product_category_name 
group by product_category_name order by count(distinct product_id) desc;
-- computers_accessories, telephony, electronics, home_appliances, consoles_games, small_appliances, home_appliances_2, computers, pc_gamer

-- How many products of these tech categories have been sold (within the time window of the database snapshot)?
select * from order_items;
select count(*) from order_items;
-- 112650

select product_category_name_english, count(product_category_name_english) from product_category_name_translation
Left join products on product_category_name_translation.product_category_name = products.product_category_name
left join order_items on products.product_id = order_items.product_id where product_category_name_english in('audio', 'consoles_games', 
'electronics', 'computers', 'computers_accessories', 'pc_gamer', 'telephony', 'tablets_printing_image')  group by product_category_name_english;

SELECT COUNT(*) AS n_orders
FROM order_items
LEFT JOIN products p ON p.product_id = order_items.product_id
LEFT JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
where product_category_name_english in ("audio", "computers", "consoles_games", "pc_gamer",
                        "electronics", "computers_accessories", "telephony", "tablets_printing_image");

-- 16935 --> What percentage does that represent from the overall number of products sold? %

select(
SELECT COUNT(*) AS n_orders
FROM order_items
LEFT JOIN products p ON p.product_id = order_items.product_id
LEFT JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
where product_category_name_english in ("audio", "computers", "consoles_games", "pc_gamer",
                        "electronics", "computers_accessories", "telephony", "tablets_printing_image"))
                        *100/112650;
                        
                        -- 15%

                        
-- What’s the average price of the products being sold?
select * from order_items;
select round(avg(price)) from order_items;

-- Are expensive tech products popular?
select * from order_items;

select order_id, order_items.product_id, price, product_category_name_english, 
case when price < 110 then 'low'
when price >= 110 and price < 130 then 'average'
else 'high'
end as Price_Category
from order_items
Left Join products on order_items.product_id = products.product_id
left join product_category_name_translation on products.product_category_name = product_category_name_translation.product_category_name
where product_category_name_english in('audio', 'console_games', 'electronics', 'computers', 'computer_accessories', 'pc_gamer', 'telephony', 'tablet_printing_image');

select count(*),
case when price < 110 then 'low'
when price >= 110 and price < 130 then 'average'
else 'high'
end as Price_Category
from order_items
Left Join products on order_items.product_id = products.product_id
left join product_category_name_translation on products.product_category_name = product_category_name_translation.product_category_name
where product_category_name_english in('audio', 'console_games', 'electronics', 'computers', 'computer_accessories', 'pc_gamer', 'telephony', 'tablet_printing_image') 
group by Price_Category;



/*
SELECT
  COUNT(*) AS total_orders,
  SUM(CASE
  WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1
  ELSE 0
  END) AS on_time_orders,
  COUNT(*) - SUM(CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1
  ELSE 0
  END) AS delayed_orders
FROM orders;
*/

-- In relation to the seller:
-- How many months of data are included in the magist database?
select year(order_purchase_timestamp) as Year_, 
month(order_purchase_timestamp) as Month_, count(customer_id) from orders group by Year_, Month_ order by Year_, Month_;
select year(order_purchase_timestamp) as Year_, month(order_purchase_timestamp) as Month_, count(order_id) from orders group by Year_, Month_ order by Year_, Month_;
-- 25 Monate

SELECT TIMESTAMPDIFF(MONTH, MIN(order_purchase_timestamp), MAX(order_purchase_timestamp)) AS months_of_data 
FROM orders;

-- How many sellers are there? How many Tech sellers are there? What percentage of overall sellers are Tech sellers?
select count(*) from sellers;
-- 3095 sellers

SELECT 
      count(DISTINCT s.seller_id) AS tech_sellers
      FROM sellers s
      LEFT JOIN order_items oi ON s.seller_id = oi.seller_id
      Left JOIN products p ON oi.product_id = p.product_id
      LEFT JOIN product_category_name_translation pt ON pt.product_category_name = p.product_category_name 
      WHERE product_category_name_english IN ('audio', 'consoles_games', 'electronics', 'computers', 'computers_accessories', 'pc_gamer','telephony','tablets_printing_image')
;

select (
SELECT 
      count(DISTINCT s.seller_id) AS tech_sellers
      FROM sellers s
      LEFT JOIN order_items oi ON s.seller_id = oi.seller_id
      INNER JOIN products p ON oi.product_id = p.product_id
      INNER JOIN product_category_name_translation pt ON pt.product_category_name = p.product_category_name 
      WHERE product_category_name_english IN ('audio', 'consoles_games', 'electronics', 'computers', 'computers_accessories', 'pc_gamer','telephony','tablets_printing_image'))
      *100/3095;
      
      -- 15.4%
      
      
select * from sellers;

-- What is the total amount earned by all sellers? What is the total amount earned by all Tech sellers?
select round(sum(price)) from order_items;
-- 13.591.643,70

SELECT 
      sum(price)
      FROM sellers s
      LEFT JOIN order_items oi ON s.seller_id = oi.seller_id
      INNER JOIN products p ON oi.product_id = p.product_id
      INNER JOIN product_category_name_translation pt ON pt.product_category_name = p.product_category_name 
      WHERE product_category_name_english IN ('audio', 'consoles_games', 'electronics', 'computers', 'computers_accessories', 'pc_gamer','telephony','tablets_printing_image');
      
      -- 1.836.059,80
      
      -- Can you work out the average monthly income of all sellers? Can you work out the average monthly income of Tech sellers?
      select count(seller_id) from sellers;
      
      
	SELECT 
		YEAR(order_purchase_timestamp) AS Year_, 
		MONTH(order_purchase_timestamp) AS Month_, ROUND(SUM(price)/COUNT(s.seller_id)) 
      FROM sellers s
      LEFT JOIN order_items oi ON s.seller_id = oi.seller_id
      INNER JOIN orders o ON oi.order_id = o.order_id
      INNER JOIN products p ON oi.product_id = p.product_id
      INNER JOIN product_category_name_translation pt ON pt.product_category_name = p.product_category_name 
      GROUP BY Year_, Month_ ORDER BY Year_, Month_;
      
     select count(distinct s.seller_id) from sellers s
     LEFT JOIN order_items oi ON oi.seller_id = s.seller_id
     LEFT JOIN products p ON oi.product_id = p.product_id
     LEFT JOIN product_category_name_translation pc ON p.product_category_name = pc.product_category_name
     WHERE product_category_name_english IN ('audio', 'consoles_games', 'electronics', 'computers', 'computers_accessories', 'pc_gamer','telephony','tablets_printing_image'); 
      
  	SELECT 
		YEAR(order_purchase_timestamp) AS Year_, 
		MONTH(order_purchase_timestamp) AS Month_, ROUND(SUM(price)/477) as avg_price
      FROM sellers s
      LEFT JOIN order_items oi ON s.seller_id = oi.seller_id
      INNER JOIN orders o ON oi.order_id = o.order_id
      INNER JOIN products p ON oi.product_id = p.product_id
      INNER JOIN product_category_name_translation pt ON pt.product_category_name = p.product_category_name 
	WHERE product_category_name_english IN ('audio', 'consoles_games', 'electronics', 'computers', 'computers_accessories', 'pc_gamer','telephony','tablets_printing_image')
      GROUP BY Year_, Month_ ORDER BY Year_, Month_;
      
          

-- In relation to the delivery time:
-- What’s the average time between the order being placed and the product being delivered?
select * from orders;
select order_id, datediff(order_delivered_customer_date, order_purchase_timestamp) as time_diff_in_days from orders order by time_diff_in_days desc;

select avg(datediff(order_delivered_customer_date, order_purchase_timestamp)) as time_diff_in_days from orders;
-- 12,5

SELECT AVG(TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)) as average_delivery_time_in_days
FROM orders;


-- How many orders are delivered on time vs orders delivered with a delay?
select * from orders;

SELECT
  COUNT(*) AS total_orders,
  SUM(CASE
  WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1
  ELSE 0
  END) AS on_time_orders,
  COUNT(*) - SUM(CASE WHEN order_delivered_customer_date <= order_estimated_delivery_date THEN 1
  ELSE 0
  END) AS delayed_orders
FROM orders
WHERE order_status = 'delivered';

-- Is there any pattern for delayed orders, e.g. big products being delayed more often?
SELECT *, 
product_length_cm*product_height_cm*product_width_cm AS product_vol 
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
HAVING (TIMESTAMPDIFF(DAY, order_purchase_timestamp, order_delivered_customer_date)>10)
ORDER BY product_vol DESC
; 

SELECT *, 
product_length_cm*product_height_cm*product_width_cm AS product_vol 
FROM products p
LEFT JOIN order_items oi ON p.product_id = oi.product_id
LEFT JOIN orders o ON oi.order_id = o.order_id
ORDER BY product_vol DESC
; 

select pc.product_category_name_english, 
        count(*) as n_deleyed_delivery
	

from order_items
inner join orders on orders.order_id = order_items.order_id
INNER JOIN products as p ON p.product_id = order_items.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
where datediff(orders.order_estimated_delivery_date, orders.order_delivered_customer_date) < 0 
and orders.order_status = "delivered"
group by pc.product_category_name_english 
order by n_deleyed_delivery desc;

select pc.product_category_name_english, 
        orders.order_estimated_delivery_date, 
        orders.order_delivered_customer_date,
    (select
        datediff(orders.order_estimated_delivery_date, orders.order_delivered_customer_date) 
        having datediff(orders.order_delivered_customer_date, orders.order_estimated_delivery_date) > 0) 
        as time_on_delayed_delivery

from order_items
inner join orders on orders.order_id = order_items.order_id
INNER JOIN products as p ON p.product_id = order_items.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
where datediff(orders.order_delivered_customer_date, orders.order_estimated_delivery_date) > 0 
and orders.order_status = "delivered"
order by time_on_delayed_delivery;

select pc.product_category_name_english, 
        count(*) as n_items_orders,
        COUNT(
            IF( orders.order_delivered_customer_date > orders.order_estimated_delivery_date, 
                orders.order_id, NULL)
        ) as n_delayed_deliveries,
        ROUND(COUNT(
            IF( orders.order_delivered_customer_date > orders.order_estimated_delivery_date, 
                orders.order_id, NULL)
            ) / count(*) * 100) as avg_delayed_deliveries
from order_items
inner join orders on orders.order_id = order_items.order_id
INNER JOIN products as p ON p.product_id = order_items.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
and orders.order_status = "delivered"
group by pc.product_category_name_english 
order by avg_delayed_deliveries desc;

select * from order_reviews;

select o.order_id, order_status, 
order_purchase_timestamp, 
order_delivered_customer_date, 
order_estimated_delivery_date, 
timestampdiff(day, order_delivered_customer_date, order_estimated_delivery_date), 
product_category_name_english  
from orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation pc ON p.product_category_name = pc.product_category_name
where order_status = 'delivered';

select count(*),
product_category_name_english  
from orders o
LEFT JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation pc ON p.product_category_name = pc.product_category_name
where order_status = 'delivered'
Group by product_category_name_english
order by product_category_name_english;

select count(*) as amount_of_delivered_items, product_category_name_english from orders o
RIGHT JOIN order_items oi ON o.order_id = oi.order_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation pc ON p.product_category_name = pc.product_category_name
where order_status = 'delivered'
group by product_category_name_english
order by product_category_name_english;

 select count(review_score) as amount_reviews, product_category_name_english from order_reviews ore
LEFT JOIN order_items oi ON ore.order_id = oi.order_id
INNER JOIN orders o ON oi.order_id = o.order_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
 where order_status = 'delivered' and timestampdiff(day, order_delivered_customer_date, order_estimated_delivery_date) < 0
 group by product_category_name_english
 order by amount_reviews desc;
 
 select  count(o.order_id) as amount_orders, product_category_name_english  from order_items oi
INNER JOIN orders o ON oi.order_id = o.order_id
INNER JOIN products p ON oi.product_id = p.product_id
INNER JOIN product_category_name_translation pc ON pc.product_category_name = p.product_category_name
 where order_status = 'delivered' and timestampdiff(day, order_delivered_customer_date, order_estimated_delivery_date) < 0
 group by product_category_name_english
 order by amount_orders desc;