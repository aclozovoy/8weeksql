Week 2 -- Pizza Runner
https://8weeksqlchallenge.com/case-study-2/


-------- SETUP --------

CREATE SCHEMA pizza_runner;
SET search_path = pizza_runner;

DROP TABLE IF EXISTS runners;
CREATE TABLE runners (
  "runner_id" INTEGER,
  "registration_date" DATE
);
INSERT INTO runners
  ("runner_id", "registration_date")
VALUES
  (1, '2021-01-01'),
  (2, '2021-01-03'),
  (3, '2021-01-08'),
  (4, '2021-01-15');


DROP TABLE IF EXISTS customer_orders;
CREATE TABLE customer_orders (
  "order_id" INTEGER,
  "customer_id" INTEGER,
  "pizza_id" INTEGER,
  "exclusions" VARCHAR(4),
  "extras" VARCHAR(4),
  "order_time" TIMESTAMP
);

INSERT INTO customer_orders
  ("order_id", "customer_id", "pizza_id", "exclusions", "extras", "order_time")
VALUES
  ('1', '101', '1', '', '', '2020-01-01 18:05:02'),
  ('2', '101', '1', '', '', '2020-01-01 19:00:52'),
  ('3', '102', '1', '', '', '2020-01-02 23:51:23'),
  ('3', '102', '2', '', NULL, '2020-01-02 23:51:23'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '1', '4', '', '2020-01-04 13:23:46'),
  ('4', '103', '2', '4', '', '2020-01-04 13:23:46'),
  ('5', '104', '1', 'null', '1', '2020-01-08 21:00:29'),
  ('6', '101', '2', 'null', 'null', '2020-01-08 21:03:13'),
  ('7', '105', '2', 'null', '1', '2020-01-08 21:20:29'),
  ('8', '102', '1', 'null', 'null', '2020-01-09 23:54:33'),
  ('9', '103', '1', '4', '1, 5', '2020-01-10 11:22:59'),
  ('10', '104', '1', 'null', 'null', '2020-01-11 18:34:49'),
  ('10', '104', '1', '2, 6', '1, 4', '2020-01-11 18:34:49');


DROP TABLE IF EXISTS runner_orders;
CREATE TABLE runner_orders (
  "order_id" INTEGER,
  "runner_id" INTEGER,
  "pickup_time" VARCHAR(19),
  "distance" VARCHAR(7),
  "duration" VARCHAR(10),
  "cancellation" VARCHAR(23)
);

INSERT INTO runner_orders
  ("order_id", "runner_id", "pickup_time", "distance", "duration", "cancellation")
VALUES
  ('1', '1', '2020-01-01 18:15:34', '20km', '32 minutes', ''),
  ('2', '1', '2020-01-01 19:10:54', '20km', '27 minutes', ''),
  ('3', '1', '2020-01-03 00:12:37', '13.4km', '20 mins', NULL),
  ('4', '2', '2020-01-04 13:53:03', '23.4', '40', NULL),
  ('5', '3', '2020-01-08 21:10:57', '10', '15', NULL),
  ('6', '3', 'null', 'null', 'null', 'Restaurant Cancellation'),
  ('7', '2', '2020-01-08 21:30:45', '25km', '25mins', 'null'),
  ('8', '2', '2020-01-10 00:15:02', '23.4 km', '15 minute', 'null'),
  ('9', '2', 'null', 'null', 'null', 'Customer Cancellation'),
  ('10', '1', '2020-01-11 18:50:20', '10km', '10minutes', 'null');


DROP TABLE IF EXISTS pizza_names;
CREATE TABLE pizza_names (
  "pizza_id" INTEGER,
  "pizza_name" TEXT
);
INSERT INTO pizza_names
  ("pizza_id", "pizza_name")
VALUES
  (1, 'Meatlovers'),
  (2, 'Vegetarian');


DROP TABLE IF EXISTS pizza_recipes;
CREATE TABLE pizza_recipes (
  "pizza_id" INTEGER,
  "toppings" TEXT
);
INSERT INTO pizza_recipes
  ("pizza_id", "toppings")
VALUES
  (1, '1, 2, 3, 4, 5, 6, 8, 10'),
  (2, '4, 6, 7, 9, 11, 12');


