select channel,avg(event_count),count(*) from
(select Date_trunc('day',occurred_at) as day,
channel,count(*) as event_count
from web_events
group by 1,2
order by 3 desc)
tt
group by 1;

select sum(total_amt_usd),avg(standard_qty) asa,
	   avg(gloss_qty) aga,
	   avg(poster_qty) pau 
	   from orders
	   where DATE_TRUNC('month',occurred_at)=(select DATE_TRUNC('month',MIN(occurred_at))
											  from orders)
			
select sales_rep_name,region_name,sum(tau) from
(select s.name sales_rep_name,r.name region_name,o.total_amt_usd tau
from region r
join sales_reps s
on r.id = s.region_id
join accounts a
on s.id = a.sales_rep_id
join orders o
on a.id = o.account_id) sub
group by 1,2
order by 3;
								
/*1.Provide the name of the sales_rep in each region with the largest amount of
total_amt_usd sales.*/

--First, I wanted to find the total_amt_usd totals associated with each sales rep,
--and I also wanted the region in which they were located. The query below provided
--this information.

SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY 1,2
ORDER BY 3 DESC;

--Next, I pulled the max for each region, and then we can use this to pull those
--rows in our final result.

SELECT region_name, MAX(total_amt) total_amt
        FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
                FROM sales_reps s
                JOIN accounts a
                ON a.sales_rep_id = s.id
                JOIN orders o
                ON o.account_id = a.id
                JOIN region r
                ON r.id = s.region_id
                GROUP BY 1, 2) t1
        GROUP BY 1;

--Essentially, this is a JOIN of these two tables, where the region and amount match.

SELECT t3.rep_name, t3.region_name, t3.total_amt
FROM(SELECT region_name, MAX(total_amt) total_amt
        FROM(SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
                FROM sales_reps s
                JOIN accounts a
                ON a.sales_rep_id = s.id
                JOIN orders o
                ON o.account_id = a.id
                JOIN region r
                ON r.id = s.region_id
                GROUP BY 1, 2) t1
        GROUP BY 1) t2
JOIN (SELECT s.name rep_name, r.name region_name, SUM(o.total_amt_usd) total_amt
        FROM sales_reps s
        JOIN accounts a
        ON a.sales_rep_id = s.id
        JOIN orders o
        ON o.account_id = a.id
        JOIN region r
        ON r.id = s.region_id
        GROUP BY 1,2
        ORDER BY 3 DESC) t3
ON t3.region_name = t2.region_name AND t3.total_amt = t2.total_amt;

/*2.For the region with the largest sales total_amt_usd, how many total orders
were placed?*/

--The first query I wrote was to pull the total_amt_usd for each region.

SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name;

--Then we just want the region with the max amount from this table. 
--There are two ways I considered getting this amount. One was to pull the max
--using a subquery. Another way is to order descending and just pull the top value.

SELECT MAX(total_amt)
FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
                FROM sales_reps s
                JOIN accounts a
                ON a.sales_rep_id = s.id
                JOIN orders o
                ON o.account_id = a.id
                JOIN region r
                ON r.id = s.region_id
                GROUP BY r.name) sub;

--Finally, we want to pull the total orders for the region with this amount:

SELECT r.name, COUNT(o.total) total_orders
FROM sales_reps s
JOIN accounts a
ON a.sales_rep_id = s.id
JOIN orders o
ON o.account_id = a.id
JOIN region r
ON r.id = s.region_id
GROUP BY r.name
HAVING SUM(o.total_amt_usd) = (
         SELECT MAX(total_amt)
         FROM (SELECT r.name region_name, SUM(o.total_amt_usd) total_amt
                 FROM sales_reps s
                 JOIN accounts a
                 ON a.sales_rep_id = s.id
                 JOIN orders o
                 ON o.account_id = a.id
                 JOIN region r
                 ON r.id = s.region_id
                 GROUP BY r.name) sub);

--This provides the Northeast with 2357 orders.

/*3.How many accounts had more total purchases than the account name which has
bought the most standard_qty paper throughout their lifetime as a customer?*/

--First, we want to find the account that had the most standard_qty paper. 
--The query here pulls that account, as well as the total amount:

SELECT a.name account_name, SUM(o.standard_qty) total_std, SUM(o.total) total
FROM accounts a
JOIN orders o
ON o.account_id = a.id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;

--Now, I want to use this to pull all the accounts with more total sales:

SELECT a.name
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY 1
HAVING SUM(o.total) > (SELECT total 
                      FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                            FROM accounts a
                            JOIN orders o
                            ON o.account_id = a.id
                            GROUP BY 1
                            ORDER BY 2 DESC
                            LIMIT 1) sub);

--This is now a list of all the accounts with more total orders. We can get the 
--count with just another simple subquery.

SELECT COUNT(*)
FROM (SELECT a.name
          FROM orders o
          JOIN accounts a
          ON a.id = o.account_id
          GROUP BY 1
          HAVING SUM(o.total) > (SELECT total 
                      FROM (SELECT a.name act_name, SUM(o.standard_qty) tot_std, SUM(o.total) total
                            FROM accounts a
                            JOIN orders o
                            ON o.account_id = a.id
                            GROUP BY 1
                            ORDER BY 2 DESC
                            LIMIT 1) inner_tab)
                ) counter_tab;

/*4.For the customer that spent the most (in total over their lifetime as a customer)
total_amt_usd, how many web_events did they have for each channel?*/

--Here, we first want to pull the customer with the most spent in lifetime value.

SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 1;

--Now, we want to look at the number of events on each channel this company had, 
--which we can match with just the id.

SELECT a.name, w.channel, COUNT(*)
FROM accounts a
JOIN web_events w
ON a.id = w.account_id AND a.id =  (SELECT id
                        FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
                              FROM orders o
                              JOIN accounts a
                              ON a.id = o.account_id
                              GROUP BY a.id, a.name
                              ORDER BY 3 DESC
                              LIMIT 1) inner_table)
GROUP BY 1, 2
ORDER BY 3 DESC;

--I added an ORDER BY for no real reason, and the account name to assure I was
--only pulling from one account.

/*5.What is the lifetime average amount spent in terms of total_amt_usd for the
top 10 total spending accounts?*/

--First, we just want to find the top 10 accounts in terms of highest total_amt_usd.

SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
FROM orders o
JOIN accounts a
ON a.id = o.account_id
GROUP BY a.id, a.name
ORDER BY 3 DESC
LIMIT 10;

--Now, we just want the average of these 10 amounts.

SELECT AVG(tot_spent)
FROM (SELECT a.id, a.name, SUM(o.total_amt_usd) tot_spent
         FROM orders o
         JOIN accounts a
         ON a.id = o.account_id
         GROUP BY a.id, a.name
         ORDER BY 3 DESC
          LIMIT 10) temp;
		  