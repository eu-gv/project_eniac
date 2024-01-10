-- I consider tech sellers the ones falling into the following 7 categories:
-- ( audio computers computers_accessories electronics tablets_printing_image telephony watches_gifts )
# numeber of Tech sellers: 516
select
	count(*)
from (
	select distinct
		seller_id
	from order_items oi
	left join products p on oi.product_id = p.product_id
	left join product_category_name_translation ptr on p.product_category_name = ptr.product_category_name
	where product_category_name_english in ('audio', 'computers', 'computers_accessories', 'electronics', 'tablets_printing_image', 'telephony', 'watches_gifts')
	order by seller_id
    ) as count_sellers; # 516 tech sellers

-- What percentage of overall sellers are Tech sellers? 516 : 3095 = x : 100
-- 516*100 / 3095 = 16.67%

-- How many orders actually come from the tech sellers?
select
	count(*)
from (
	select distinct
		seller_id, order_id, product_category_name_english
	from order_items oi
	left join products p on oi.product_id = p.product_id
	left join product_category_name_translation ptr on p.product_category_name = ptr.product_category_name
	where product_category_name_english in ('audio', 'computers', 'computers_accessories', 'electronics', 'tablets_printing_image', 'telephony', 'watches_gifts')
	order by seller_id
     ) as count_tech_orders; # 19814 orders from tech companies

-- Of the total 99441 orders handled by Magist, 19814 come from tech sellers -> 19.92%

# total earned amount of money from all the orders over 22 months (I cut the first 3 and the last 2 months of the dataset):
select
	seller_id, sum(price)
from orders o
left join order_items oi on o.order_id = oi.order_id
where order_purchase_timestamp between '2017-01-01' and '2018-8-31'
group by seller_id;

# total earned amount of money per seller and per year:
select
	seller_id, year(order_purchase_timestamp), sum(price)
from orders o
left join order_items oi on o.order_id = oi.order_id
where order_purchase_timestamp between '2017-01-01' and '2018-8-31'
group by seller_id, year(order_purchase_timestamp);

# number of months per year when sellers sell sth:
select distinct
	seller_id, count(month(order_purchase_timestamp))
from orders o
left join order_items oi on o.order_id = oi.order_id
where order_purchase_timestamp between '2017-01-01' and '2018-8-31'
and seller_id = '0015a82c2db000af6aaaf3ae2ecb0532'
group by seller_id, year(order_purchase_timestamp);



# number of months: 20 (without the first 3 and last 2)
select
	year(order_purchase_timestamp) as year_buy,
	month(order_purchase_timestamp) as month_buy
from orders
where order_purchase_timestamp between '2017-01-01' and '2018-8-31'
-- where year(order_purchase_timestamp) between 2017 and 2018
group by year_buy, month_buy
order by year_buy;


-- ALL sellers with total number of orders with location and avg. delivery time:
select
 	oi.seller_id, count(*) as number_of_orders, s.seller_zip_code_prefix, city, state, lat, lng,
	AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS average_delivery_time
from
	order_items oi
left join orders o on oi.order_id = o.order_id
left join sellers s on oi.seller_id = s.seller_id
left join geo g on s.seller_zip_code_prefix = g.zip_code_prefix
where
 	order_status = 'delivered'
    and order_purchase_timestamp between '2017-01-01' and '2018-8-31'
    group by seller_id
order by count(*) desc;


-- TECH sellers with total number of orders with location and avg. delivery time:
select
 	oi.seller_id, count(*) as number_of_orders, s.seller_zip_code_prefix, city, state, lat, lng,
	AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS average_delivery_time#, product_category_name_english
from
	order_items oi
left join products p on oi.product_id = p.product_id
left join product_category_name_translation ptr on p.product_category_name = ptr.product_category_name
left join orders o on oi.order_id = o.order_id
left join sellers s on oi.seller_id = s.seller_id
left join geo g on s.seller_zip_code_prefix = g.zip_code_prefix
where
 	order_status = 'delivered'
    and order_purchase_timestamp between '2017-01-01' and '2018-8-31'
   	and product_category_name_english in ('audio', 'computers', 'computers_accessories', 'electronics', 'tablets_printing_image', 'telephony', 'watches_gifts')
group by seller_id
order by count(*) desc;



select *
from
	orders o
left join order_items oi on oi.order_id = o.order_id
where seller_id = 'df683dfda87bf71ac3fc63063fba369d';

# average delivery time per tech categories:
select
	count(*) as number_of_orders,
