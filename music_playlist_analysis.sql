use music_playlist;

-- who is the senior most employee based on job title

select * from employee;

select employee_id, last_name, first_name 
from employee
order by levels desc 
limit 1;

-- which countries have most invoices

select * from invoice;

select billing_country, count(invoice_id) as mi
from invoice
group by billing_country
order by mi desc;

-- what are the top 3 values of total invoices

select total from invoice 
order by total desc
limit 3;

-- which city has the best customer? we would like to throw a promotional music festival in the city we made the most 
-- money. write a query that returns one city that has the highest sum of invoice totals, return both the city name
-- and sum of all invoice total.

select billing_city, sum(total) as invoice_total
from invoice 
order by invoice_total desc
limit 1;

-- who is the best customer, the customer who has spent the most money will be declared the best customer. write a 
-- query that returns the person who has spent the most money.

select c.customer_id, c.first_name, c.last_name, sum(total) as total_spent
from customer as c
join invoice as i on
c.customer_id = i.customer_id
order by total_spent desc
limit 1;

-- moderate

select email, first_name, last_name from customer c
join invoice i on c.customer_id = i.customer_id
join invoice_line il on i.invoice_id = il.invoice_id
where track_id in (
					select track_id from track t
                    join genre g on t.genre_id = g.genre_id
                    where g.name like 'Rock'
                    )
                    order by email;
                    
select ar.name , ar.artist_id, count(ar.artist_id) as number_of_songs
from track t
join album a on t.album_id = a.album_id
join artist ar on a.artist_id = ar.artist_id
join genre g on t.genre_id = g.genre_id
where g.name like 'Rock'
group by ar.artist_id
order by number_of_songs desc
limit 10;

select name, milliseconds from track
where milliseconds > (select avg(milliseconds) as avg_track_length from track)
order by milliseconds desc;

select * from invoice_line;

with best_selling_artist as (
		select ar.artist_id as artist_id, ar.name as artist_name, sum(il.unti_price * il.quantity) as total_sales
        from invoice_line il
        join track t on il.track_id = t.track_id
        join album a on t.album_id = a.album_id
        join artist ar on a.artist_id = ar.artist_id
        group by ar.artist_id 
        order by total_sales desc
        limit 1
        )
        SELECT c.customer_id, c.first_name, c.last_name, bsa.artist_name, SUM(il.unti_price*il.quantity) AS amount_spent
FROM invoice i
JOIN customer c ON c.customer_id = i.customer_id
JOIN invoice_line il ON il.invoice_id = i.invoice_id
JOIN track t ON t.track_id = il.track_id
JOIN album alb ON alb.album_id = t.album_id
JOIN best_selling_artist bsa ON bsa.artist_id = alb.artist_id
GROUP BY 1,2,3,4
ORDER BY 5 DESC;

WITH popular_genre AS 
(
    SELECT COUNT(invoice_line.quantity) AS purchases, customer.country, genre.name, genre.genre_id, 
	ROW_NUMBER() OVER(PARTITION BY customer.country ORDER BY COUNT(invoice_line.quantity) DESC) AS RowNo 
    FROM invoice_line 
	JOIN invoice ON invoice.invoice_id = invoice_line.invoice_id
	JOIN customer ON customer.customer_id = invoice.customer_id
	JOIN track ON track.track_id = invoice_line.track_id
	JOIN genre ON genre.genre_id = track.genre_id
	GROUP BY 2,3,4
	ORDER BY 2 ASC, 1 DESC
)
SELECT * FROM popular_genre WHERE RowNo <= 1;


WITH Customter_with_country AS (
		SELECT customer.customer_id,first_name,last_name,billing_country,SUM(total) AS total_spending,
	    ROW_NUMBER() OVER(PARTITION BY billing_country ORDER BY SUM(total) DESC) AS RowNo 
		FROM invoice
		JOIN customer ON customer.customer_id = invoice.customer_id
		GROUP BY 1,2,3,4
		ORDER BY 4 ASC,5 DESC)
SELECT * FROM Customter_with_country WHERE RowNo <= 1