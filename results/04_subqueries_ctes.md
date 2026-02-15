# Results: 04_subqueries_ctes

## Q16: How many customers spent more than the average customer?

```sql
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
```

|   customers_above_avg |   all_customers |   avg_spend |
|----------------------:|----------------:|------------:|
|                    22 |              59 |       39.47 |

## Q17: What is the most popular genre in each country? (by units bought)

```sql
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
```

| Country        | genre              |   units |
|:---------------|:-------------------|--------:|
| USA            | Rock               |     157 |
| Canada         | Rock               |     107 |
| Brazil         | Rock               |      81 |
| France         | Rock               |      65 |
| Germany        | Rock               |      62 |
| United Kingdom | Rock               |      37 |
| Portugal       | Rock               |      31 |
| Czech Republic | Rock               |      25 |
| India          | Rock               |      25 |
| Australia      | Rock               |      22 |
| Poland         | Rock               |      22 |
| Spain          | Rock               |      22 |
| Belgium        | Rock               |      21 |
| Denmark        | Rock               |      21 |
| Finland        | Rock               |      18 |
| Italy          | Rock               |      18 |
| Netherlands    | Rock               |      18 |
| Norway         | Rock               |      17 |
| Austria        | Rock               |      15 |
| Ireland        | Rock               |      12 |
| Sweden         | Latin              |      12 |
| Hungary        | Rock               |      11 |
| Argentina      | Alternative & Punk |       9 |
| Argentina      | Rock               |       9 |
| Chile          | Rock               |       9 |

## Q18: Who is the top spending customer in each country?

```sql
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
```

| Country        | customer              |   total_spent |
|:---------------|:----------------------|--------------:|
| Czech Republic | Helena Holý           |         49.62 |
| USA            | Richard Cunningham    |         47.62 |
| Chile          | Luis Rojas            |         46.62 |
| Hungary        | Ladislav Kovács       |         45.62 |
| Ireland        | Hugh O'Reilly         |         45.62 |
| Germany        | Fynn Zimmermann       |         43.62 |
| Austria        | Astrid Gruber         |         42.62 |
| Finland        | Terhi Hämäläinen      |         41.62 |
| France         | Isabelle Mercier      |         40.62 |
| Netherlands    | Johannes Van der Berg |         40.62 |
| Brazil         | Luís Gonçalves        |         39.62 |
| Canada         | François Tremblay     |         39.62 |
| Norway         | Bjørn Hansen          |         39.62 |
| Portugal       | João Fernandes        |         39.62 |
| Sweden         | Joakim Johansson      |         38.62 |
| India          | Manoj Pareek          |         38.62 |
| Belgium        | Daan Peeters          |         37.62 |
| Denmark        | Kara Nielsen          |         37.62 |
| Italy          | Lucas Mancini         |         37.62 |
| Poland         | Stanisław Wójcik      |         37.62 |
| Spain          | Enrique Muñoz         |         37.62 |
| United Kingdom | Emma Jones            |         37.62 |
| United Kingdom | Phil Hughes           |         37.62 |
| United Kingdom | Steve Murray          |         37.62 |
| Australia      | Mark Taylor           |         37.62 |
| Argentina      | Diego Gutiérrez       |         37.62 |

## Q19: How much of the catalogue has never been sold?

```sql
SELECT COUNT(*) AS tracks,
       SUM(CASE WHEN TrackId NOT IN (SELECT TrackId FROM InvoiceLine) THEN 1 ELSE 0 END) AS never_sold,
       ROUND(100.0 * SUM(CASE WHEN TrackId NOT IN (SELECT TrackId FROM InvoiceLine) THEN 1 ELSE 0 END)
             / COUNT(*), 1) AS pct_never_sold
FROM Track;
```

|   tracks |   never_sold |   pct_never_sold |
|---------:|-------------:|-----------------:|
|     3503 |         1519 |             43.4 |

## Q20: Do people buy whole albums or single tracks?

```sql
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
```

| order_type        |   orders |   pct_of_orders |
|:------------------|---------:|----------------:|
| full album        |        2 |             0.5 |
| individual tracks |      410 |            99.5 |
