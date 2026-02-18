# Results: 03_aggregations

## Q11: Revenue, customers and average order value by country

```sql
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
```

| country_group   |   customers |   revenue |   revenue_per_customer |   avg_order_value |
|:----------------|------------:|----------:|-----------------------:|------------------:|
| USA             |          13 |    523.06 |                  40.24 |              5.75 |
| Canada          |           8 |    303.96 |                  37.99 |              5.43 |
| France          |           5 |    195.1  |                  39.02 |              5.57 |
| Brazil          |           5 |    190.1  |                  38.02 |              5.43 |
| Germany         |           4 |    156.48 |                  39.12 |              5.59 |
| United Kingdom  |           3 |    112.86 |                  37.62 |              5.37 |
| Czech Republic  |           2 |     90.24 |                  45.12 |              6.45 |
| Portugal        |           2 |     77.24 |                  38.62 |              5.52 |
| India           |           2 |     75.26 |                  37.63 |              5.79 |
| Other           |          15 |    604.3  |                  40.29 |              5.76 |

## Q12: Who are the top 5 customers by total spend?

```sql
SELECT c.FirstName || ' ' || c.LastName AS customer,
       c.Country,
       COUNT(i.InvoiceId)     AS orders,
       ROUND(SUM(i.Total), 2) AS total_spent
FROM Customer c
JOIN Invoice i ON i.CustomerId = c.CustomerId
GROUP BY c.CustomerId, customer, c.Country
ORDER BY total_spent DESC
LIMIT 5;
```

| customer           | Country        |   orders |   total_spent |
|:-------------------|:---------------|---------:|--------------:|
| Helena Holý        | Czech Republic |        7 |         49.62 |
| Richard Cunningham | USA            |        7 |         47.62 |
| Luis Rojas         | Chile          |        7 |         46.62 |
| Ladislav Kovács    | Hungary        |        7 |         45.62 |
| Hugh O'Reilly      | Ireland        |        7 |         45.62 |

## Q13: What does a typical order look like? (tracks per order and order value)

```sql
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
```

|   avg_tracks_per_order |   min_tracks |   max_tracks |   avg_order_value |
|-----------------------:|-------------:|-------------:|------------------:|
|                    5.4 |            1 |           14 |              5.65 |

## Q14: Which genres sell the smallest share of their catalogue? (genres with 20+ tracks)

```sql
SELECT g.Name AS genre,
       COUNT(DISTINCT t.TrackId)  AS tracks_in_catalog,
       COUNT(DISTINCT il.TrackId) AS tracks_ever_sold,
       ROUND(100.0 * COUNT(DISTINCT il.TrackId) / COUNT(DISTINCT t.TrackId), 1) AS pct_sold
FROM Genre g
JOIN Track t ON t.GenreId = g.GenreId
LEFT JOIN InvoiceLine il ON il.TrackId = t.TrackId
GROUP BY g.GenreId, g.Name
HAVING COUNT(DISTINCT t.TrackId) >= 20
ORDER BY pct_sold;
```

| genre              |   tracks_in_catalog |   tracks_ever_sold |   pct_sold |
|:-------------------|--------------------:|-------------------:|-----------:|
| Alternative        |                  40 |                 14 |       35   |
| Electronica/Dance  |                  30 |                 11 |       36.7 |
| Easy Listening     |                  24 |                 10 |       41.7 |
| Drama              |                  64 |                 27 |       42.2 |
| Heavy Metal        |                  28 |                 12 |       42.9 |
| Hip Hop/Rap        |                  35 |                 15 |       42.9 |
| Soundtrack         |                  43 |                 19 |       44.2 |
| TV Shows           |                  93 |                 43 |       46.2 |
| World              |                  28 |                 13 |       46.4 |
| Reggae             |                  58 |                 28 |       48.3 |
| Classical          |                  74 |                 36 |       48.6 |
| Jazz               |                 130 |                 68 |       52.3 |
| Pop                |                  48 |                 26 |       54.2 |
| Rock               |                1297 |                745 |       57.4 |
| Latin              |                 579 |                340 |       58.7 |
| R&B/Soul           |                  61 |                 37 |       60.7 |
| Alternative & Punk |                 332 |                203 |       61.1 |
| Metal              |                 374 |                231 |       61.8 |
| Blues              |                  81 |                 53 |       65.4 |
| Sci Fi & Fantasy   |                  26 |                 20 |       76.9 |

## Q15: Which day of the week gets the most orders?

```sql
SELECT CASE strftime('%w', InvoiceDate)
         WHEN '0' THEN 'Sun' WHEN '1' THEN 'Mon' WHEN '2' THEN 'Tue' WHEN '3' THEN 'Wed'
         WHEN '4' THEN 'Thu' WHEN '5' THEN 'Fri' ELSE 'Sat' END AS weekday,
       COUNT(*)             AS orders,
       ROUND(SUM(Total), 2) AS revenue
FROM Invoice
GROUP BY strftime('%w', InvoiceDate)
ORDER BY strftime('%w', InvoiceDate);
```

| weekday   |   orders |   revenue |
|:----------|---------:|----------:|
| Sun       |       60 |    341.77 |
| Mon       |       59 |    326.82 |
| Tue       |       58 |    321.81 |
| Wed       |       59 |    348.78 |
| Thu       |       59 |    332.89 |
| Fri       |       59 |    326.77 |
| Sat       |       58 |    329.76 |
