# Results: 05_window_functions

## Q21: Monthly revenue with a running total

```sql
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
```

| month   |   revenue |   running_total |
|:--------|----------:|----------------:|
| 2009-01 |     35.64 |           35.64 |
| 2009-02 |     37.62 |           73.26 |
| 2009-03 |     37.62 |          110.88 |
| 2009-04 |     37.62 |          148.5  |
| 2009-05 |     37.62 |          186.12 |
| 2009-06 |     37.62 |          223.74 |
| 2009-07 |     37.62 |          261.36 |
| 2009-08 |     37.62 |          298.98 |
| 2009-09 |     37.62 |          336.6  |
| 2009-10 |     37.62 |          374.22 |
| 2009-11 |     37.62 |          411.84 |
| 2009-12 |     37.62 |          449.46 |
| 2010-01 |     52.62 |          502.08 |
| 2010-02 |     46.62 |          548.7  |
| 2010-03 |     44.62 |          593.32 |
| 2010-04 |     37.62 |          630.94 |
| 2010-05 |     37.62 |          668.56 |
| 2010-06 |     37.62 |          706.18 |
| 2010-07 |     37.62 |          743.8  |
| 2010-08 |     37.62 |          781.42 |
| 2010-09 |     36.63 |          818.05 |
| 2010-10 |     37.62 |          855.67 |
| 2010-11 |     37.62 |          893.29 |
| 2010-12 |     37.62 |          930.91 |
| 2011-01 |     37.62 |          968.53 |
| 2011-02 |     37.62 |         1006.15 |
| 2011-03 |     37.62 |         1043.77 |
| 2011-04 |     51.62 |         1095.39 |
| 2011-05 |     42.62 |         1138.01 |
| 2011-06 |     50.62 |         1188.63 |
| 2011-07 |     37.62 |         1226.25 |
| 2011-08 |     37.62 |         1263.87 |
| 2011-09 |     37.62 |         1301.49 |
| 2011-10 |     37.62 |         1339.11 |
| 2011-11 |     23.76 |         1362.87 |
| 2011-12 |     37.62 |         1400.49 |
| 2012-01 |     37.62 |         1438.11 |
| 2012-02 |     37.62 |         1475.73 |
| 2012-03 |     37.62 |         1513.35 |
| 2012-04 |     37.62 |         1550.97 |
| 2012-05 |     37.62 |         1588.59 |
| 2012-06 |     37.62 |         1626.21 |
| 2012-07 |     39.62 |         1665.83 |
| 2012-08 |     47.62 |         1713.45 |
| 2012-09 |     46.71 |         1760.16 |
| 2012-10 |     42.62 |         1802.78 |
| 2012-11 |     37.62 |         1840.4  |
| 2012-12 |     37.62 |         1878.02 |
| 2013-01 |     37.62 |         1915.64 |
| 2013-02 |     27.72 |         1943.36 |
| 2013-03 |     37.62 |         1980.98 |
| 2013-04 |     33.66 |         2014.64 |
| 2013-05 |     37.62 |         2052.26 |
| 2013-06 |     37.62 |         2089.88 |
| 2013-07 |     37.62 |         2127.5  |
| 2013-08 |     37.62 |         2165.12 |
| 2013-09 |     37.62 |         2202.74 |
| 2013-10 |     37.62 |         2240.36 |
| 2013-11 |     49.62 |         2289.98 |
| 2013-12 |     38.62 |         2328.6  |

## Q22: Year-over-year change in revenue

```sql
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
```

|   year |   revenue |   change |   pct_change |
|-------:|----------:|---------:|-------------:|
|   2009 |    449.46 |          |              |
|   2010 |    481.45 |    31.99 |          7.1 |
|   2011 |    469.58 |   -11.87 |         -2.5 |
|   2012 |    477.53 |     7.95 |          1.7 |
|   2013 |    450.58 |   -26.95 |         -5.6 |

## Q23: Top 3 artists in each of the 5 biggest genres (RANK)

```sql
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
```

| genre              |   rank_in_genre | artist                      |   revenue |
|:-------------------|----------------:|:----------------------------|----------:|
| Rock               |               1 | U2                          |     90.09 |
| Rock               |               2 | Led Zeppelin                |     86.13 |
| Rock               |               3 | Iron Maiden                 |     53.46 |
| Latin              |               1 | Os Paralamas Do Sucesso     |     44.55 |
| Latin              |               2 | Chico Buarque               |     26.73 |
| Latin              |               3 | Chico Science & Nação Zumbi |     24.75 |
| Metal              |               1 | Metallica                   |     90.09 |
| Metal              |               2 | Iron Maiden                 |     69.3  |
| Metal              |               3 | Bruce Dickinson             |     11.88 |
| Metal              |               3 | System Of A Down            |     11.88 |
| Alternative & Punk |               1 | Titãs                       |     33.66 |
| Alternative & Punk |               2 | Faith No More               |     32.67 |
| Alternative & Punk |               2 | Green Day                   |     32.67 |
| TV Shows           |               1 | Lost                        |     45.77 |
| TV Shows           |               2 | The Office                  |     31.84 |
| TV Shows           |               3 | Battlestar Galactica        |      7.96 |

## Q24: How long do customers wait between orders? (LAG)

```sql
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
```

|   avg_days_between_orders |   min_days |   max_days |
|--------------------------:|-----------:|-----------:|
|                       235 |         41 |        584 |

## Q25: Each country's share of total revenue (SUM over the whole table)

```sql
SELECT BillingCountry AS country,
       ROUND(SUM(Total), 2) AS revenue,
       ROUND(100.0 * SUM(Total) / SUM(SUM(Total)) OVER (), 1) AS pct_of_total
FROM Invoice
GROUP BY BillingCountry
ORDER BY revenue DESC
LIMIT 10;
```

| country        |   revenue |   pct_of_total |
|:---------------|----------:|---------------:|
| USA            |    523.06 |           22.5 |
| Canada         |    303.96 |           13.1 |
| France         |    195.1  |            8.4 |
| Brazil         |    190.1  |            8.2 |
| Germany        |    156.48 |            6.7 |
| United Kingdom |    112.86 |            4.8 |
| Czech Republic |     90.24 |            3.9 |
| Portugal       |     77.24 |            3.3 |
| India          |     75.26 |            3.2 |
| Chile          |     46.62 |            2   |
