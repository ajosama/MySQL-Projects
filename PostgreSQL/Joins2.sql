--Finding Matched and Unmatched Rows with FULL OUTER JOIN

SELECT *
  FROM accounts
 FULL JOIN sales_reps ON accounts.sales_rep_id = sales_reps.id

--If unmatched rows existed (they don't for this query), you could isolate
--them by adding the following line to the end of the query:

SELECT *
  FROM accounts
 FULL JOIN sales_reps ON accounts.sales_rep_id = sales_reps.id
WHERE accounts.sales_rep_id IS NULL OR sales_reps.id IS NULL

--JOINs with Comparison Operators

SELECT accounts.name as account_name,
       accounts.primary_poc as poc_name,
       sales_reps.name as sales_rep_name
  FROM accounts
  LEFT JOIN sales_reps
    ON accounts.sales_rep_id = sales_reps.id
   AND accounts.primary_poc < sales_reps.name

--SELF JOINs

SELECT o1.id AS o1_id,
       o1.account_id AS o1_account_id,
       o1.occurred_at AS o1_occurred_at,
       o2.id AS o2_id,
       o2.account_id AS o2_account_id,
       o2.occurred_at AS o2_occurred_at
  FROM orders o1
 LEFT JOIN orders o2
   ON o1.account_id = o2.account_id
  AND o2.occurred_at > o1.occurred_at
  AND o2.occurred_at <= o1.occurred_at + INTERVAL '28 days'
ORDER BY o1.account_id, o1.occurred_at

SELECT we1.id AS we_id,
       we1.account_id AS we1_account_id,
       we1.occurred_at AS we1_occurred_at,
       we1.channel AS we1_channel,
       we2.id AS we2_id,
       we2.account_id AS we2_account_id,
       we2.occurred_at AS we2_occurred_at,
       we2.channel AS we2_channel
  FROM web_events we1 
 LEFT JOIN web_events we2
   ON we1.account_id = we2.account_id
  AND we1.occurred_at > we2.occurred_at
  AND we1.occurred_at <= we2.occurred_at + INTERVAL '1 day'
ORDER BY we1.account_id, we2.occurred_at

/*Without rewriting and running the query, how many results would be returned
if you used UNION instead of UNION ALL in the above query?*/

SELECT *
    FROM accounts

UNION ALL

SELECT *
  FROM accounts
/*2.Pretreating Tables before doing a UNION
Add a WHERE clause to each of the tables that you unioned in the query above, 
filtering the first table where name equals Walmart and filtering the second
table where name equals Disney. Inspect the results then answer the subsequent quiz.*/

SELECT *
    FROM accounts
    WHERE name = 'Walmart'

UNION ALL

SELECT *
  FROM accounts
  WHERE name = 'Disney'
  
/*3.Performing Operations on a Combined Dataset
Perform the union in your first query (under the Appending Data via UNION header)
in a common table expression and name it double_accounts. Then do a COUNT the 
number of times a name appears in the double_accounts table. If you do this 
correctly, your query results should have a count of 2 for each name*/

WITH double_accounts AS (
    SELECT *
      FROM accounts
    
    UNION ALL
    
    SELECT *
      FROM accounts
)

SELECT name,
       COUNT(*) AS name_count
 FROM double_accounts 
GROUP BY 1
ORDER BY 2 DESC