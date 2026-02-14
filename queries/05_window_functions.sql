-- 05 window functions

-- Q21: Monthly revenue with a running total
WITH monthly AS (
    SELECT strftime('%Y-%m', InvoiceDate) AS month, SUM(Total) AS revenue
    FROM Invoice
    GROUP BY month
)
SELECT month,
       ROUND(revenue, 2) AS revenue,
       ROUND(SUM(revenue) OVER (ORDER BY month), 2) AS running_total
FROM monthly
ORDER BY month;

-- Q22: Year-over-year change in revenue
WITH yearly AS (
    SELECT strftime('%Y', InvoiceDate) AS year, SUM(Total) AS revenue
    FROM Invoice
    GROUP BY year
)
SELECT year,
       ROUND(revenue, 2) AS revenue,
       ROUND(revenue - LAG(revenue) OVER (ORDER BY year), 2) AS change,
       ROUND(100.0 * (revenue - LAG(revenue) OVER (ORDER BY year))
             / LAG(revenue) OVER (ORDER BY year), 1) AS pct_change
FROM yearly
ORDER BY year;

-- Q23: Top 3 artists in each of the 5 biggest genres (RANK)
WITH artist_genre AS (
    SELECT g.Name AS genre, ar.Name AS artist, SUM(il.UnitPrice * il.Quantity) AS revenue
    FROM InvoiceLine il
    JOIN Track  t  ON t.TrackId   = il.TrackId
    JOIN Genre  g  ON g.GenreId   = t.GenreId
    JOIN Album  al ON al.AlbumId  = t.AlbumId
    JOIN Artist ar ON ar.ArtistId = al.ArtistId
    GROUP BY g.Name, ar.Name
),
ranked AS (
    SELECT genre, artist, revenue,
           RANK() OVER (PARTITION BY genre ORDER BY revenue DESC) AS rank_in_genre,
           SUM(revenue) OVER (PARTITION BY genre) AS genre_revenue
    FROM artist_genre
)
SELECT genre, rank_in_genre, artist, ROUND(revenue, 2) AS revenue
FROM ranked
WHERE rank_in_genre <= 3
  AND genre IN (SELECT genre FROM ranked GROUP BY genre ORDER BY MAX(genre_revenue) DESC LIMIT 5)
ORDER BY genre_revenue DESC, rank_in_genre, artist;

-- Q24: How long do customers wait between orders? (LAG)
WITH orders AS (
    SELECT CustomerId,
           InvoiceDate,
           LAG(InvoiceDate) OVER (PARTITION BY CustomerId ORDER BY InvoiceDate) AS previous_order
    FROM Invoice
)
SELECT ROUND(AVG(julianday(InvoiceDate) - julianday(previous_order)), 0) AS avg_days_between_orders,
       MIN(julianday(InvoiceDate) - julianday(previous_order))           AS min_days,
       MAX(julianday(InvoiceDate) - julianday(previous_order))           AS max_days
FROM orders
WHERE previous_order IS NOT NULL;

-- Q25: Each country's share of total revenue (SUM over the whole table)
SELECT BillingCountry AS country,
       ROUND(SUM(Total), 2) AS revenue,
       ROUND(100.0 * SUM(Total) / SUM(SUM(Total)) OVER (), 1) AS pct_of_total
FROM Invoice
GROUP BY BillingCountry
ORDER BY revenue DESC
LIMIT 10;
