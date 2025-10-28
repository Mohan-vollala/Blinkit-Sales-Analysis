#create database blinkit;
use blinkit;
select * from customers;
#1customer analysis
select count(*) from customers;
select  count(distinct area) from customers;
select distinct customer_segment from customers;
select customer_segment,sum(total_orders)as total from customers group by customer_segment order by total desc;
select * from customers where total_orders=(select max(total_orders) from customers);
select * from customers where avg_order_value=(select max(order_value) from customers);
select  customer_id, customer_name, round(total_orders * order_value,2) as total_spent from customers
order by total_spent desc limit 5;
select count(*) from customers where order_value>=(select avg(order_value) from customers);
select  customer_segment, round(avg(order_value), 2) as avg_segment_value
from  customers
group by customer_segment
order by  avg_segment_value desc;
SELECT customer_id, customer_name, registration_date
FROM customers
WHERE customer_segment = 'Premium' AND registration_date >= '2024-01-01'
order by registration_date desc;

select area,sum(total_orders) as total from customers group by area  order by total desc;

select  area, round(sum(total_orders * order_value),2) AS total_revenue from customers
group by area order by total_revenue desc limit 10;

select date_format(registration_date,'%Y-%m') as date,sum(total_orders) as total_orders from customers
group by date  order by total_orders desc;

select DATE_FORMAT(registration_date, '%Y-%m') AS month,
customer_segment,
sum(total_orders) as monthly_sales
from customers
group by month, customer_segment
order by monthly_sales desc;

select customer_segment,max(order_value) from customers
group by customer_segment;

select date_format(registration_date,'%Y-%m') as date,count(*) as total_registrations from customers group by date order by total_registrations  desc;
select date_format(registration_date,'%Y-%m') as date,customer_segment, count(*) as total_registrations from customers 
group by date,customer_segment order by total_registrations desc;
select * from customers;

#2customer_feedback
select count(*) from customer_feedback;
select c.customer_id,c.customer_name,c.area,ch.order_id,ch.feedback_text from customers c  inner join  customer_feedback ch on c.customer_id=ch.customer_id;
select count(distinct feedback_text) from customer_feedback;
select count(distinct feedback_category) from customer_feedback;
select feedback_text,count(*) as each_count from customer_feedback group by feedback_text order by each_count desc;
select feedback_text,count(*) as count_delivery from customer_feedback where feedback_category='Delivery' group by feedback_text order by count_delivery desc;
select feedback_text,count(*) as count_App from customer_feedback where feedback_category='App Experience' group by feedback_text order by count_App desc;
select feedback_text,count(*) as count_service from customer_feedback where feedback_category='Customer Service' group by feedback_text order by count_service desc;
select feedback_text,count(*) as count_Quality from customer_feedback where feedback_category='Product Quality' group by feedback_text order by count_Quality desc;
select rating,count(*) as count from customer_feedback group by rating order by count;
select sentiment,count(*) as count from customer_feedback group by sentiment order by count;
select feedback_category,rating,count(rating) as count  from customer_feedback group by feedback_category,rating order by feedback_category,count desc;
select avg(rating) from customer_feedback;
select sentiment,round(count(*) * 100.0 / (SELECT COUNT(*) from  customer_feedback),2) as  percentage from customer_feedback group by sentiment;
select date_format(feedback_date,'%Y-%m') as month, round(avg(rating),2) as avg_rating from customer_feedback group by month order by avg_rating desc;
select count(*) from customer_feedback where lower(feedback_text) like '%damaged%';
select count(*) from customer_feedback where sentiment='Negative' and lower(feedback_text) like '%late%';
select * from customer_feedback;

#3delivery_performance
select count(*) from  delivery_performance;
select reasons_if_delayed,count(*) from delivery_performance group by reasons_if_delayed;
select delivery_status,count(*) from delivery_performance group by delivery_status;
select 
count( case when delivery_time_minutes < 0 then 1 end) as late,
count(case when  delivery_time_minutes >=0 then 1 end) as arrived from delivery_performance;
select min(delivery_time_minutes) from delivery_performance;
select round(avg(delivery_time_minutes),2) from delivery_performance;
select case
    when distance_km < 1 then '<1 km'
    when distance_km < 3 then '1-3 km'
    when distance_km < 5 then '3-5 km'
    else '5+ km' end as distance_range,
