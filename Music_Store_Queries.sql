-- 									Question Set 1 - Easy

/* Q1: Who is the senior most employee based on job title? */

SELECT title, last_name, first_name 
FROM employee
ORDER BY levels DESC
LIMIT 1


/* Q2: Which countries have the most Invoices? */

SELECT COUNT(*) AS c, billing_country 
FROM invoice
GROUP BY billing_country
ORDER BY c DESC


/* Q3: What are top 3 values of total invoice? */

SELECT total 
FROM invoice
ORDER BY total DESC


/* Q4: Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
Write a query that returns one city that has the highest sum of invoice totals. 
Return both the city name & sum of all invoice totals */

SELECT billing_city,SUM(total) AS InvoiceTotal
FROM invoice
GROUP BY billing_city
ORDER BY InvoiceTotal DESC
LIMIT 1;


/* Q5: Who is the best customer? The customer who has spent the most money will be declared the best customer. 
Write a query that returns the person who has spent the most money.*/

SELECT customer.customer_id, first_name, last_name, SUM(total) AS total_spending
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
GROUP BY customer.customer_id
ORDER BY total_spending DESC
LIMIT 1;




--									 Question Set 2 - Moderate 

/* Q1: Write query to return the email, first name, last name, & Genre of all Rock Music listeners. 
Return your list ordered alphabetically by email starting with A. */

/*Method 1 */

SELECT DISTINCT email,first_name, last_name
FROM customer
JOIN invoice ON customer.customer_id = invoice.customer_id
JOIN invoiceline ON invoice.invoice_id = invoiceline.invoice_id
WHERE track_id IN(
	SELECT track_id FROM track
	JOIN genre ON track.genre_id = genre.genre_id
	WHERE genre.name LIKE 'Rock'
)
ORDER BY email;


/* Method 2 */

SELECT DISTINCT email AS Email,first_name AS FirstName, last_name AS LastName, genre.name AS Name
FROM customer
JOIN invoice ON invoice.customer_id = customer.customer_id
JOIN invoiceline ON invoiceline.invoice_id = invoice.invoice_id
JOIN track ON track.track_id = invoiceline.track_id
JOIN genre ON genre.genre_id = track.genre_id
WHERE genre.name LIKE 'Rock'
ORDER BY email;/*2. Let's invite the artists who have written the most rock music in our dataset. Write a 
query that returns the Artist name and total track count of the top 10 rock band.
*/
SELECT artist.name, count(*) No_of_tracks  FROM artist
JOIN album ON album.artist_id = artist.artist_id
JOIN track ON track.album_id = album.album_id
where track.genre_id IN (select track.genre_id from track join genre on genre.genre_id = track.genre_id where genre.name = 'Rock')
GROUP BY artist.name
Order by no_of_tracks desc
LIMIT 10;

/* 3. Return all the track names that have a song length longer than the average song length. 
Return the Name and Milliseconds for each track. Order by the song length with the 
longest songs listed first
*/
SELECT track_id, name, milliseconds 
FROM Track
WHERE Milliseconds > (SELECT avg(milliseconds) from track)
ORDER BY milliseconds DESC;


 --  									Question Set 3 – Advance
 
 /* 1. Find how much amount spent by each customer on artists? Write a query to return
customer name, artist name and total spent
*/
SELECT * FROM customer;
SELECT * FROM Artist;

WITH best_selling_artist AS(
SELECT a.artist_id, a.name, SUM(il.unit_price*il.quantity) sale_amount 
FROM artist a
JOIN album al ON al.artist_id = a.artist_id 
JOIN track t ON t.album_id = al.album_id
JOIN invoice_line il ON il.track_id = t.track_id
GROUP BY 1,2
ORDER BY sale_amount desc
LIMIT 1
)
SELECT c.customer_id, c.first_name, c.last_name, bsa.name, SUM(il.unit_price * il.quantity) AS amount_spend
FROM customer c
JOIN Invoice i ON i.customer_id = c.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN TRACk t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 desc ;





/*  2. We want to find out the most popular music Genre for each country. We determine the 
most popular genre as the genre with the highest amount of purchases. Write a query 
that returns each country along with the top Genre. For countries where the maximum 
number of purchases is shared return all Genres
*/
WITH popular_genre AS(
SELECT i.billing_country,g.name, count(*) as purchases,
ROW_NUMBER() OVER (PARTITION BY i.billing_country ORDER BY count(*) DESC) AS RowNo
FROM invoice_line il
JOIN track t ON t.track_id = il.track_id
JOIN genre g on g.genre_id = t.genre_id
JOIN invoice i ON i.invoice_id = il.invoice_id

GROUP BY 1,2
ORDER BY 1 ASC,3 DESC
)

SELECT * FROM popular_genre where rowno <=1 ;



/* 3. Write a query that determines the customer that has spent the most on music for each 
country. Write a query that returns the country along with the top customer and how
much they spent. For countries where the top amount spent is shared, provide all 
customers who spent this amount
*/

WITH customer_with_country AS(
SELECT c.customer_id, C.first_name , c.last_name , c.country, Sum(unit_price * quantity) money_spent,
row_number() OVER (PARTITION BY c.country ORDER BY Sum(unit_price * quantity) DESC) as row_no
FROM invoice_line il
JOIN invoice i ON i.invoice_id = il.invoice_id
JOIN customer c ON c.customer_id = i.customer_id
GROUP BY 1, 2 , 3,4 
ORDER BY 4 ASC, 5 DESC)
SELECT * FROM customer_with_country WHERE row_no <=1;


SELECT C.customer_id, sum(i.total)
FROM customer c
JOIN invoice i
ON i.customer_id = c.customer_id
Group by 1
order by 1






