-- This will be all material for GitHub project 

/*
1. First, let's take a look at the volume growth: overall session and order volume, trends by quarter, for the life of the business.
*/
SELECT
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) as qrt, 
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions, 
    COUNT(DISTINCT orders.order_id) AS num_orders,
    SUM(orders.price_usd) AS revenue
FROM website_sessions
	LEFT JOIN orders ON orders.website_session_id = website_sessions.website_session_id
GROUP BY 1,2; 

/*
2. Next, all of efficiency improvements. 
Let's pull quarterly figures since launch, for session-to-order conversion rate, revenue per order, and revenue per session.
*/
SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qr,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) * 100 AS CRT_order_session,
    SUM(orders.price_usd) / COUNT(DISTINCT orders.order_id) AS rev_per_order, 
    SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS rev_per_session
FROM website_sessions
LEFT JOIN orders ON orders.website_session_id = website_sessions.website_session_id
GROUP BY 1,2;

/*
3. Let's show how specific channels have grown and pull a quarterly view of orders from Gsearch nonbrand,
Bsearch nonbrand, brand search overall, organic search, and direct type-in?  
*/
SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qrt,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS gsearch_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) AS bsearch_nonbrand,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) AS brand_search, 
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) AS org_search, 
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) AS direct_type
FROM website_sessions
	LEFT JOIN orders ON orders.website_session_id = website_sessions.website_session_id
GROUP BY 1,2;

/*
4. Next, let's show the overall session-to-order conversion rate trends for those same channels, by quarter. 
Please, also make a note of any periods where we made major improvements or optimisations. 
*/
SELECT
	YEAR(website_sessions.created_at) AS yr,
    QUARTER(website_sessions.created_at) AS qrt,
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) / 
    COUNT(DISTINCT CASE WHEN utm_source = 'gsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) * 100 AS gsearch_non_CTR,
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN orders.order_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN utm_source = 'bsearch' AND utm_campaign = 'nonbrand' THEN website_sessions.website_session_id ELSE NULL END) * 100 AS bsearch_non_CTR,
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN orders.order_id ELSE NULL END) / 
    COUNT(DISTINCT CASE WHEN utm_campaign = 'brand' THEN website_sessions.website_session_id ELSE NULL END) * 100 AS brand_CTR,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN orders.order_id ELSE NULL END) / 
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NOT NULL THEN website_sessions.website_session_id ELSE NULL END) * 100 AS org_search_CTR,
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN orders.order_id ELSE NULL END) / 
    COUNT(DISTINCT CASE WHEN utm_source IS NULL AND http_referer IS NULL THEN website_sessions.website_session_id ELSE NULL END) * 100 AS direct_CTR
FROM website_sessions 
LEFT JOIN orders ON orders.website_session_id = website_sessions.website_session_id
GROUP BY 1,2;

/*
5. While we're on Gsearch, let's dive into nonbrand, and pull monthly sessions and orders split by device type?
*/
SELECT
	YEAR(website_sessions.created_at) AS yr,
	QUARTER(website_sessions.created_at) AS qrt,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN website_sessions.website_session_id ELSE NULL END) AS mob_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'mobile' THEN orders.order_id ELSE NULL END) AS mob_orders,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN website_sessions.website_session_id ELSE NULL END) AS desk_sessions,
    COUNT(DISTINCT CASE WHEN device_type = 'desktop' THEN orders.order_id ELSE NULL END) AS desk_sessions
FROM website_sessions
LEFT JOIN orders ON orders.website_session_id = website_sessions.website_session_id
WHERE utm_source = 'gsearch' AND utm_campaign = 'nonbrand' 
GROUP BY 1,2;

/*
6. We've come along way since the days of selling a single product. Let's pull monthly trending for revenue and margin by product,
along with total sales and revenue. Note anything you notice about seasonality. 
*/
SELECT 
	YEAR(created_at) AS yr,
    MONTH(created_at) AS mnth, 
    SUM(CASE WHEN product_id = 1 THEN price_usd ELSE NULL END) AS mrfuzzy_rev,
    SUM(CASE WHEN product_id = 1 THEN price_usd - cogs_usd ELSE NULL END) AS mrfuzzy_marg,
    SUM(CASE WHEN product_id = 2 THEN price_usd ELSE NULL END) AS lovebear_rev,
    SUM(CASE WHEN product_id = 2 THEN price_usd - cogs_usd ELSE NULL END) AS lovebear_marg,
    SUM(CASE WHEN product_id = 3 THEN price_usd ELSE NULL END) AS birthdaybear_rev,
    SUM(CASE WHEN product_id = 3 THEN price_usd - cogs_usd ELSE NULL END) AS birthday_marg,
    SUM(CASE WHEN product_id = 4 THEN price_usd ELSE NULL END) AS minibear_rev,
    SUM(CASE WHEN product_id = 4 THEN price_usd - cogs_usd ELSE NULL END) AS minibear_marg,
    SUM(price_usd) AS total_revenue,
    SUM(price_usd - cogs_usd) AS total_marg