round(avg(delivery_time_minutes),2) as avg_delivery_time from delivery_performance group by  distance_range;
select order_id,delivery_time_minutes,distance_km from delivery_performance order by delivery_time_minutes desc limit 10;
#avg delivery time per month
select date_format(promised_time, '%Y-%m') AS month,
round(avg(delivery_time_minutes),2) as avg_time
from  delivery_performance group  by month order by month;
select date_format(promised_time,'%Y-%m') as month,count(*) as total_orders from delivery_performance group by month order by total_orders desc;
select 
count(case when delivery_time_minutes < 0 then 1 end) as early_deliveries,
count(case when delivery_time_minutes = 0 then 1 end) as on_time_deliveries,
count(case when delivery_time_minutes > 0 then 1 end) as late_deliveries from delivery_performance;
select * from delivery_performance;


#4Orders;
select count(*) as total_orders from orders; 
select payment_method,count(*) as orders from orders group by payment_method;
select payment_method,round(sum(order_total),2) as total from orders group by payment_method order by total desc;
select count(distinct customer_id) from orders;
select * from orders where order_value=(select max(order_value) from orders);
select min(order_value) from orders;
select customer_id,count(*) as total_orders,round(sum(order_total),2) from orders group by customer_id order by total_orders desc limit 10; 
select delivery_status,count(*) as total_count from orders group by delivery_status;
select date_format(order_date,'%Y-%m') as month,count(*) as total_orders  from orders group by month order by month;
select date_format(order_date,'%Y-%m') as month,round(sum(order_total),2) as sum_total_orders  from orders group by month order by month;
select order_id,customer_id,order_total from orders order by order_total desc limit 10;
select payment_method,round(avg(order_total),2) as average from orders group by payment_method;
select count(*) as late_orders from orders where actual_delivery_time > promised_delivery_time;
select count(distinct cast(order_date as date))as total_days from orders;
select round(sum(order_value),2) from orders;
select round(round(sum(order_value),2)/count(distinct cast(order_date as date)),2) as revenue_each_day from orders;
#Average delviery delay for late_orders
select  round(avg((timestampdiff(minute,promised_delivery_time,actual_delivery_time) / 60)), 2) as avg_delay_minutes
from orders where actual_delivery_time > promised_delivery_time;
#On time_delivery_rate per month
select date_format(order_date, '%Y-%m') as month,
round(100.0 * SUM(case when delivery_status = 'On Time' THEN 1 ELSE 0 END) / COUNT(*), 2) as on_time_rate
from orders group by  month order by month;
#customers with more than 2 orders
SELECT customer_id, count(*) as order_count from  orders
group by  customer_id having count(*) > 2 order by  order_count desc;
#Repeated customer_rate
SELECT round(100.0 * sum(case  when order_count > 1 then 1 else  0 end) / count(*), 2) as repeat_customer_rate
from  (select  customer_id, COUNT(*) as  order_count from orders group by customer_id) as  customer_orders;
select count(distinct store_id) from orders;
#top 5 delivery partners by   on-time  deliveries
SELECT delivery_partner_id, COUNT(*) as on_time_deliveries
from  orders where delivery_status = 'On Time'
group  by delivery_partner_id  order by on_time_deliveries desc limit 5;
#peak order hour of the day
select hour(order_date) AS hour, COUNT(*) AS orders from orders 
group by hour order by  orders desc;
#Stores with highest late delivery percentage
SELECT store_id, round(100.0 * SUM(CASE WHEN actual_delivery_time > promised_delivery_time THEN 1 ELSE 0 END) / COUNT(*), 2) as  late_delivery_rate from orders
group by store_id
order by late_delivery_rate desc limit 50;
select * from orders;

#5Inventory
select count(*) from inventory;
select sum(stock_received) from inventory;
select sum(damaged_stock) from inventory;
select product_id,count(*) as total_stocks  from inventory group by product_id order by total_stocks desc;
select date,sum(stock_received) as total_stocks from inventory group by date order by total_stocks desc;
select * from inventory where damaged_stock=(select max(damaged_stock) from inventory);
select sum(damaged_stock)*100/sum(stock_received) as damaged_percentage from inventory;
select 
sum(case when damaged_stock=0 then 1 end) as not_damaged,
sum(case when damaged_stock>0 then damaged_stock end) as damaged_stock from inventory;
select product_id,sum(stock_received) as total_stocks from inventory group by product_id order by total_stocks desc;
select product_id,sum(damaged_stock) as damaged_stock from inventory group by product_id order by damaged_stock desc;
select * from inventory where stock_received=damaged_stock;
select count(*) from inventory where stock_received=damaged_stock;
select date,avg(stock_received)as avg_stock from inventory group by date;
select date,avg(damaged_stock)as avg_stock from inventory group by date;
select * from inventory;

