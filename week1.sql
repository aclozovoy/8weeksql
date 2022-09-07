Week 1
https://8weeksqlchallenge.com/case-study-1/


---------- QUESTIONS -----------

CREATE SCHEMA dannys_diner;
SET search_path = dannys_diner;

CREATE TABLE sales (
  "customer_id" VARCHAR(1),
  "order_date" DATE,
  "product_id" INTEGER
);

INSERT INTO sales
  ("customer_id", "order_date", "product_id")
VALUES
  ('A', '2021-01-01', '1'),
  ('A', '2021-01-01', '2'),
  ('A', '2021-01-07', '2'),
  ('A', '2021-01-10', '3'),
  ('A', '2021-01-11', '3'),
  ('A', '2021-01-11', '3'),
  ('B', '2021-01-01', '2'),
  ('B', '2021-01-02', '2'),
  ('B', '2021-01-04', '1'),
  ('B', '2021-01-11', '1'),
  ('B', '2021-01-16', '3'),
  ('B', '2021-02-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-01', '3'),
  ('C', '2021-01-07', '3');
 

CREATE TABLE menu (
  "product_id" INTEGER,
  "product_name" VARCHAR(5),
  "price" INTEGER
);

INSERT INTO menu
  ("product_id", "product_name", "price")
VALUES
  ('1', 'sushi', '10'),
  ('2', 'curry', '15'),
  ('3', 'ramen', '12');
  

CREATE TABLE members (
  "customer_id" VARCHAR(1),
  "join_date" DATE
);

INSERT INTO members
  ("customer_id", "join_date")
VALUES
  ('A', '2021-01-07'),
  ('B', '2021-01-09');




---------- QUESTIONS -----------

-- 1. What is the total amount each customer spent at the restaurant?
SELECT
	customer_id,
    SUM(price) AS "total spent"
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.menu AS m
	ON s.product_id = m.product_id
GROUP BY customer_id;

-- 2. How many days has each customer visited the restaurant?
SELECT
	customer_id,
    COUNT(DISTINCT order_date) AS "days visited"
FROM dannys_diner.sales AS s
GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?
WITH temp AS (
SELECT
    s.customer_id,
  	s.order_date,
    m.product_name,
    RANK() OVER (PARTITION BY
                 	customer_id
                 ORDER BY
                 	order_date
                 ) AS rnk
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.menu AS m
	ON s.product_id = m.product_id
)

SELECT
	customer_id,
    product_name
FROM temp
WHERE rnk = 1;


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
SELECT
	m.product_name,
    COUNT(m.product_name)
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.menu AS m
	ON s.product_id = m.product_id
GROUP BY m.product_name
ORDER BY COUNT(m.product_name) DESC
LIMIT 1;

-- 5. Which item was the most popular for each customer?
WITH cte AS (SELECT
	s.customer_id,
	m.product_name,
    COUNT(*),
    RANK() OVER (PARTITION BY
                 	s.customer_id
                 ORDER BY
                 	COUNT(*)
                 ) AS sale_rank
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.menu AS m
	ON s.product_id = m.product_id
GROUP BY s.customer_id, m.product_name
ORDER BY s.customer_id, COUNT(*)
)

SELECT customer_id, product_name, count
FROM cte
WHERE sale_rank = 1;

-- 6. Which item was purchased first by the customer after they became a member?
WITH cte AS (
SELECT
	s.customer_id,
	s.product_id,
	m.product_name,
    RANK() OVER (PARTITION BY
                 	s.customer_id
                 ORDER BY
                 	s.order_date - mem.join_date
                 ) AS rnk
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.members AS mem
	ON s.customer_id = mem.customer_id
LEFT JOIN dannys_diner.menu AS m
	ON s.product_id = m.product_id
WHERE s.order_date - mem.join_date >= 0
ORDER BY s.customer_id
)

SELECT customer_id,
	product_name
FROM cte
WHERE rnk = 1;

-- 7. Which item was purchased just before the customer became a member?
WITH cte AS (
SELECT
	s.customer_id,
	s.product_id,
	m.product_name,
    RANK() OVER (PARTITION BY
                 	s.customer_id
                 ORDER BY
                 	s.order_date - mem.join_date DESC
                 ) AS rnk
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.members AS mem
	ON s.customer_id = mem.customer_id
LEFT JOIN dannys_diner.menu AS m
	ON s.product_id = m.product_id
WHERE s.order_date - mem.join_date < 0 OR s.order_date - mem.join_date IS NULL
ORDER BY s.customer_id
)

SELECT customer_id,
	product_name
FROM cte
WHERE rnk = 1;

-- 8. What is the total items and amount spent for each member before they became a member?
WITH cte AS (
SELECT
	s.customer_id,
	s.product_id,
	m.product_name,
    m.price
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.members AS mem
	ON s.customer_id = mem.customer_id
LEFT JOIN dannys_diner.menu AS m
	ON s.product_id = m.product_id
WHERE s.order_date - mem.join_date < 0 OR s.order_date - mem.join_date IS NULL
ORDER BY s.customer_id
)

SELECT customer_id,
	COUNT(*),
    SUM(price)
FROM cte
GROUP BY customer_id;


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
WITH cte AS (
SELECT
	s.customer_id,
    m.product_name,
    m.price,
	CASE
    	WHEN m.product_name = 'sushi' THEN 20 * m.price
        ELSE 10 * m.price
    	END AS points
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.members AS mem
	ON s.customer_id = mem.customer_id
LEFT JOIN dannys_diner.menu AS m
	ON s.product_id = m.product_id
ORDER BY s.customer_id
)


SELECT
	customer_id,
    SUM(points) AS total_points
FROM cte
GROUP BY customer_id;





-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, not just sushi - how many points do customer A and B have at the end of January?
WITH cte AS (
SELECT
	s.customer_id,
	s.product_id,
	m.product_name,
    CASE
    	WHEN s.order_date - mem.join_date >= 0 THEN 20 * m.price
        ELSE 10 * m.price
    	END AS points
FROM dannys_diner.sales AS s
LEFT JOIN dannys_diner.members AS mem
	ON s.customer_id = mem.customer_id
LEFT JOIN dannys_diner.menu AS m
	ON s.product_id = m.product_id
ORDER BY s.customer_id
)

SELECT
	customer_id,
    SUM(points)
FROM cte
GROUP BY customer_id;
