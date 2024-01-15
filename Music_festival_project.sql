--Who is the senior most employee based on job title
select TOP(1) title,first_name,last_name 
from Music_festival_Project..employee$
order by levels desc

--Which countries has the most invoices
select billing_country, COUNT('billing_country') as No_of_Invoices 
from Music_festival_Project..invoice$
Group by billing_country
order by No_of_Invoices desc

--What are the top 3 values of total invoice
select TOP(3) total 
from Music_festival_Project..invoice$
order by total desc 

--Which City has the best customers
select billing_city, ROUND(SUM(total),2) as best_customers 
from Music_festival_Project..invoice$
group by billing_city
order by best_customers desc

--Best customer 
select TOP(1) Music_festival_Project..customer$.customer_id, first_name, last_name, ROUND(SUM(total),2) as most_money_spent
from Music_festival_Project..customer$
JOIN Music_festival_Project..invoice$ ON customer$.customer_id=invoice$.customer_id
Group by first_name,last_name, Music_festival_Project..customer$.customer_id
order by most_money_spent desc

--Rock Music Listeners
select distinct first_name,last_name,email
from Music_festival_Project..customer$
JOIN Music_festival_Project..invoice$ ON Music_festival_Project..invoice$.customer_id=customer$.customer_id
JOIN Music_festival_Project..invoice_line$ ON Music_festival_Project..invoice_line$.invoice_id=invoice$.invoice_id
Where invoice_line$.track_id IN (
Select track_id from Music_festival_Project..track$ 
JOIN Music_festival_Project..genre$ ON genre$.genre_id=track$.genre_id
Where genre$.name LIKE 'Rock'
)
order by email

--Artist with most rock songs
--Let's invite the artists who have written the most rock music in our dataset. 
--Write a query that returns the Artist name and total track count of the top 10 rock bands
select TOP(10) Music_festival_Project..artist$.artist_id, artist$.name, COUNT(artist$.artist_id) as track_count
from Music_festival_Project..track$
JOIN Music_festival_Project..album$ ON album$.album_id=track$.album_id
JOIN Music_festival_Project..artist$ ON artist$.artist_id=album$.artist_id
JOIN Music_festival_Project..genre$ ON genre$.genre_id=track$.genre_id
where genre$.name LIKE 'Rock'
group by Music_festival_Project..artist$.artist_id, artist$.name
order by track_count desc

select * from Music_festival_Project..genre$
select * from Music_festival_Project..artist$
select * from Music_festival_Project..customer$
select * from Music_festival_Project..invoice_line$
select * from Music_festival_Project..track$
--Return all the track names that have a song length longer than the average song length. 
--Return the Name and Milliseconds for each track. 
--Order by the song length with the longest songs listed first
select name, milliseconds 
from Music_festival_Project..track$
where milliseconds > (
select AVG(milliseconds) as average_song_length 
from Music_festival_Project..track$)
order by milliseconds desc


--Find how much amount spent by each customer on artists? 
--Write a query to return customer name, artist name and total spent
WITH best_Selling_artist (artist_id, name, spend_each_artist) 
AS 
(select Music_festival_Project..artist$.artist_id, Music_festival_Project..artist$.name, 
SUM((Music_festival_Project..invoice_line$.unit_price)*(Music_festival_Project..invoice_line$.quantity)) as spend_each_artist
from Music_festival_Project..invoice_line$
JOIN Music_festival_Project..track$ ON invoice_line$.track_id=track$.track_id
JOIN Music_festival_Project..album$ ON track$.album_id=album$.album_id
JOIN Music_festival_Project..artist$ ON album$.artist_id=artist$.artist_id
Group by Music_festival_Project..artist$.artist_id, Music_festival_Project..artist$.name
)
select Music_festival_Project..customer$.customer_id, customer$.first_name,customer$.last_name, Music_festival_Project..artist$.name as artist_name, SUM(Music_festival_Project..invoice_line$.unit_price*Music_festival_Project..invoice_line$.quantity) as spend_each_artist
from Music_festival_Project..invoice$
JOIN Music_festival_Project..customer$ ON customer$.customer_id=Music_festival_Project..invoice$.customer_id
JOIN Music_festival_Project..invoice_line$ ON invoice$.invoice_id=invoice_line$.invoice_id
JOIN Music_festival_Project..track$ ON invoice_line$.track_id=track$.track_id
JOIN Music_festival_Project..album$ ON track$.album_id=album$.album_id
JOIN Music_festival_Project..artist$ ON album$.artist_id=artist$.artist_id
JOIN best_Selling_artist ON artist$.artist_id=album$.artist_id
group by Music_festival_Project..customer$.customer_id, customer$.first_name,customer$.last_name, Music_festival_Project..artist$.name
order by spend_each_artist desc


--We want to find out the most popular music Genre for each country. We determine the most popular genre as the genre with the highest amount of purchases. 
--Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared return all Genres
With popularGenre (country,genre,genre_id,purchases,rownum) as
(select customer$.country, genre$.name , genre$.genre_id , COUNT(a.quantity) as purchases,
ROW_NUMBER() OVER(Partition by country ORDER BY (COUNT(a.quantity))) AS rownum
from Music_festival_Project..invoice_line$ as a
JOIN Music_festival_Project..invoice$ ON a.invoice_id=invoice$.invoice_id
JOIN Music_festival_Project..customer$ ON invoice$.customer_id=customer$.customer_id
JOIN Music_festival_Project..track$ ON track$.track_id=a.track_id
JOIN Music_festival_Project..genre$ ON genre$.genre_id=track$.genre_id 
Group by Music_festival_Project..customer$.country, Music_festival_Project..genre$.name, Music_festival_Project..genre$.genre_id
)
select * from popularGenre
where rownum <=1

--Write a query that determines the customer that has spent the most on music for each country. 
--Write a query that returns the country along with the top customer and how much they spent. 
--For countries where the top amount spent is shared, provide all customers who spent this amount
With mostSpend (first_name, last_name, country,totalspend,unique_spend) as
(select Music_festival_Project..customer$.first_name, Music_festival_Project..customer$.last_name, a.billing_country as c, SUM(a.total) AS totalspend,
ROW_NUMBER() OVER (Partition by billing_country ORDER BY SUM(a.total) desc) as unique_spend
from Music_festival_Project..invoice$ as a
JOIN Music_festival_Project..customer$ ON customer$.customer_id=a.customer_id
Group by Music_festival_Project..customer$.first_name, Music_festival_Project..customer$.last_name, a.billing_country 
)
select * from mostSpend where unique_spend <=1
Order by totalspend desc