FROM order_items  
GROUP BY 1,2
ORDER BY 1,2;

/*
7. Let's dive deeper into the impact of introducing new products.
Pull monthly sessions to the /products page, and show how the % of those sessions clicking through another page has changed over time, 
along with view of how conversion from /products to placing an order has improved
*/

-- first temp table - all sessions, reached out "/products" page
CREATE TEMPORARY TABLE products_pageviews
SELECT 
	website_session_id,
    website_pageview_id,
    created_at AS saw_product_page_at
FROM website_pageviews
WHERE pageview_url = '/products';
  
SELECT
	YEAR(saw_product_page_at) AS yr,
    MONTH(saw_product_page_at) AS mnth,
    COUNT(DISTINCT products_pageviews.website_session_id) AS sessions_to_product_page,
    COUNT(DISTINCT website_pageviews.website_session_id) AS clicked_to_next_page,
    COUNT(DISTINCT website_pageviews.website_session_id) / COUNT(DISTINCT products_pageviews.website_session_id) AS clickthrough_rt,
    COUNT(DISTINCT orders.order_id) AS orders,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT products_pageviews.website_session_id) AS products_to_order_rt
FROM products_pageviews
LEFT JOIN website_pageviews ON website_pageviews.website_session_id = products_pageviews.website_session_id -- means the same session
AND website_pageviews.website_pageview_id > products_pageviews.website_pageview_id -- means they have another page after
LEFT JOIN orders ON orders.website_session_id = products_pageviews.website_session_id
GROUP BY 1,2;

/*
8. From the June 19th we lunched the new landing page. Let's take a look what the revenue test earned us for the gsearch users.
(hint: look at encrease in CVR from the test ( Jun 19 - Jul 28 ), and use nonbrand sessions and revenue since then to calculate incremental value) 	
*/
SELECT 
	MIN(DATE(created_at)),
    MIN(website_pageview_id),
    MAX(DATE(created_at))
FROM website_pageviews
WHERE created_at < '2012-11-27' AND pageview_url = '/lander-1'; 

-- So, the date and minimal pageview id: 2012-06-19 and 23504

-- first, we'll find the first pageview id 
CREATE TEMPORARY TABLE lp1
SELECT 
	website_pageviews.website_session_id,
    MIN(website_pageviews.website_pageview_id) AS min_pv_id,
    website_pageviews.pageview_url 
FROM website_pageviews
INNER JOIN website_sessions ON website_pageviews.website_session_id = website_sessions.website_session_id
AND website_sessions.created_at < '2012-07-28'
AND website_pageviews.website_pageview_id >= 23504 
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
GROUP BY 1;

-- next we'll bring in the landing page to each session, like last time, but restricting to home or lander-1
CREATE TEMPORARY TABLE lp_w_landing_pages
SELECT
	lp1.website_session_id,
    website_pageviews.pageview_url AS landing_page
    FROM lp1 
LEFT JOIN website_pageviews ON website_pageviews.website_pageview_id = lp1.min_pv_id
WHERE website_pageviews.pageview_url IN ('/home', '/lander-1'); 

-- then we make a table to bring in orders
CREATE TEMPORARY TABLE lp_w_orders 
SELECT 
	lp_w_landing_pages.website_session_id,
    lp_w_landing_pages.landing_page,
    orders.order_id AS order_id 
    FROM lp_w_landing_pages
    LEFT JOIN orders ON orders.website_session_id = lp_w_landing_pages.website_session_id;

-- to find the difference between conversion rates
SELECT 
	landing_page, 
    COUNT(DISTINCT website_session_id) AS sessions, 
    COUNT(DISTINCT order_id) AS orders, 
    COUNT(DISTINCT order_id) / COUNT(DISTINCT website_session_id) AS conv_rate
