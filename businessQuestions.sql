
use magist;

/* Answer business questions */ 
-- There are 32951 products divided by 74 categories. 112650 items have been sold in 99441 orders, with at least an order for every product!

-- 3.2. In relation to the sellers:
-- How many months of data are included in the magist database? 25 but the first 3 and the last 2 look compromised!
select * from orders;
select
	year(order_purchase_timestamp) as year_buy,
	month(order_purchase_timestamp) as month_buy,
	count(customer_id)
from orders
where order_purchase_timestamp between '2017-01-01' and '2018-8-31'
-- where year(order_purchase_timestamp) between 2017 and 2018
group by year_buy, month_buy
order by year_buy;

# I count the months using a subquery:
select
	count(*)
from (
		select
			year(order_purchase_timestamp) as year_buy,
			month(order_purchase_timestamp) as month_buy,
			count(customer_id)
		from orders
		group by year_buy, month_buy
		order by year_buy
	) as count_months;


-- How many sellers are there? 3095
select
	count(*)
from sellers; # 3095

select
	count(distinct seller_id)
from order_items; # 3095

###############################################################################################################################
-- personal question: does a seller fall into one or more of the 74 categories? Many sellers fall into more than one category.
-- select count(*) from (
		select distinct
			seller_id, product_category_name
		from order_items oi
		left join products p on oi.product_id = p.product_id
        order by seller_id;
-- 	) as check_;

select
	distinct seller_id, avg(price), product_category_name
from order_items oi
left join products p on oi.product_id = p.product_id
group by product_category_name, seller_id;
###############################################################################################################################

-- How many Tech sellers are there? 516
-- I consider tech sellers the ones falling into the following 7 categories:
-- audio computers computers_accessories electronics tablets_printing_image telephony watches_gifts
select distinct
	seller_id
from order_items oi
left join products p on oi.product_id = p.product_id
left join product_category_name_translation ptr on p.product_category_name = ptr.product_category_name
where product_category_name_english in ('audio', 'computers', 'computers_accessories', 'electronics', 'tablets_printing_image', 'telephony', 'watches_gifts')
order by seller_id;

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

-- -------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------
-- WRONG: I consider a threshold price of 100€, above which I consider a seller a tech seller
-- of course this is not enough. Also furnitures and other things can be very expensive and still not high-tech...
select
	seller_id, avg(price)
from order_items oi
group by seller_id
having avg(price) >= 100
order by avg(price) desc; # 1463 sellers with an avg price over 100€
-- -------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------

-- What percentage of overall sellers are Tech sellers? 516 : 3095 = x : 100
-- 516*100 / 3095 = 16.67%

-- What is the total amount earned by all sellers?
# total amount earned by each seller:
select
	seller_id, sum(price)
from order_items oi
group by seller_id
order by sum(price) desc;
# countercheck on most successful seller:
select
	sum(price)
from order_items
where seller_id = '4869f7a5dfa277a7dca6462dcf3b52b2';
# total amount earned by ALL sellers together:
select
	sum(price)
from order_items oi; # 13.59M €


-- What is the total amount earned by all Tech sellers?
# total amount earned by each Tech sellers:
select distinct
	seller_id, sum(price)
from order_items oi
left join products p on oi.product_id = p.product_id
left join product_category_name_translation ptr on p.product_category_name = ptr.product_category_name
where product_category_name_english in ('audio', 'computers', 'computers_accessories', 'electronics', 'tablets_printing_image', 'telephony', 'watches_gifts')
group by seller_id
order by sum(price) desc; # 516 Tech sellers with the total earned amount
# total amount earned by ALL Tech sellers: 2.88M €
select
	sum(price)
from order_items oi
left join products p on oi.product_id = p.product_id
left join product_category_name_translation ptr on p.product_category_name = ptr.product_category_name
where product_category_name_english in ('audio', 'computers', 'computers_accessories', 'electronics', 'tablets_printing_image', 'telephony', 'watches_gifts');
# total amount earned by ALL Tech sellers per month:
select
	year(order_purchase_timestamp) as year_buy,
    month(order_purchase_timestamp) as month_buy,
    sum(price)
from order_items oi
left join orders o on oi.order_id = o.order_id
left join products p on oi.product_id = p.product_id
left join product_category_name_translation ptr on p.product_category_name = ptr.product_category_name
where product_category_name_english in ('audio', 'computers', 'computers_accessories', 'electronics', 'tablets_printing_image', 'telephony', 'watches_gifts')
	and order_purchase_timestamp between '2017-01-01' and '2018-8-31'
