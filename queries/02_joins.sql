-- 02 joins: combining tables

-- Q6: Which 10 albums sold the most tracks?
SELECT al.Title          AS album,
       ar.Name           AS artist,
       SUM(il.Quantity)  AS tracks_sold
FROM InvoiceLine il
JOIN Track  t  ON t.TrackId   = il.TrackId
JOIN Album  al ON al.AlbumId  = t.AlbumId
JOIN Artist ar ON ar.ArtistId = al.ArtistId
GROUP BY al.AlbumId, al.Title, ar.Name
ORDER BY tracks_sold DESC, album
LIMIT 10;

-- Q7: Which 10 artists earned the most?
SELECT ar.Name                                 AS artist,
       ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue
FROM InvoiceLine il
JOIN Track  t  ON t.TrackId  = il.TrackId
JOIN Album  al ON al.AlbumId = t.AlbumId
JOIN Artist ar ON ar.ArtistId = al.ArtistId
GROUP BY ar.ArtistId, ar.Name
ORDER BY revenue DESC
LIMIT 10;

-- Q8: Revenue by genre, with each genre's share of the total
SELECT g.Name AS genre,
       ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue,
       ROUND(100.0 * SUM(il.UnitPrice * il.Quantity) /
             (SELECT SUM(UnitPrice * Quantity) FROM InvoiceLine), 1) AS pct_of_revenue
FROM InvoiceLine il
JOIN Track t ON t.TrackId = il.TrackId
JOIN Genre g ON g.GenreId = t.GenreId
GROUP BY g.GenreId, g.Name
ORDER BY revenue DESC;

-- Q9: Which media types sell?
SELECT mt.Name AS media_type,
       COUNT(*) AS lines_sold,
       ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue
FROM InvoiceLine il
JOIN Track t      ON t.TrackId = il.TrackId
JOIN MediaType mt ON mt.MediaTypeId = t.MediaTypeId
GROUP BY mt.MediaTypeId, mt.Name
ORDER BY revenue DESC;

-- Q10: Which sales support agent's customers spent the most?
SELECT e.FirstName || ' ' || e.LastName AS agent,
       COUNT(DISTINCT c.CustomerId)     AS customers,
       ROUND(SUM(i.Total), 2)           AS revenue
FROM Employee e
JOIN Customer c ON c.SupportRepId = e.EmployeeId
JOIN Invoice  i ON i.CustomerId   = c.CustomerId
GROUP BY e.EmployeeId, agent
ORDER BY revenue DESC;