-- 	oi.seller_id, count(*) as number_of_orders, s.seller_zip_code_prefix, city, state, lat, lng,
	AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS average_delivery_time, product_category_name_english
from
	order_items oi
left join products p on oi.product_id = p.product_id
left join product_category_name_translation ptr on p.product_category_name = ptr.product_category_name
left join orders o on oi.order_id = o.order_id
left join sellers s on oi.seller_id = s.seller_id
left join geo g on s.seller_zip_code_prefix = g.zip_code_prefix
where
 	order_status = 'delivered'
    and order_purchase_timestamp between '2017-01-01' and '2018-8-31'
   	and product_category_name_english in ('audio', 'computers', 'computers_accessories', 'electronics', 'tablets_printing_image', 'telephony', 'watches_gifts')
group by product_category_name_english
order by count(*) desc;




################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################
################################################################################################################
-- Alisa's code:

SELECT
    CASE
        WHEN o.order_status = 'delivered' AND o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'Delivered On Time'
        WHEN o.order_status = 'delivered' AND o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Delayed'
        WHEN o.order_status = 'canceled' THEN 'Canceled'
        WHEN o.order_status = 'unavailable' THEN 'Unavailable'
        WHEN o.order_status = 'shipped' THEN 'Shipped'
        WHEN o.order_status = 'processing' THEN 'Processing'
        WHEN o.order_status = 'invoiced' THEN 'Invoiced'
        ELSE 'Other' 
    END AS order_status_category,
    COUNT(*) AS order_count
FROM
    orders o
JOIN
    order_items oi ON o.order_id = oi.order_id
JOIN
    products p ON oi.product_id = p.product_id
LEFT JOIN
    product_category_name_translation pct ON p.product_category_name = pct.product_category_name
WHERE
    p.product_category_name IN ("audio", "pcs", "informatica_acessorios", "eletronicos", "tablets_impressao_imagem", "telefonia", "relogios_presentes")
GROUP BY
    order_status_category;


### My trials:
# average delivery on total delivered deliveries (so the delayed and the on-time deliveries):
select
	 AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS average_delivery_time, order_status
from orders
where
	order_purchase_timestamp between '2017-01-01' and '2018-8-31'
group by order_status;

# average delivery on the on-time deliveries:
select
	 AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS average_delivery_time, order_status
from orders
where
	order_status = 'delivered'
    and order_delivered_customer_date <= order_estimated_delivery_date
    and order_purchase_timestamp between '2017-01-01' and '2018-8-31'
group by order_status;

# average delivery on the on-time deliveries for tech sellers:
select
	 AVG(DATEDIFF(order_delivered_customer_date, order_purchase_timestamp)) AS average_delivery_time, order_status
from
	orders o
left join
	order_items oi on o.order_id = oi.order_id
left join
	products p on oi.product_id = p.product_id
left join
	product_category_name_translation ptr on p.product_category_name = ptr.product_category_name
where
	product_category_name_english in ('audio', 'computers', 'computers_accessories', 'electronics', 'tablets_printing_image', 'telephony', 'watches_gifts')
	and order_status = 'delivered'
    and order_delivered_customer_date <= order_estimated_delivery_date
    and order_purchase_timestamp between '2017-01-01' and '2018-8-31'
group by order_status;







# Alisa's code for looking at product weight and delivery status:
SELECT
    CASE
        WHEN o.order_status = 'delivered' AND o.order_delivered_customer_date <= o.order_estimated_delivery_date THEN 'Delivered On Time'
        WHEN o.order_status = 'delivered' AND o.order_delivered_customer_date > o.order_estimated_delivery_date THEN 'Delayed'
        WHEN o.order_status = 'canceled' THEN 'Canceled'
        WHEN o.order_status = 'unavailable' THEN 'Unavailable'
        WHEN o.order_status = 'shipped' THEN 'Shipped'
        WHEN o.order_status = 'processing' THEN 'Processing'
        WHEN o.order_status = 'invoiced' THEN 'Invoiced'
        ELSE 'Other'
    END AS order_status_category,
    avg(p.product_weight_g), stddev(p.product_weight_g),
    COUNT(*) AS order_count
FROM
    orders o
JOIN
    order_items oi ON o.order_id = oi.order_id
JOIN
    products p ON oi.product_id = p.product_id
LEFT JOIN
    product_category_name_translation pct ON p.product_category_name = pct.product_category_name
WHERE
    p.product_category_name IN ("audio", "pcs", "informatica_acessorios", "eletronicos", "tablets_impressao_imagem", "telefonia", "relogios_presentes")
GROUP BY
    order_status_category
ORDER BY
    order_status_category;
