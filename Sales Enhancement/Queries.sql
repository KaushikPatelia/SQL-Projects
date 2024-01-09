drop table if exists goldusers_signup;
CREATE TABLE goldusers_signup(user_id integer,gold_signup_date date); 

INSERT INTO goldusers_signup(user_id,gold_signup_date) 
 VALUES (1,'22-09-2017'),
(3,'21-04-2017');

select * from goldusers_signup;

drop table if exists users;
CREATE TABLE users(user_id integer,signup_date date); 

INSERT INTO users(user_id,signup_date) 
 VALUES (1,'02-09-2014'),
(2,'15-01-2015'),
(3,'11-04-2014');

select * from users;

drop table if exists sales;
CREATE TABLE sales(user_id integer,created_date date,product_id integer); 

INSERT INTO sales(user_id,created_date,product_id) 
 VALUES (1, '19-04-2017', 2),
(3,'18-12-2019', 1),
(2,'20-07-2020', 3),
(1,'23-10-2019', 2),
(1,'19-03-2018', 3),
(3,'20-12-2016', 2),
(1,'09-11-2016', 1),
(1,'20-05-2016', 3),
(2,'24-09-2017', 1),
(1,'11-03-2017', 2),
(1,'11-03-2016', 1),
(3,'10-11-2016', 1),
(3,'07-12-2017', 2),
(3,'15-12-2016', 2),
(2,'08-11-2017', 2),
(2,'10-09-2018', 3);

select * from sales;

drop table if exists product;
CREATE TABLE product(product_id integer,product_name text,price integer); 

INSERT INTO product(product_id,product_name,price) 
 VALUES
(1,'p1',980),
(2,'p2',870),
(3,'p3',330);

select * from product;



--> Q1. What is the total amount each customer spent? Arrange in descending order of amount spent.

SELECT s.user_id ,SUM(p.price) as amount_spent
FROM sales AS s
INNER JOIN product AS p
	ON p.product_id = s.product_id
GROUP BY s.user_id
ORDER BY amount_spent DESC;


--> Q2. How many days each customer visited the app?

SELECT user_id ,COUNT(DISTINCT created_date) as no_days_visited
FROM sales
GROUP BY user_id
ORDER BY no_days_visited DESC;


--> Q3. What was the first product purchased by each customer?

SELECT * FROM(
		SELECT user_id,product_id,created_date,RANK()OVER(PARTITION BY user_id ORDER BY created_date) as rnk
		FROM sales) as ranked
WHERE rnk = 1;

--> Q4. What is the most purchased item and how many times it was purchased by all customers? 

SELECT user_id,COUNT(product_id)as times_purchased_by_each_customer
FROM sales 
WHERE product_id = ( 
					SELECT product_id
					FROM sales
					GROUP BY product_id
					ORDER BY COUNT(product_id) DESC
					LIMIT 1)
GROUP BY user_id;


--> Q5. Which product was the most popular for each customer?

SELECT user_id,product_id,popular_count FROM (
SELECT *,RANK()OVER(PARTITION BY user_id ORDER BY popular_count DESC) as r 
FROM (
		SELECT user_id,product_id,COUNT(product_id) as popular_count
		FROM sales
		GROUP BY user_id,product_id
		ORDER BY user_id,popular_count DESC
	) as a ) as b
WHERE r=1;


--> Q6. Which product was first purchased by the customer after they became a member?

SELECT user_id,product_id,gold_signup_date
FROM(SELECT *,RANK()OVER(PARTITION BY a.user_id ORDER BY a.created_date) as r
	 FROM (SELECT s.user_id,s.created_date,s.product_id,g.gold_signup_date
	  		FROM sales as s
	  		INNER JOIN goldusers_signup as g
				ON s.user_id = g.user_id
	  		WHERE s.created_date >= g.gold_signup_date) as a
	 ) as b
WHERE r=1;


--> Q7. Which item was purchased just before the customer became the member?

SELECT user_id,product_id,gold_signup_date
FROM(SELECT *,RANK()OVER(PARTITION BY a.user_id ORDER BY a.created_date DESC) as r
	 FROM (SELECT s.user_id,s.created_date,s.product_id,g.gold_signup_date
	  		FROM sales as s
	  		INNER JOIN goldusers_signup as g
				ON s.user_id = g.user_id
	  		WHERE s.created_date < g.gold_signup_date) as a
	 ) as b
WHERE r=1;


--> Q8. What is the total orders and amount spent for each member before they became a member?

SELECT a.user_id,COUNT(a.product_id) as num_orders,SUM(p.price) as amount
FROM(SELECT s.user_id,s.created_date,s.product_id,g.gold_signup_date
FROM sales as s
INNER JOIN goldusers_signup as g
	ON s.user_id = g.user_id
WHERE s.created_date < g.gold_signup_date) as a
INNER JOIN product as p
	ON a.product_id = p.product_id
GROUP BY a.user_id
ORDER BY amount DESC;


--> Q9. Every product purchase generate points. p1->5rs=1pt, p2->10rs=5pt, p3->5rs=1pt.
		--Calculate Points collected by each customer & for which products most pts have been given till now?

SELECT user_id,SUM(points) as points_earned
FROM(SELECT *,
		CASE WHEN product_id =1 THEN amount_spent/5
			 WHEN product_id =2 THEN amount_spent/2
			 WHEN product_id =3 THEN amount_spent/5
			 END as points
	FROM(SELECT s.user_id,s.product_id,SUM(p.price) as amount_spent
		FROM sales as s
		INNER JOIN product as p
			ON s.product_id = p.product_id
		GROUP BY s.user_id,s.product_id) as a
	 )as b
GROUP BY user_id
ORDER BY points_earned DESC;

--For products
SELECT product_id,SUM(points) as points_given
FROM(SELECT *,
		CASE WHEN product_id =1 THEN amount_spent/5
			 WHEN product_id =2 THEN amount_spent/2
			 WHEN product_id =3 THEN amount_spent/5
			 END as points
	FROM(SELECT s.user_id,s.product_id,SUM(p.price) as amount_spent
		FROM sales as s
		INNER JOIN product as p
			ON s.product_id = p.product_id
		GROUP BY s.user_id,s.product_id) as a
	 )as b
GROUP BY product_id
ORDER BY points_given DESC;


--> Q10. In the first year after a customer joins gold program (including their joing date) irrescpective of what the 
--       customer has purchased they earn 5 zomato points for every 10rs spent.
--       Who earned more 1 or 3 and what was their points earnings in the first year?

SELECT g.user_id,g.gold_signup_date,u.created_date,(u.price/2) as points_earned
FROM goldusers_signup as g
INNER JOIN (SELECT * 
			FROM sales as s
			INNER JOIN product as p
				ON s.product_id = p.product_id)as u
	ON g.user_id = u.user_id AND u.created_date>=g.gold_signup_date
WHERE u.created_date <= g.gold_signup_date + 365;  --OR  g.gold_signup_date + INTERVAL '1 year'


--> Q11. Rank all the transactions of the customers.

SELECT *,RANK()OVER(PARTITION BY user_id ORDER BY created_date)as rank
FROM sales;

--> Q12. Rank all the transactions of gold plan members & for non-gold plan members rank as '0'

SELECT s.user_id,s.created_date,s.product_id,g.gold_signup_date,
	CASE WHEN g.gold_signup_date IS NULL THEN '0'
		ELSE RANK()OVER(PARTITION BY s.user_id ORDER BY s.created_date DESC)
		END as rank
FROM sales as s
LEFT JOIN goldusers_signup as g
	ON s.user_id = g.user_id AND s.created_date >= g.gold_signup_date








