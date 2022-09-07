Week 3 - Foodie Fi
https://8weeksqlchallenge.com/case-study-3/

-------- SETUP --------
CREATE SCHEMA foodie_fi;
SET search_path = foodie_fi;

CREATE TABLE plans (
  plan_id INTEGER,
  plan_name VARCHAR(13),
  price DECIMAL(5,2)
);

INSERT INTO plans
  (plan_id, plan_name, price)
VALUES
  ('0', 'trial', '0'),
  ('1', 'basic monthly', '9.90'),
  ('2', 'pro monthly', '19.90'),
  ('3', 'pro annual', '199'),
  ('4', 'churn', null);



CREATE TABLE subscriptions (
  customer_id INTEGER,
  plan_id INTEGER,
  start_date DATE
);

INSERT INTO subscriptions
  (customer_id, plan_id, start_date)
VALUES
  ('1', '0', '2020-08-01'),
  ('1', '1', '2020-08-08'),
  ('2', '0', '2020-09-20'),
  ('2', '3', '2020-09-27'),
  ('3', '0', '2020-01-13'),
  ('3', '1', '2020-01-20'),
  ('4', '0', '2020-01-17'),
  ('4', '1', '2020-01-24'),
  ('4', '4', '2020-04-21'),
  ('5', '0', '2020-08-03'),
  ('5', '1', '2020-08-10'),
  ('6', '0', '2020-12-23'),
  ('6', '1', '2020-12-30'),
  ('6', '4', '2021-02-26'),
  ('7', '0', '2020-02-05'),
  ('7', '1', '2020-02-12'),
  ('7', '2', '2020-05-22'),
  ('8', '0', '2020-06-11'),
  ('8', '1', '2020-06-18'),
  ('8', '2', '2020-08-03'),
  ('9', '0', '2020-12-07'),
  ('9', '3', '2020-12-14'),
  ('10', '0', '2020-09-19'),
  ('10', '2', '2020-09-26'),
-- ........



-------- QUESTIONS --------
-- A. Customer Journey

-- Based off the 8 sample customers provided in the sample from the subscriptions table, write a brief description about each customer’s onboarding journey.

-- Try to keep it as short as possible - you may also want to run some sort of join to make your explanations a bit easier!

--SELECT *
--FROM foodie_fi.subscriptions AS s
--LEFT JOIN foodie_fi.plans AS p
--	ON s.plan_id = p.plan_id
--ORDER BY s.customer_id, s.start_date;

-- Users start with a free trial before upgrading to a paid subscription



-- B. Data Analysis Questions

-- 1. How many customers has Foodie-Fi ever had?
SELECT
	COUNT(DISTINCT s.customer_id) AS total_customers
FROM foodie_fi.subscriptions AS s;


-- 2. What is the monthly distribution of trial plan start_date values for our dataset - use the start of the month as the group by value
WITH temp AS (
SELECT
	*,
	to_char(s.start_date,'MM') AS start_month
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
	ON s.plan_id = p.plan_id
WHERE p.plan_name = 'trial'
ORDER BY s.customer_id, s.start_date
)

SELECT
	temp.start_month,
    COUNT(*)
FROM temp
GROUP BY temp.start_month
ORDER BY temp.start_month;

-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the breakdown by count of events for each plan_name
SELECT
	p.plan_name,
    COUNT(*)
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
	ON s.plan_id = p.plan_id
WHERE CAST(to_char(s.start_date,'YYYY') AS INT) > 2020
GROUP BY p.plan_name
ORDER BY p.plan_name;



-- 4. What is the customer count and percentage of customers who have churned rounded to 1 decimal place?
-- WITH total AS (
SELECT
  CAST(
    (
    CAST(MAX((SELECT COUNT(DISTINCT s.customer_id)
    	FROM foodie_fi.subscriptions AS s
		LEFT JOIN foodie_fi.plans AS p
			ON s.plan_id = p.plan_id
		WHERE p.plan_name = 'churn')) AS DECIMAL(9,1))
    /
	CAST(MAX((SELECT COUNT(DISTINCT s.customer_id)
    	FROM foodie_fi.subscriptions AS s)) AS DECIMAL(9,1))
     )*100
   AS DECIMAL(9,1)) AS percent_churn
FROM foodie_fi.subscriptions AS s;


-- 5. How many customers have churned straight after their initial free trial - what percentage is this rounded to the nearest whole number?
WITH temp AS (
SELECT
	s.customer_id,
	CASE
  		WHEN STRING_AGG (p.plan_name, ', ') LIKE '%trial, churn%'
  		THEN true
  		ELSE false
  		END AS trial_only
FROM foodie_fi.subscriptions AS s
LEFT JOIN foodie_fi.plans AS p
	ON s.plan_id = p.plan_id
GROUP BY s.customer_id
ORDER BY s.customer_id
)

SELECT
  CAST(
    (
    CAST((SELECT
		COUNT(*) AS count_of_trial_only
		FROM temp
		WHERE trial_only = true) AS DECIMAL(9,2))
     /
     CAST(COUNT(*) AS DECIMAL(9,2))
     )*100
     AS DECIMAL(9,1)) AS percent_trial_only
FROM temp;


-- 6. What is the number and percentage of customer plans after their initial free trial?


-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at 2020-12-31?
-- 8. How many customers have upgraded to an annual plan in 2020?
-- 9. How many days on average does it take for a customer to an annual plan from the day they join Foodie-Fi?
-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days, 31-60 days etc)
-- 11. How many customers downgraded from a pro monthly to a basic monthly plan in 2020?