DROP TABLE IF EXISTS pizza_toppings;
CREATE TABLE pizza_toppings (
  "topping_id" INTEGER,
  "topping_name" TEXT
);
INSERT INTO pizza_toppings
  ("topping_id", "topping_name")
VALUES
  (1, 'Bacon'),
  (2, 'BBQ Sauce'),
  (3, 'Beef'),
  (4, 'Cheese'),
  (5, 'Chicken'),
  (6, 'Mushrooms'),
  (7, 'Onions'),
  (8, 'Pepperoni'),
  (9, 'Peppers'),
  (10, 'Salami'),
  (11, 'Tomatoes'),
  (12, 'Tomato Sauce');
  
  
  
  
  
  -------- PROBLEMS --------
  -- A PIZZA METRICS
-- 1. How many pizzas were ordered?
SELECT
	COUNT(*)
FROM pizza_runner.customer_orders;



-- 2. How many unique customer orders were made?
SELECT
	COUNT(DISTINCT customer_id)
FROM pizza_runner.customer_orders;



-- 3. How many successful orders were delivered by each runner?
WITH cte AS (
SELECT
	runner_id,
    cancellation,
    CASE
    	WHEN cancellation LIKE '%Cancellation%'THEN True
    	ELSE False
        END AS Cancelled
FROM pizza_runner.runner_orders
)

SELECT
    runner_id,
    COUNT(*)
FROM cte
WHERE Cancelled = false
GROUP BY runner_id;




-- 4. How many of each type of pizza was delivered?
WITH cte AS (
SELECT *,
    CASE
    	WHEN ro.cancellation LIKE '%Cancellation%'THEN True
    	ELSE False
        END AS Cancelled
FROM pizza_runner.customer_orders AS co
LEFT JOIN pizza_runner.runner_orders AS ro
	ON co.order_id = ro.order_id
)

SELECT
	pizza_id,
    COUNT(*)
FROM cte
WHERE Cancelled = false
GROUP BY pizza_id;



-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
WITH cte AS (
SELECT *,
	CASE
    	WHEN pn.pizza_name LIKE '%Vegetarian%' THEN true
        ELSE false
        END AS vegetarian,
	CASE
    	WHEN pn.pizza_name LIKE '%Meatlovers%' THEN true
        ELSE false
        END AS meatlovers   
FROM pizza_runner.customer_orders AS co
LEFT JOIN pizza_runner.pizza_names AS pn
	ON co.pizza_id = pn.pizza_id
)


SELECT
	customer_id,
    COUNT(*) AS total,
    COUNT(CASE WHEN vegetarian = true THEN 1 END) AS vegetarian,
    COUNT(CASE WHEN meatlovers = true THEN 1 END) AS meatlovers    
FROM cte
GROUP BY customer_id;


-- 6. What was the maximum number of pizzas delivered in a single order?
WITH cte AS (
SELECT
	co.order_id,
  	co.customer_id,
  	co.pizza_id,
  	ro.runner_id,
    CASE
    	WHEN ro.cancellation LIKE '%Cancellation%'THEN True
    	ELSE False
        END AS Cancelled
FROM pizza_runner.customer_orders AS co
LEFT JOIN pizza_runner.runner_orders AS ro
	ON co.order_id = ro.order_id
)


SELECT
	order_id,
    COUNT(CASE WHEN cancelled = false THEN 1 END) AS pizza_count
FROM cte
GROUP BY order_id
ORDER BY pizza_count DESC
LIMIT 1;



-- 7. For each customer, how many delivered pizzas had at least 1 change and how many had no changes?
WITH cte AS (
SELECT
	co.order_id,
  	co.customer_id,
  	co.pizza_id,
  	co.exclusions,
    CASE
		WHEN co.exclusions IS NULL THEN false  		
  		WHEN co.exclusions = '' THEN false
  		WHEN co.exclusions = 'null' THEN false
  		ELSE true
  		END AS has_exclusions,
  	co.extras,
    CASE
  		WHEN co.extras IS NULL THEN false
  		WHEN co.extras = '' THEN false
  		WHEN co.extras = 'null' THEN false
  		ELSE true
  		END AS has_extras,
  	ro.runner_id,
    CASE
    	WHEN ro.cancellation LIKE '%Cancellation%'THEN True
    	ELSE False
        END AS Cancelled
FROM pizza_runner.customer_orders AS co
LEFT JOIN pizza_runner.runner_orders AS ro
	ON co.order_id = ro.order_id
)