FROM lp_w_orders
GROUP BY 1; 

-- 0.0319 for /home, vs 0.0406 for /lander-1
-- 0.0087 additional orders per session 

-- finding the most recent pageview for Gsearch nonbrand where the traffic was sent to /home
SELECT 
	MAX(website_sessions.website_session_id) AS most_recent_home
FROM website_sessions
	LEFT JOIN website_pageviews ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE utm_source = 'gsearch'
AND utm_campaign = 'nonbrand'
AND pageview_url = '/home'
AND website_sessions.created_at < '2012-11-27'; 

-- max website_session_id = 17145

SELECT 
	COUNT(website_session_id) AS sessions_since_test
FROM website_sessions
WHERE created_at < '2012-11-27'
AND website_session_id > 17145 -- last /home session 
AND utm_source = 'gsearch'
AND utm_campaign = 'nonbrand';

-- 22,972 website sessions since the test
-- x0.0087 incremental conversion = 202 incremental orders sinse 7/29
-- roughly 4 months, so roughly 50 extra orders per month.

/*
9. For the landing page test that we analyzed, it would be great to show a full conv funnel from each of the 2 pages to orders. 
*/
CREATE TEMPORARY TABLE saw_flag
SELECT 
	website_session_id,
    MAX(homepage) AS saw_homepage,
    MAX(lander) AS saw_lander,
    MAX(product_page) AS saw_product_page, 
    MAX(mrfuzzy_page) AS saw_mrfuzzy_page, 
    MAX(cart_page) AS saw_cart_page, 
    MAX(ship_page) AS saw_ship_page,
    MAX(bil_page) AS saw_bil_page, 
    MAX(tnx_page) AS saw_tnx_page
FROM(
SELECT 
	website_sessions.website_session_id,
    website_pageviews.pageview_url, 
    CASE WHEN pageview_url = '/home' THEN 1 ELSE 0 END AS homepage,
    CASE WHEN pageview_url = '/lander-1' THEN 1 ELSE 0 END AS lander,
    CASE WHEN pageview_url = '/products' THEN 1 ELSE 0 END AS product_page,
    CASE WHEN pageview_url = '/the-original-mr-fuzzy' THEN 1 ELSE 0 END AS mrfuzzy_page, 
    CASE WHEN pageview_url = '/cart' THEN 1 ELSE 0 END AS cart_page,
    CASE WHEN pageview_url = '/shipping' THEN 1 ELSE 0 END AS ship_page,
    CASE WHEN pageview_url = '/billing' THEN 1 ELSE 0 END AS bil_page, 
    CASE WHEN pageview_url = '/thank-you-for-your-order' THEN 1 ELSE 0 END AS tnx_page
 FROM website_sessions
LEFT JOIN website_pageviews ON website_pageviews.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at < '2012-07-28' AND website_sessions.created_at > '2012-06-19' 
AND website_sessions.utm_source = 'gsearch' AND website_sessions.utm_campaign = 'nonbrand'
GROUP BY 1,2) AS in_tbl
GROUP BY 1;

-- final output, part 1 
SELECT 
CASE WHEN saw_homepage = 1 THEN 'saw_homepage' WHEN saw_lander = 1 THEN 'saw_lander' ELSE 'mistake' END AS segment, 
COUNT(DISTINCT website_session_id) AS sessions, 
COUNT(DISTINCT CASE WHEN saw_product_page = 1 THEN website_session_id ELSE NULL END) AS to_prod,
COUNT(DISTINCT CASE WHEN saw_mrfuzzy_page = 1 THEN website_session_id ELSE NULL END) AS to_mrfuzzy, 
COUNT(DISTINCT CASE WHEN saw_cart_page = 1 THEN website_session_id ELSE NULL END) AS to_cart, 
COUNT(DISTINCT CASE WHEN saw_ship_page = 1 THEN website_session_id ELSE NULL END) AS to_ship,
COUNT(DISTINCT CASE WHEN saw_bil_page = 1 THEN website_session_id ELSE NULL END) AS to_bil,
COUNT(DISTINCT CASE WHEN saw_tnx_page = 1 THEN saw_tnx_page ELSE NULL END) AS to_thx
FROM saw_flag
GROUP BY 1; 

-- final output, conversion rates, part 2
SELECT 
	CASE 
		WHEN saw_homepage = 1 THEN 'saw_homepage' 
		WHEN saw_lander = 1 THEN 'saw_lander' 
        ELSE 'mistake' 
	END AS segment, 
