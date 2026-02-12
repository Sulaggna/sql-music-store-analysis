-- 04 subqueries and CTEs

-- Q16: How many customers spent more than the average customer?
WITH spend AS (
    SELECT CustomerId, SUM(Total) AS total_spent
    FROM Invoice
    GROUP BY CustomerId
)
SELECT COUNT(*)                                   AS customers_above_avg,
       (SELECT COUNT(*) FROM spend)               AS all_customers,
       ROUND((SELECT AVG(total_spent) FROM spend), 2) AS avg_spend
FROM spend
WHERE total_spent > (SELECT AVG(total_spent) FROM spend);

-- Q17: What is the most popular genre in each country? (by units bought)
WITH genre_country AS (
    SELECT c.Country, g.Name AS genre, SUM(il.Quantity) AS units
    FROM InvoiceLine il
    JOIN Invoice  i ON i.InvoiceId  = il.InvoiceId
    JOIN Customer c ON c.CustomerId = i.CustomerId
    JOIN Track    t ON t.TrackId    = il.TrackId
    JOIN Genre    g ON g.GenreId    = t.GenreId
    GROUP BY c.Country, g.Name
)
SELECT gc.Country, gc.genre, gc.units
FROM genre_country gc
WHERE gc.units = (SELECT MAX(units) FROM genre_country x WHERE x.Country = gc.Country)
ORDER BY gc.units DESC, gc.Country;

-- Q18: Who is the top spending customer in each country?
WITH spend AS (
    SELECT c.Country, c.FirstName || ' ' || c.LastName AS customer, SUM(i.Total) AS total_spent
    FROM Customer c
    JOIN Invoice i ON i.CustomerId = c.CustomerId
    GROUP BY c.CustomerId, c.Country, customer
)
SELECT s.Country, s.customer, ROUND(s.total_spent, 2) AS total_spent
FROM spend s
WHERE s.total_spent = (SELECT MAX(total_spent) FROM spend x WHERE x.Country = s.Country)
ORDER BY total_spent DESC;

-- Q19: How much of the catalogue has never been sold?
SELECT COUNT(*) AS tracks,
       SUM(CASE WHEN TrackId NOT IN (SELECT TrackId FROM InvoiceLine) THEN 1 ELSE 0 END) AS never_sold,
       ROUND(100.0 * SUM(CASE WHEN TrackId NOT IN (SELECT TrackId FROM InvoiceLine) THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS pct_never_sold
FROM Track;

-- Q20: Do people buy whole albums or single tracks?
-- An order counts as a "full album" if it has every track of one album and nothing else.
WITH order_album AS (
    SELECT il.InvoiceId,
           MIN(t.AlbumId) AS album_id,
           COUNT(DISTINCT t.AlbumId) AS albums_in_order,
           COUNT(*) AS tracks_in_order
    FROM InvoiceLine il
    JOIN Track t ON t.TrackId = il.TrackId
    GROUP BY il.InvoiceId
),
album_size AS (
    SELECT AlbumId, COUNT(*) AS album_tracks FROM Track GROUP BY AlbumId
)
SELECT CASE WHEN oa.albums_in_order = 1 AND oa.tracks_in_order = a.album_tracks
            THEN 'full album' ELSE 'individual tracks' END AS order_type,
       COUNT(*) AS orders,
       ROUND(100.0 * COUNT(*) / (SELECT COUNT(*) FROM Invoice), 1) AS pct_of_orders
FROM order_album oa
JOIN album_size a ON a.AlbumId = oa.album_id
GROUP BY order_type;