#6marketing_performance
select count(*) from marketing_performance;
select round(sum(spend),2) as total_spend from marketing_performance;
select round(sum(revenue_generated),2) from marketing_performance;
select round(sum(revenue_generated),2)- round(sum(spend),2) as profit from marketing_performance;
select round(avg(roas),2) as average from marketing_performance;
select campaign_name,max(roas) as max_roas from marketing_performance group by campaign_name order by max_roas;
select campaign_name,round(sum(revenue_generated),2)as total from marketing_performance group by campaign_name order by total;
select campaign_name,round(sum(conversions),2)as total from marketing_performance group by campaign_name order by total;
select campaign_name,round(avg(roas),2) as avg_roas from marketing_performance group by campaign_name having avg_roas<1;
SELECT campaign_name, sum(clicks) AS total_clicks,
sum(conversions) as total_conversions,sum(conversions) * 100.0 / sum(clicks) as conversion_rate
from marketing_performance group by campaign_name having conversion_rate > 10;
select date,round(sum(spend),2) as daily_spend from marketing_performance group by date order by date;
select date,round(sum(revenue_generated),2) as daily_revenue from marketing_performance group by date order by date;
select date,round(avg(roas),2) as avg_roas from marketing_performance group by date order by date;
select date,round(sum(spend),2) as total_spend from marketing_performance group by date order by total_spend desc limit 1;
select date,round(sum(revenue_generated),2) as total_revenue from marketing_performance group by date order by total_revenue desc limit 1;
select channel,round(sum(spend),2) as total_spend from marketing_performance group by channel order by total_spend desc;
select channel,round(sum(revenue_generated),2) as total_revenue from marketing_performance group by channel order by total_revenue desc;
select channel,round(sum(revenue_generated)-(sum(spend)),2) as profit from marketing_performance group by channel order by profit desc;
select channel,avg(roas) as avg_roas from marketing_performance group by channel order by avg_roas;
select channel,round(sum(revenue_generated),2) as total_revenue from marketing_performance group by channel order by total_revenue limit 1;
select target_audience,sum(impressions) as total_impressions from marketing_performance group by target_audience;
SELECT target_audience,sum(clicks)*100.0/sum(impressions) as  ctr from  marketing_performance group by target_audience;
SELECT target_audience,sum(conversions)*100.0/sum(clicks) as  conversion_rate from  marketing_performance group by target_audience;
SELECT target_audience, SUM(revenue_generated) AS total_revenue
from  marketing_performance group by target_audience order by total_revenue desc limit 1;
SELECT campaign_name, count(distinct date) as  active_days
from  marketing_performance group by campaign_name having active_days > 10;
select week(date) as week_no,round(sum(spend),2) as weekly_spend,round(sum(revenue_generated),2) as weekly_revenue from marketing_performance
group by week(date) order by week_no;
select  channel, SUM(impressions) AS impressions, SUM(revenue_generated) AS revenue
FROM marketing_performance
group  BY channel
order by impressions DESC, revenue ASC limit 1;

SELECT date, SUM(spend) AS spend, SUM(revenue_generated) AS revenue
FROM marketing_performance group by  date having spend > revenue;

select campaign_id,SUM(spend) AS spend, SUM(revenue_generated) revenue_generated from marketing_performance 
group by campaign_id having spend>revenue_generated order by spend desc;

select count(*) from marketing_performance where spend>revenue_generated;

SELECT channel,round(SUM(spend) / NULLIF(SUM(conversions), 0),2) AS cost_per_conversion
FROM marketing_performance group by channel;

SELECT channel, AVG(roas) AS avg_roas
from marketing_performance where channel in ('App', 'Email') group by  channel;

SELECT channel, campaign_name, round(SUM(revenue_generated),2) AS total_revenue
FROM marketing_performance group by channel, campaign_name order by channel, total_revenue DESC;

SELECT channel FROM marketing_performance GROUP BY channel HAVING AVG(roas) < (SELECT AVG(roas) FROM marketing_performance);
select * from marketing_performance;