COUNT(DISTINCT CASE WHEN saw_product_page = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT website_session_id) AS lander_clck_rt,
COUNT(DISTINCT CASE WHEN saw_mrfuzzy_page = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN saw_product_page = 1 THEN website_session_id ELSE NULL END) AS products_clck_rt,
COUNT(DISTINCT CASE WHEN saw_cart_page = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN saw_mrfuzzy_page = 1 THEN website_session_id ELSE NULL END) AS mrfuzzy_clck_rt,
COUNT(DISTINCT CASE WHEN saw_ship_page = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN saw_cart_page = 1 THEN website_session_id ELSE NULL END) AS cart_clck_rt, 
COUNT(DISTINCT CASE WHEN saw_bil_page = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN saw_ship_page = 1 THEN website_session_id ELSE NULL END) AS ship_clck_rt,
COUNT(DISTINCT CASE WHEN saw_tnx_page = 1 THEN website_session_id ELSE NULL END)/COUNT(DISTINCT CASE WHEN saw_bil_page = 1 THEN website_session_id ELSE NULL END) AS bil_clck_rt 
FROM saw_flag
GROUP BY 1;

/*
10. I'd love for you to quantify the impact of our billing test as well. Please, analyze the lift generated from the test (Sep 10 - Nov 10), 
in terms of revenue per billing page session, and then pull the number of billing page sessions for the past month to understand monthly impact 
*/
SELECT
	billing_ver, 
    COUNT(DISTINCT website_session_id) AS sessions,
    SUM(price_usd)/ COUNT(DISTINCT website_session_id) AS rev_per_bil_page
FROM (
SELECT
	website_pageviews.website_session_id, 
    website_pageviews.pageview_url AS billing_ver, 
    orders.order_id, 
    orders.price_usd
FROM website_pageviews
LEFT JOIN orders ON orders.website_session_id = website_pageviews.website_session_id
WHERE website_pageviews.created_at > '2012-09-10' AND website_pageviews.created_at < '2012-11-10' 
AND website_pageviews.pageview_url IN ('/billing','/billing-2')) AS in_tbl
 GROUP BY 1; 
 
 -- 22.82 for billing page, 31.33 for billing -2 page, difference - 8.51 USD. 
 
 SELECT 
	COUNT(website_session_id) AS bil_last_month
 FROM website_pageviews
 WHERE website_pageviews.pageview_url IN ('/billing', '/billing-2') AND created_at BETWEEN '2012-10-27' AND '2012-11-27';
 
 -- 1193 billing sessions past month. Value for billing test: 8.51 * 1193 = 10160 USD.

/*
11. We made our 4th product available as a primary product on December 5, 2014 (it was previously only a cross-sell item)
Could you please pull sales data since then, and show how well each product cross-sells from one another
*/

-- first, we create temp table where store list of primary products since December 5th in 2014
CREATE TEMPORARY TABLE primary_products
SELECT 
	order_id,
    primary_product_id,
    created_at
FROM orders
WHERE created_at > '2014-12-05'; 

SELECT
	primary_product_id,
    COUNT(DISTINCT order_id) AS total_orders,
    COUNT(DISTINCT CASE WHEN cross_sell_product = 1 THEN order_id ELSE NULL END) AS xsold_p1,
    COUNT(DISTINCT CASE WHEN cross_sell_product = 2 THEN order_id ELSE NULL END) AS xsold_p2,
    COUNT(DISTINCT CASE WHEN cross_sell_product = 3 THEN order_id ELSE NULL END) AS xsold_p3,
    COUNT(DISTINCT CASE WHEN cross_sell_product = 4 THEN order_id ELSE NULL END) AS xsold_p4, 
    COUNT(DISTINCT CASE WHEN cross_sell_product = 1 THEN order_id ELSE NULL END) / COUNT(DISTINCT order_id) AS p1_xsell_rt, 
    COUNT(DISTINCT CASE WHEN cross_sell_product = 2 THEN order_id ELSE NULL END) / COUNT(DISTINCT order_id) AS p2_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product = 3 THEN order_id ELSE NULL END) / COUNT(DISTINCT order_id) AS p3_xsell_rt,
    COUNT(DISTINCT CASE WHEN cross_sell_product = 4 THEN order_id ELSE NULL END) / COUNT(DISTINCT order_id) AS p4_xsell_rt
