/* Question Set 3 - Advance */

/* Q1: Find how much amount spent by each customer on best artist? Write a query to return customer name, artist name and total spent
																										(use invoice_line) */

WITH best_artist AS (SELECT a.artist_id , a.name as artist_name , SUM(invl.unit_price * invl.quantity) as total_spent
					FROM invoice_line as invl
					JOIN track as t
						ON t.track_id = invl.track_id
					JOIN album as alb
						ON alb.album_id = t.album_id
					JOIN artist as a
						ON a.artist_id = alb.artist_id
					GROUP BY a.artist_id,artist_name
					ORDER BY total_spent DESC
					LIMIT 1)						
SELECT cust.customer_id, cust.first_name, cust.last_name, ba.artist_name, SUM(invl.unit_price*invl.quantity) AS amount_spent
FROM invoice as inv
JOIN customer as cust 
	ON cust.customer_id = inv.customer_id
JOIN invoice_line as invl 
	ON invl.invoice_id = inv.invoice_id
JOIN track as t 
	ON t.track_id = invl.track_id
JOIN album as alb 
	ON alb.album_id = t.album_id
JOIN best_artist as ba 
	ON ba.artist_id = alb.artist_id
GROUP BY cust.customer_id, cust.first_name, cust.last_name, ba.artist_name
ORDER BY amount_spent DESC;



/* Q2: We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre 
with the highest amount of purchases. Write a query that returns each country along with the top Genre. For countries where 
the maximum number of purchases is shared return all Genres. */

-- always use row_number when you need to find single highest from every category

WITH popular_genre AS 
(
    SELECT COUNT(invl.quantity) AS purchases, cust.country, g.name, g.genre_id,
	ROW_NUMBER() OVER(PARTITION BY cust.country ORDER BY COUNT(invl.quantity) DESC) AS RowNo 
    FROM invoice_line as invl
	JOIN invoice as inv
		ON inv.invoice_id = invl.invoice_id
	JOIN customer as cust
		ON cust.customer_id = inv.customer_id
	JOIN track as t
		ON t.track_id = invl.track_id
	JOIN genre as g
		ON g.genre_id = t.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * 
FROM popular_genre 
WHERE RowNo <= 1;


/* Q3: Write a query that determines the customer that has spent the most on music for each country. 
Write a query that returns the country along with the top customer and how much they spent. 
For countries where the top amount spent is shared, provide all customers who spent this amount. */

WITH RECURSIVE
	customter_with_country AS (
		SELECT customer.customer_id,customer.first_name,customer.last_name,invoice.billing_country,SUM(invoice.total) AS total_spending
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 2,3 DESC),

	country_max_spending AS(
		SELECT billing_country,MAX(total_spending) AS max_spending
		FROM customter_with_country
		GROUP BY billing_country)

SELECT cc.billing_country, cc.total_spending, cc.first_name, cc.last_name, cc.customer_id
FROM customter_with_country as cc
JOIN country_max_spending as ms
ON cc.billing_country = ms.billing_country
WHERE cc.total_spending = ms.max_spending
ORDER BY 1; 