group by month_buy, year_buy
order by year_buy, month_buy;


-- Can you work out the average monthly income of all sellers?
# average amount earned by each seller in the entire period available in the dataset:
select
	seller_id, avg(price)
from order_items oi
group by seller_id
order by avg(price) desc;
-- average income in the single month (total earned in the month / number of sells in the month)
#first try with one seller: THIS IS THE AVERAGE PRICE OF SOLD PRODUCT PER ONE SELLER
-- select count(*) from (
		select
			year(order_purchase_timestamp) as year_buy,
			month(order_purchase_timestamp) as month_buy,
			sum(price)
			-- seller_id, avg(price)
		from order_items oi
		left join orders o on oi.order_id = o.order_id
		where seller_id = '0015a82c2db000af6aaaf3ae2ecb0532'
		group by month_buy, year_buy
		order by year_buy, month_buy;
--    ) as count_months_seller;
-- average income in the single month (total earned in the month / number of sells in the month) for ALL sellers:
#first try with one seller: THIS IS THE AVERAGE PRICE OF SOLD PRODUCT PER SELLER
select
	seller_id,
	year(order_purchase_timestamp) as year_buy,
    month(order_purchase_timestamp) as month_buy,
    avg(price)
from order_items oi
left join orders o on oi.order_id = o.order_id
group by seller_id, month_buy, year_buy
order by seller_id, year_buy, month_buy;

-- -------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------
-- TODO: average monthly income per year (total earned in the year / number of months of the year during they sold )
#first try with one seller: TO FINISH!!
 -- select count(*) from (
		select
			year(order_purchase_timestamp) as year_buy,
            month(order_purchase_timestamp) as month_buy,
            avg(price)
			-- seller_id, avg(price)
		from order_items oi
 		left join orders o on oi.order_id = o.order_id
		where seller_id = '0015a82c2db000af6aaaf3ae2ecb0532'
		group by year_buy, month(order_purchase_timestamp);
-- 		order by year_buy;
--      ) as count_months_seller;

select price, month(order_purchase_timestamp), year(order_purchase_timestamp)
from order_items oi
left join orders o on oi.order_id = o.order_id
where seller_id = '0015a82c2db000af6aaaf3ae2ecb0532';


select
	seller_id,
	case
		when order_purchase_timestamp between '2017-01-01' and '2018-8-31' then 'Sold Item'
	end as sold_items,
    count(*)
from orders
group by sold_items, seller_id;

-- -------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------
-- -------------------------------------------------------------------------------------------------------------------

-- Can you work out the average monthly income of Tech sellers?
select
	seller_id,
	year(order_purchase_timestamp) as year_buy,
    month(order_purchase_timestamp) as month_buy,
    avg(price)
from order_items oi
left join orders o on oi.order_id = o.order_id
left join products p on oi.product_id = p.product_id
left join product_category_name_translation ptr on p.product_category_name = ptr.product_category_name
where product_category_name_english in ('audio', 'computers', 'computers_accessories', 'electronics', 'tablets_printing_image', 'telephony', 'watches_gifts')
group by seller_id, month_buy, year_buy
order by seller_id, year_buy, month_buy;



###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################
###############################################################################################################################



-- 3.1. In relation to the products:
-- What categories of tech products does Magist have?
-- I was thinking to take the avg price of products per category in order to find the categories with the most expensive
-- products and assume that the tech products have an avg price higher than a certain threshold, e.g. 100€

# total number of items sold in the dataset: 112650
select
	count(*)
from order_items;
# total number of orders in the dataset: 99441
select
	count(*)
from orders;

# An order can be paid in installments, which means that a single order can have many separate payments.
select
	count(*)
from order_payments; # 103886 payments are listed
# I can do a countecheck of the total number of orders from order_payments: 99440 looks like one is missing
select
	count(distinct order_id)
from order_payments;
# I try to find the missing paid order:
select
	*
from order_payments op
right join orders o on op.order_id = o.order_id
where op.order_id is null;


# avg price of products per category:
select
	avg(price), product_category_name_english
from order_items oi
left join products p on oi.product_id = p.product_id
left join product_category_name_translation ptr on p.product_category_name = ptr.product_category_name
group by product_category_name_english
order by avg(price) desc;