FROM(
SELECT 
	primary_products.*, 
    order_items.product_id AS cross_sell_product
FROM primary_products 
LEFT JOIN order_items ON order_items.order_id = primary_products.order_id
AND order_items.is_primary_item = 0 -- only bringin in cross-sells 
) AS primary_w_cross
GROUP BY 1;

-- 12. Found business patterns for sessions and orders through the Day of the Week
SELECT 
	hr,
    ROUND(AVG(CASE WHEN wkd = 0 THEN sessions ELSE NULL END),1) AS mon,
    ROUND(AVG(CASE WHEN wkd = 1 THEN sessions ELSE NULL END), 1) AS tue,
    ROUND(AVG(CASE WHEN wkd = 2 THEN sessions ELSE NULL END),1) AS wed,
	ROUND(AVG(CASE WHEN wkd = 3 THEN sessions ELSE NULL END),1) AS thu,
    ROUND(AVG(CASE WHEN wkd = 4 THEN sessions ELSE NULL END),1) AS fri,
    ROUND(AVG(CASE WHEN wkd = 5 THEN sessions ELSE NULL END),1) AS sat,
    ROUND(AVG(CASE WHEN wkd = 6 THEN sessions ELSE NULL END),1) AS sun
FROM
(SELECT
	DATE(created_at) AS dt, 
    WEEKDAY(created_at) AS wkd, 
    HOUR(created_at) AS hr,
    COUNT(DISTINCT website_session_id) AS sessions
FROM website_sessions
WHERE created_at between '2012-09-15' AND '2012-11-15'
GROUP BY 1,2,3) AS dt_week_hr_sessions
GROUP BY 1;

-- 13. Let's take a look on seasonality 
SELECT 
	YEAR(website_sessions.created_at) AS yr,
    WEEK(website_sessions.created_at) AS wk,
    MIN(DATE(website_sessions.created_at)) AS week_start,
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) AS orders
FROM website_sessions
LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
GROUP BY 1,2;

-- 2013-12-12 - launch of the new product birthday bear
/* 14. Let's pull out pre-post analysis comparing the month before and month after the launch in terms of:
	1. session-to-order conv rate
	2. AOV (average order value)
	3. products per order
	4. revenue per sessions
*/

SELECT 
	CASE 
		WHEN website_sessions.created_at < '2013-12-12' THEN 'a.pre_birthday_bear'
        WHEN website_sessions.created_at > '2013-12-12' THEN 'b.post_birthday_bear'
        ELSE 'error'
	END AS time_period,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS sessions_to_order_conv,
    SUM(orders.price_usd) / COUNT(DISTINCT orders.order_id) AS AOV,
    SUM(orders.items_purchased) / COUNT(DISTINCT orders.order_id) AS prod_per_order, 
    SUM(orders.price_usd) / COUNT(DISTINCT website_sessions.website_session_id) AS rev_per_sess
FROM website_sessions
LEFT JOIN orders ON website_sessions.website_session_id = orders.website_session_id
WHERE website_sessions.created_at >= '2013-11-12' AND website_sessions.created_at <='2014-01-12'
GROUP BY 1; 

/*
15. She wants to see monthly product refunds rates, by product because of new supplier from 2014-09-16
*/
SELECT
	YEAR(order_items.created_at) AS yr,
    MONTH(order_items.created_at) AS mnth,
    COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_items.order_item_id ELSE NULL END) AS p1_orders,
    ROUND(COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_item_refunds.order_item_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN product_id = 1 THEN order_items.order_item_id ELSE NULL END), 2) AS p1_ref_rate,
    COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_items.order_item_id ELSE NULL END) AS p2_orders,
    ROUND(COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_item_refunds.order_item_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN product_id = 2 THEN order_items.order_item_id ELSE NULL END), 2) AS p2_ref_rate,
    COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_items.order_item_id ELSE NULL END) AS p3_orders,
    ROUND(COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_item_refunds.order_item_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN product_id = 3 THEN order_items.order_item_id ELSE NULL END), 2) AS p3_ref_rate,
    COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_items.order_item_id ELSE NULL END) AS p4_orders,
    ROUND(COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_item_refunds.order_item_id ELSE NULL END) /
    COUNT(DISTINCT CASE WHEN product_id = 4 THEN order_items.order_item_id ELSE NULL END), 2) AS p4_ref_rate
