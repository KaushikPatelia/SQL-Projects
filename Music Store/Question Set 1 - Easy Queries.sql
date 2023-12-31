/*	Question Set 1 - Easy */

/* Q1: Who is the senior most employee based on job title? */

--Based on level

SELECT CONCAT(TRIM(first_name),' ',TRIM(last_name)) as full_name,title
FROM employee
ORDER BY levels DESC
LIMIT 1;

--Based on age

SELECT CONCAT(TRIM(first_name),' ',TRIM(last_name)) as full_name,title
FROM employee
ORDER BY birthdate ASC
LIMIT 1;


/* Q2: Which countries have the most Invoices? */

SELECT billing_country , COUNT(*) as no_of_invoices
FROM invoice
GROUP BY billing_country
ORDER BY no_of_invoices DESC;


/* Q3: What are top 3 values of total invoice? */

SELECT total as total_invoice
FROM invoice
ORDER BY total_invoice DESC
LIMIT 3;


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city , SUM(total) as invoice_total
FROM invoice
GROUP BY billing_city
ORDER BY invoice_total DESC
LIMIT 1;
--Hence, Prague city had the best customers.


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT CONCAT(TRIM(cust.first_name),' ',TRIM(cust.last_name)) as full_name,SUM(inv.total) as money_spent
FROM customer as cust
JOIN invoice as inv
	ON inv.customer_id = cust.customer_id
GROUP BY full_name
ORDER BY money_spent DESC
LIMIT 1;