SELECT
	customer_id,
	COUNT(CASE
      WHEN has_exclusions = true
      	OR has_extras = true THEN 1 END) AS has_changes,
    COUNT(CASE
      WHEN has_exclusions = false
      	AND has_extras = false THEN 1 END) AS no_changes
FROM cte
GROUP BY customer_id;



-- 8. How many pizzas were delivered that had both exclusions and extras?
WITH cte AS (
SELECT
	co.order_id,
  	co.customer_id,
  	co.pizza_id,
  	co.exclusions,
    CASE
		WHEN co.exclusions IS NULL THEN false  		
  		WHEN co.exclusions = '' THEN false
  		WHEN co.exclusions = 'null' THEN false
  		ELSE true
  		END AS has_exclusions,
  	co.extras,
    CASE
  		WHEN co.extras IS NULL THEN false
  		WHEN co.extras = '' THEN false
  		WHEN co.extras = 'null' THEN false
  		ELSE true
  		END AS has_extras,
  	ro.runner_id,
    CASE
    	WHEN ro.cancellation LIKE '%Cancellation%'THEN True
    	ELSE False
        END AS Cancelled
FROM pizza_runner.customer_orders AS co
LEFT JOIN pizza_runner.runner_orders AS ro
	ON co.order_id = ro.order_id
)

SELECT
    COUNT(CASE
      WHEN has_exclusions = true
      	AND has_extras = true THEN 1 END) AS exclusions_and_extras
FROM cte;

-- 9. What was the total volume of pizzas ordered for each hour of the day?
SELECT
	to_char(order_time,'HH24') AS hour,
    COUNT(*)
FROM pizza_runner.customer_orders AS co
GROUP BY to_char(order_time,'HH24');

-- 10. What was the volume of orders for each day of the week?
SELECT
	to_char(order_time,'Day') AS day,
    COUNT(*)
FROM pizza_runner.customer_orders AS co
GROUP BY to_char(order_time,'Day');




-- B. RUNNER AND CUSTOMER EXPERIENCE

-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
SELECT
	to_char(registration_date,'W') AS week,
    COUNT(*)
FROM pizza_runner.runners AS co
GROUP BY to_char(registration_date,'W')
ORDER BY to_char(registration_date,'W');



-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza Runner HQ to pickup the order?
WITH ro_clean AS (
SELECT 
	order_id,
  	runner_id,
  	TO_TIMESTAMP(ro.pickup_time,'YYYY-MM-DD HH24:MI:SS') AS pickup_time
FROM pizza_runner.runner_orders AS ro
WHERE ro.cancellation NOT LIKE '%Cancellation%' OR
  	ro.cancellation IS NULL
)


SELECT
	ro.runner_id,
    to_char(AVG(ro.pickup_time - co.order_time), 'MI') AS avg_minutes_to_pickup
FROM pizza_runner.customer_orders AS co
LEFT JOIN ro_clean AS ro
	ON co.order_id = ro.order_id
WHERE ro.pickup_time IS NOT NULL
GROUP BY ro.runner_id;


-- 3. Is there any relationship between the number of pizzas and how long the order takes to prepare?
WITH ro_clean AS (
SELECT 
	order_id,
  	runner_id,
  	TO_TIMESTAMP(ro.pickup_time,'YYYY-MM-DD HH24:MI:SS') AS pickup_time
FROM pizza_runner.runner_orders AS ro
WHERE ro.cancellation NOT LIKE '%Cancellation%' OR
  	ro.cancellation IS NULL
),
pizzas_per_order AS (
SELECT
	order_id,
  	COUNT(*) AS pizzas_in_order
FROM pizza_runner.customer_orders
GROUP BY order_id
)

SELECT
	ppo.pizzas_in_order,
    to_char(AVG(ro.pickup_time - co.order_time), 'MI') AS avg_minutes_to_pickup
FROM pizza_runner.customer_orders AS co
LEFT JOIN ro_clean AS ro
	ON co.order_id = ro.order_id
LEFT JOIN pizzas_per_order AS ppo
	ON co.order_id = ppo.order_id
WHERE ro.pickup_time IS NOT NULL
GROUP BY ppo.pizzas_in_order
ORDER BY ppo.pizzas_in_order;