FROM order_items
LEFT JOIN order_item_refunds ON order_items.order_id = order_item_refunds.order_id
WHERE order_items.created_at < '2014-10-15'
GROUP BY 1,2;

/*
16. Let's pull out how many of our website visitors come back for another sessions
*/

CREATE TEMPORARY TABLE sessions_w_repeats
SELECT 
	new_sessions.user_id,
    new_sessions.website_session_id,
    website_sessions.website_session_id AS next_session
FROM (
SELECT 
	website_session_id,
    user_id
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-01' AND is_repeat_session = 0) AS new_sessions
LEFT JOIN website_sessions ON website_sessions.user_id = new_sessions.user_id
AND website_sessions.website_session_id > new_sessions.website_session_id
AND website_sessions.is_repeat_session = 1
AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-11-01';

SELECT 
	repeats.num_of_repeats, 
    COUNT(DISTINCT user_id) AS num_of_users
FROM (
SELECT 
	user_id,
    COUNT(DISTINCT next_session) AS num_of_repeats
FROM sessions_w_repeats
GROUP BY 1) AS repeats
GROUP BY 1;

/*
17. Let's show understanding the minimum, maximum and average time between the first and second session 
*/

CREATE TEMPORARY TABLE sessions_w_repeats_diff
SELECT
	fsession.user_id, 
    fsession.website_session_id AS new_session_id,
    fsession.created_at AS new_session_created_at, 
    website_sessions.website_session_id AS repeat_session_id, 
    website_sessions.created_at AS repeat_created_at
FROM(
SELECT 
	website_session_id, 
    created_at, 
    user_id
FROM website_sessions
where created_at BETWEEN '2014-01-01' AND '2014-11-03' AND is_repeat_session = 0) AS fsession
LEFT JOIN website_sessions ON website_sessions.user_id = fsession.user_id
AND website_sessions.website_session_id > fsession.website_session_id
AND website_sessions.is_repeat_session = 1
AND website_sessions.created_at BETWEEN '2014-01-01' AND '2014-11-03';

SELECT
	AVG(days_first_to_second_session) AS avg_days,
    MIN(days_first_to_second_session) AS min_days, 
    MAX(days_first_to_second_session) AS msx_days
FROM(
SELECT
	user_id,
    DATEDIFF(second_created_at, new_session_created_at) AS days_first_to_second_session
FROM(
SELECT
	user_id, 
    new_session_id, 
    new_session_created_at, 
    MIN(repeat_session_id) AS second_session_id,
    MIN(repeat_created_at) AS second_created_at
FROM sessions_w_repeats_diff
WHERE repeat_session_id IS NOT NULL
GROUP BY 1,2,3) AS first_second) AS diff_query; 

/*
18. Comparing new vs. repeat sessions by channel 
*/

SELECT 
	CASE 
    WHEN utm_source IS NULL AND http_referer IN('https://www.gsearch.com', 'https://www.bsearch.com') THEN 'organic_search'
    WHEN utm_campaign = 'nonbrand' THEN 'paid_nonbrand'
    WHEN utm_campaign = 'brand' THEN 'paid_brand'
    WHEN utm_source IS NULL AND http_referer IS NULL THEN 'direct_type'
    WHEN utm_source = 'socialbook' THEN 'paid_social'
	ELSE 'error'
    END AS channel_group,
    COUNT(CASE WHEN is_repeat_session = 0 THEN website_session_id ELSE NULL END) AS new_sessions,
    COUNT(CASE WHEN is_repeat_session = 1 THEN website_session_id ELSE NULL END) AS repeat_sessions
FROM website_sessions
WHERE created_at BETWEEN '2014-01-01' AND '2014-11-05'
GROUP BY 1; 

/*
19. Comparing conversion rate and revenue per session for repeat sessions vs new sessions
*/

SELECT 
	website_sessions.is_repeat_session, 
    COUNT(DISTINCT website_sessions.website_session_id) AS sessions,
    COUNT(DISTINCT orders.order_id) / COUNT(DISTINCT website_sessions.website_session_id) AS conv_rate, 
    SUM(orders.price_usd) /  COUNT(DISTINCT website_sessions.website_session_id) AS rev_per_session
FROM website_sessions
LEFT JOIN orders ON orders.website_session_id = website_sessions.website_session_id
WHERE website_sessions.created_at BETWEEN '2014-01-01' AND '2014-11-08'
GROUP BY 1;