#7order_items
select count(*) from order_items;
select count(distinct product_id) as unique_product_sold from order_items;
select * from order_items where unit_price=(select max(unit_price) from order_items);
select round(sum(quantity*unit_price),2) as total_revenue from order_items;
select round(avg(unit_price*quantity),2) from order_items;
select sum(quantity) as total_sold from order_items;
select product_id,round(sum(quantity*unit_price),2) as total_revenue from order_items group by product_id order by total_revenue;
select product_id,round(sum(quantity*unit_price),2) as total_revenue from order_items group by product_id order by total_revenue desc limit 10;
select product_id,round(sum(quantity),2) as total_quantity from order_items group by product_id order by total_quantity desc limit 10;
select product_id,round(avg(unit_price),2) as avg_price from order_items group by product_id order by avg_price desc;
select product_id from order_items group by product_id having sum(quantity)=1;
SELECT round(avg(total_quantity),2)AS avg_items_per_order
from(select order_id, SUM(quantity) as total_quantity from order_items group by order_id ) as items_per_order;
select product_id, SUM(quantity) AS total_quantity,rank() OVER (ORDER BY SUM(quantity) DESC) AS popularity_rank
FROM order_items group by product_id;
SELECT product_id,round(SUM(quantity * unit_price) * 100.0 / (SELECT SUM(quantity * unit_price) FROM order_items), 2) AS revenue_percentage
from order_items group by product_id order by revenue_percentage DESC;
SELECT product_id FROM order_items GROUP BY product_id HAVING MAX(unit_price) <= 100;
 select count(*) from (SELECT product_id FROM order_items GROUP BY product_id HAVING MAX(unit_price) <= 100) as products_less_than_100;
 select  case
when unit_price < 100 then 'Below 100'
when unit_price between 100 and 300 then '100-300'
when unit_price between 301 and 500 then '301-500'
else 'Above 500' end as price_range,avg(quantity) AS avg_quantity
from  order_items group by  price_range;
select * from order_items;

#8Products;
select count(*) as total_products from products;
select count(distinct product_name) from products;
select count(distinct category) from products;
select round(avg(price),2) as avg_price from products;
select  * from products where  price = (SELECT MAX(price) FROM products) or price = (SELECT MIN(price) FROM products);
select count(*) from products where price>=500;
select count(*) from products where price>mrp;

SELECT category, product_name, price from products p where  (category, price) 
in (select category, MAX(price) from products group by  category);

SELECT category, round(avg(price),2) as  avg_category_price from products
group by category having avg_category_price > 300;
select category,round(max(price)-min(price),2) as price_range from products group by category;
select brand,count(*)as product_count from products group by brand order by product_count desc;

SELECT brand, AVG(price) AS avg_price from products
group by  brand;

SELECT brand, AVG(price) AS avg_price from products
group by brand order by avg_price desc limit 5;

select category,count(*) as total_count from products group by category;
select category,count(distinct brand) as total_count from products group by category;
select * from products where margin_percentage = (select max(margin_percentage) from products);
select * from products where margin_percentage = (select min(margin_percentage) from products);
select * from products where price >= 0.8 * mrp;
select * from products where (mrp - price) > 100;

select category, brand, AVG(price) AS avg_price
from products group by category, brand;

select *, (mrp - price) AS discount_amount FROM products ORDER BY discount_amount DESC LIMIT 5;
select *, round((margin_percentage / price),2) AS margin_per_rupee FROM products ORDER BY margin_per_rupee DESC;
SELECT count(*) as profitable_products from products where  margin_percentage > ((mrp - price) / mrp) * 100;
select * from products order by price asc, margin_percentage desc limit 5;
select product_id, product_name, (max_stock_level - min_stock_level) as  stock_range from products;
select avg(min_stock_level) from products;

SELECT brand, COUNT(*) AS high_margin_count from products
WHERE margin_percentage > 30 group by brand order by high_margin_count desc limit 5;

SELECT category, AVG(margin_percentage) AS avg_margin FROM products GROUP BY category;

SELECT brand, product_name, price from(select *, rank() over (partition by brand order by price desc) as rnk from products) t where rnk = 1;

select case
when price < 100 then '<100'
when price between 100 and 500 then '100-500'
when price between 501 and 1000 then '501-1000'
else '>1000' end as price_bucket, round(avg(margin_percentage),2) as avg_margin from products group by price_bucket;

SELECT CASE
when margin_percentage < 10 then '<10%'
when margin_percentage between 10 and 20 then '10-20%'
when margin_percentage between 21 AND 40 then '21-40%'
else '>40%' end as margin_bucket, COUNT(*) as  count from products group by margin_bucket;

select * from products;






