-- 4. What was the average distance travelled for each customer?
WITH cte AS (
SELECT
  	order_id,
	CAST(REPLACE(distance,'km','') AS REAL) AS distance_clean,
    CAST(LEFT(duration,2) AS REAL) AS duration_clean
FROM pizza_runner.runner_orders AS ro
WHERE ro.cancellation NOT LIKE '%Cancellation%' OR
  	ro.cancellation IS NULL
)

SELECT
	co.customer_id,
    AVG(distance_clean) AS ave_distance
FROM pizza_runner.customer_orders AS co
LEFT JOIN cte
	ON co.order_id = cte.order_id
GROUP BY co.customer_id
ORDER BY co.customer_id;
  
-- 5. What was the difference between the longest and shortest delivery times for all orders?
WITH cte AS (
SELECT
  	order_id,
  	runner_id,
	CAST(REPLACE(distance,'km','') AS REAL) AS distance_clean,
    CAST(LEFT(duration,2) AS REAL) AS duration_clean
FROM pizza_runner.runner_orders AS ro
WHERE ro.cancellation NOT LIKE '%Cancellation%' OR
  	ro.cancellation IS NULL
)

SELECT
    MAX(duration_clean)-MIN(duration_clean) AS delta
FROM pizza_runner.customer_orders AS co
LEFT JOIN cte
	ON co.order_id = cte.order_id;

-- 6. What was the average speed for each runner for each delivery and do you notice any trend for these values?
WITH cte AS (
SELECT
  	order_id,
  	runner_id,
	CAST(REPLACE(distance,'km','') AS REAL) AS distance_clean,
    CAST(LEFT(duration,2) AS REAL) AS duration_clean
FROM pizza_runner.runner_orders AS ro
WHERE ro.cancellation NOT LIKE '%Cancellation%' OR
  	ro.cancellation IS NULL
)

SELECT
	ro.runner_id,
    AVG(distance_clean/duration_clean) AS ave_speed__km_per_min
FROM pizza_runner.customer_orders AS co
LEFT JOIN cte AS ro
	ON co.order_id = ro.order_id
WHERE ro.runner_id IS NOT NULL
GROUP BY ro.runner_id
ORDER BY ro.runner_id;

-- 7. What is the successful delivery percentage for each runner?
WITH cte AS (
SELECT
  	runner_id,
  	COUNT(*)
FROM pizza_runner.runner_orders
GROUP BY runner_id
),
cte2 AS (
SELECT
  	runner_id,
  	COUNT(*)
FROM pizza_runner.runner_orders AS ro
WHERE ro.cancellation NOT LIKE '%Cancellation%' OR
  	ro.cancellation IS NULL
GROUP BY runner_id
)


SELECT
	cte.runner_id,
    cte.count,
    cte2.count,
    CAST(cte2.count AS DECIMAL(9,2))/CAST(cte.count AS DECIMAL(9,2)) AS megan_is_cool
FROM cte
LEFT JOIN cte2
	ON cte.runner_id = cte2.runner_id;



-- C. INGREDIENT OPTIMISATION

-- 1. What are the standard ingredients for each pizza?
WITH cte AS (
SELECT
	pizza_id,
    CAST(UNNEST(string_to_array(toppings,',')) AS INTEGER) AS topping_id
FROM pizza_runner.pizza_recipes
)

SELECT
	pn.pizza_name,
	STRING_AGG (pt.topping_name, ', ') AS ingredients
FROM cte
LEFT JOIN pizza_runner.pizza_names AS pn
	ON cte.pizza_id = pn.pizza_id
LEFT JOIN pizza_runner.pizza_toppings AS pt
	ON cte.topping_id = pt.topping_id
GROUP BY pn.pizza_name;



-- 2. What was the most commonly added extra?
WITH extra_list AS (
SELECT
	order_id,
    CAST(UNNEST(string_to_array(extras,',')) AS INTEGER) AS extra_toppings
FROM pizza_runner.customer_orders AS co
WHERE extras IS NOT NULL AND extras <> '' AND extras <> 'null'
)

SELECT
	pt.topping_name,
	COUNT(*)
FROM extra_list AS ex
LEFT JOIN pizza_runner.pizza_toppings AS pt
	ON ex.extra_toppings = pt.topping_id
