-- 03 aggregations: GROUP BY, HAVING, averages

-- Q11: Revenue, customers and average order value by country
-- (countries with only one customer are grouped as 'Other')
WITH country_stats AS (
    SELECT c.Country,
           COUNT(DISTINCT c.CustomerId) AS customers,
           COUNT(i.InvoiceId)           AS orders,
           SUM(i.Total)                 AS revenue
    FROM Customer c
    JOIN Invoice i ON i.CustomerId = c.CustomerId
    GROUP BY c.Country
)
SELECT CASE WHEN customers = 1 THEN 'Other' ELSE Country END AS country_group,
       SUM(customers)                       AS customers,
       ROUND(SUM(revenue), 2)               AS revenue,
       ROUND(SUM(revenue) / SUM(customers), 2) AS revenue_per_customer,
       ROUND(SUM(revenue) / SUM(orders), 2)    AS avg_order_value
FROM country_stats
GROUP BY 1
ORDER BY CASE WHEN country_group = 'Other' THEN 1 ELSE 0 END, revenue DESC;

-- Q12: Who are the top 5 customers by total spend?
SELECT c.FirstName || ' ' || c.LastName AS customer,
       c.Country,
       COUNT(i.InvoiceId)     AS orders,
       ROUND(SUM(i.Total), 2) AS total_spent
FROM Customer c
JOIN Invoice i ON i.CustomerId = c.CustomerId
GROUP BY c.CustomerId, customer, c.Country
ORDER BY total_spent DESC
LIMIT 5;

-- Q13: What does a typical order look like? (tracks per order and order value)
SELECT ROUND(AVG(lines), 1)  AS avg_tracks_per_order,
       MIN(lines)            AS min_tracks,
       MAX(lines)            AS max_tracks,
       ROUND(AVG(Total), 2)  AS avg_order_value
FROM (
    SELECT i.InvoiceId, i.Total, COUNT(il.InvoiceLineId) AS lines
    FROM Invoice i
    JOIN InvoiceLine il ON il.InvoiceId = i.InvoiceId
    GROUP BY i.InvoiceId, i.Total
) per_order;

-- Q14: Which genres have more than 100 tracks but sold fewer than 50?
SELECT g.Name AS genre,
       COUNT(DISTINCT t.TrackId)          AS tracks_in_catalog,
       COALESCE(SUM(il.Quantity), 0)      AS units_sold
FROM Genre g
JOIN Track t ON t.GenreId = g.GenreId
LEFT JOIN InvoiceLine il ON il.TrackId = t.TrackId
GROUP BY g.GenreId, g.Name
HAVING COUNT(DISTINCT t.TrackId) > 100 AND COALESCE(SUM(il.Quantity), 0) < 50
ORDER BY tracks_in_catalog DESC;

-- Q15: Which day of the week gets the most orders?
SELECT CASE strftime('%w', InvoiceDate)
         WHEN '0' THEN 'Sun' WHEN '1' THEN 'Mon' WHEN '2' THEN 'Tue' WHEN '3' THEN 'Wed'
         WHEN '4' THEN 'Thu' WHEN '5' THEN 'Fri' ELSE 'Sat' END AS weekday,
       COUNT(*)             AS orders,
       ROUND(SUM(Total), 2) AS revenue
FROM Invoice
GROUP BY strftime('%w', InvoiceDate)
ORDER BY strftime('%w', InvoiceDate);
