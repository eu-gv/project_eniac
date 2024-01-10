
USE magist;


-- 1. How many orders are there in the dataset? 99441 total orders
select
	count(*)
from orders;  # 99441 total orders


-- 2. Are orders actually delivered? 96478/99441 orders are delivered -> 97%
select
	order_status, count(order_status)
from orders
group by order_status;
-- where order_status in ('delivered','unavailable');


-- 3. Is Magist having user growth? YES per year
select
	year(order_purchase_timestamp) as year_buy,
    month(order_purchase_timestamp) as month_buy,
    count(customer_id)
from orders
group by year_buy, month_buy
order by year_buy;


-- 4. How many products are there on the products table? 32951
select
	count(distinct product_id)
from products;


-- 5. Which are the categories with the most products? 1.bed_bath_table
select
	product_category_name, count(product_category_name) as count_pr
from products
group by product_category_name
order by count_pr desc;

-- 5+. what is the english translation of those categories?
select
	p.product_category_name, count(p.product_category_name) as count_pr, product_category_name_english
from products p
left join product_category_name_translation ptr on p.product_category_name = ptr.product_category_name
group by p.product_category_name
having count_pr > 1000
order by count_pr desc;

-- 5++. How many products are actually sold by category?
select
	p.product_category_name, count(p.product_id) as sold_prdcts_per_category, product_category_name_english
from products p
left join order_items oi on p.product_id = oi.product_id
left join product_category_name_translation ptr on p.product_category_name = ptr.product_category_name
group by product_category_name
order by sold_prdcts_per_category desc;


-- 6. How many of those products were present in actual transactions?
select
	count(distinct product_id) as count_prdctid
from order_items;

-- 6+. here I divide per category the actual transactions above:
select
	count(distinct oi.product_id) as count_prdctid, product_category_name
from order_items oi
left join products p on p.product_id = oi.product_id
group by product_category_name
order by count_prdctid desc;

-- 6++. here I add also the english names:
select
	count(distinct oi.product_id) as count_prdctid, p.product_category_name, product_category_name_english
from order_items oi
left join products p on p.product_id = oi.product_id
left join product_category_name_translation ptr on p.product_category_name = ptr.product_category_name
group by p.product_category_name
order by count_prdctid desc;


-- 7. What’s the price for the most expensive and cheapest products?
select
	max(price) as max_price,
    min(price) as min
from order_items;


-- 8. What are the highest and lowest payment values?
select
	*
from order_payments
order by payment_value desc;

select
	max(payment_value),
    min(payment_value)
from order_payments;

SELECT
    SUM(payment_value) AS highest_order
FROM order_payments
GROUP BY order_id
ORDER BY highest_order DESC
LIMIT 1;