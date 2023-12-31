/* Question Set 2 - Moderate */

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

SELECT cust.email,cust.first_name,cust.last_name,g.name as genre_name
FROM customer as cust
JOIN invoice as inv
	ON inv.customer_id = cust.customer_id
JOIN invoice_line as invl
	ON invl.invoice_id = inv.invoice_id
JOIN track as t
	ON t.track_id = invl.track_id
JOIN genre as g
	ON g.genre_id = t.genre_id
WHERE g.name LIKE 'Rock'
GROUP BY cust.email,cust.first_name,cust.last_name,genre_name
ORDER BY cust.email ASC;


/* Q2: Let's invite the artists who have written the most rock music in our dataset. 
Write a query that returns the Artist name and total track count of the top 10 rock bands. */

SELECT a.artist_id,a.name,COUNT(a.artist_id) as total_track_count
FROM artist as a
JOIN album as alb
	ON alb.artist_id = a.artist_id
JOIN track as t
	ON t.album_id = alb.album_id
JOIN genre as g
	ON g.genre_id = t.genre_id
GROUP BY g.name,a.artist_id,a.name
HAVING g.name = 'Rock'
ORDER BY total_track_count DESC
LIMIT 10;


/* Q3: Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first. */


SELECT name,milliseconds as song_length_in_milliseconds
FROM track
WHERE milliseconds > (SELECT AVG(milliseconds)
					 FROM track)
ORDER BY song_length_in_milliseconds DESC;