GROUP BY topping_name
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 3. What was the most common exclusion?
WITH exclusions_list AS (
SELECT
	order_id,
    CAST(UNNEST(string_to_array(exclusions,',')) AS INTEGER) AS exclus
FROM pizza_runner.customer_orders AS co
WHERE exclusions IS NOT NULL AND exclusions <> '' AND exclusions <> 'null'
)

SELECT
	pt.topping_name,
    COUNT(*)
FROM exclusions_list AS exc
LEFT JOIN pizza_runner.pizza_toppings AS pt
	ON exc.exclus = pt.topping_id
GROUP BY topping_name
ORDER BY COUNT(*) DESC
LIMIT 1;

-- 4. Generate an order item for each record in the customers_orders table in the format of one of the following:
        --Meat Lovers
        --Meat Lovers - Exclude Beef
        --Meat Lovers - Extra Bacon
        --Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
WITH unique_orders AS (
SELECT
  	*,
  	ROW_NUMBER() OVER() AS unique_pizza_id
FROM pizza_runner.customer_orders
),
extra_list AS (
SELECT
	order_id,
  	unique_pizza_id,
    CAST(UNNEST(string_to_array(extras,',')) AS INTEGER) AS extra_toppings
FROM unique_orders AS co
WHERE extras IS NOT NULL AND extras <> '' AND extras <> 'null'
),
extra_list2 AS(
SELECT unique_pizza_id,
  STRING_AGG (pt.topping_name, ', ') AS ingredients
FROM extra_list
LEFT JOIN pizza_runner.pizza_toppings AS pt
  	ON extra_list.extra_toppings = pt.topping_id
GROUP BY unique_pizza_id
),
exclusions_list AS (
SELECT
	order_id,
    unique_pizza_id,
    CAST(UNNEST(string_to_array(exclusions,',')) AS INTEGER) AS excluded_toppings
FROM unique_orders AS co
WHERE exclusions IS NOT NULL AND exclusions <> '' AND exclusions <> 'null'
),
exclusions_list2 AS(
SELECT unique_pizza_id,
  STRING_AGG (pt.topping_name, ', ') AS ingredients
FROM exclusions_list
LEFT JOIN pizza_runner.pizza_toppings AS pt
  	ON exclusions_list.excluded_toppings = pt.topping_id
GROUP BY unique_pizza_id
)

SELECT
	co.order_id,
    co.customer_id,
    co.pizza_id,
    co.exclusions,
    co.extras,
    co.order_time,
	CASE
    	WHEN ex.ingredients IS NULL AND exc.ingredients IS NULL
        	THEN pizza_name
        WHEN ex.ingredients IS NULL
        	THEN CONCAT(pizza_name, ' - Exclude ',exc.ingredients)
        WHEN exc.ingredients IS NULL
        	THEN CONCAT(pizza_name, ' - Extra ',ex.ingredients)
        ELSE CONCAT(pizza_name, ' - Exclude ',exc.ingredients, ' - Extra ',ex.ingredients)
        END AS recipe
FROM unique_orders AS co
LEFT JOIN pizza_runner.pizza_names AS pn
	ON co.pizza_id = pn.pizza_id
LEFT JOIN extra_list2 AS ex
	ON co.unique_pizza_id = ex.unique_pizza_id
LEFT JOIN exclusions_list2 AS exc
	ON co.unique_pizza_id = exc.unique_pizza_id;



-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza order from the customer_orders table and add a 2x in front of any relevant ingredients
 --For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
 
 
-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by most frequent first?



-- D. PRICING AND RATINGS

-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no charges for changes - how much money has Pizza Runner made so far if there are no delivery fees?


-- 2. What if there was an additional $1 charge for any pizza extras?
        --Add cheese is $1 extra
        
        
-- 3. The Pizza Runner team now wants to add an additional ratings system that allows customers to rate their runner, how would you design an additional table for this new dataset - generate a schema for this new table and insert your own data for ratings for each successful customer order between 1 to 5.


-- 4. Using your newly generated table - can you join all of the information together to form a table which has the following information for successful deliveries?
        --customer_id
        --order_id
        --runner_id
        --rating
        --order_time
        --pickup_time
        --Time between order and pickup
        --Delivery duration
        --Average speed
        --Total number of pizzas
        
        
-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for extras and each runner is paid $0.30 per kilometre traveled - how much money does Pizza Runner have left over after these deliveries?
