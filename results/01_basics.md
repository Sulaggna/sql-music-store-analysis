# Results: 01_basics

## Q1: How big is the store? (customers, invoices, tracks, total revenue)

```sql
SELECT
    (SELECT COUNT(*) FROM Customer)            AS customers,
    (SELECT COUNT(*) FROM Invoice)             AS invoices,
    (SELECT COUNT(*) FROM Track)               AS tracks,
    (SELECT ROUND(SUM(Total), 2) FROM Invoice) AS total_revenue;
```

|   customers |   invoices |   tracks |   total_revenue |
|------------:|-----------:|---------:|----------------:|
|          59 |        412 |     3503 |          2328.6 |

## Q2: Which countries do our customers come from?

```sql
SELECT Country, COUNT(*) AS customers
FROM Customer
GROUP BY Country
ORDER BY customers DESC, Country;
```

| Country        |   customers |
|:---------------|------------:|
| USA            |          13 |
| Canada         |           8 |
| Brazil         |           5 |
| France         |           5 |
| Germany        |           4 |
| United Kingdom |           3 |
| Czech Republic |           2 |
| India          |           2 |
| Portugal       |           2 |
| Argentina      |           1 |
| Australia      |           1 |
| Austria        |           1 |
| Belgium        |           1 |
| Chile          |           1 |
| Denmark        |           1 |
| Finland        |           1 |
| Hungary        |           1 |
| Ireland        |           1 |
| Italy          |           1 |
| Netherlands    |           1 |
| Norway         |           1 |
| Poland         |           1 |
| Spain          |           1 |
| Sweden         |           1 |

## Q3: What are the 10 longest tracks?

```sql
SELECT Name, ROUND(Milliseconds / 60000.0, 1) AS minutes
FROM Track
ORDER BY Milliseconds DESC
LIMIT 10;
```

| Name                        |   minutes |
|:----------------------------|----------:|
| Occupation / Precipice      |      88.1 |
| Through a Looking Glass     |      84.8 |
| Greetings from Earth, Pt. 1 |      49.3 |
| The Man With Nine Lives     |      49.3 |
| Battlestar Galactica, Pt. 2 |      49.3 |
| Battlestar Galactica, Pt. 1 |      49.2 |
| Murder On the Rising Star   |      48.9 |
| Battlestar Galactica, Pt. 3 |      48.8 |
| Take the Celestra           |      48.8 |
| Fire In Space               |      48.8 |

## Q4: What prices do tracks have, and how many tracks are at each price?

```sql
SELECT UnitPrice, COUNT(*) AS tracks
FROM Track
GROUP BY UnitPrice;
```

|   UnitPrice |   tracks |
|------------:|---------:|
|        0.99 |     3290 |
|        1.99 |      213 |

## Q5: How much revenue did we make each year?

```sql
-- (strftime is SQLite; in MySQL use YEAR(InvoiceDate), in PostgreSQL EXTRACT(YEAR FROM ...))
SELECT strftime('%Y', InvoiceDate) AS year,
       COUNT(*)                    AS invoices,
       ROUND(SUM(Total), 2)        AS revenue
FROM Invoice
GROUP BY year
ORDER BY year;
```

|   year |   invoices |   revenue |
|-------:|-----------:|----------:|
|   2009 |         83 |    449.46 |
|   2010 |         83 |    481.45 |
|   2011 |         83 |    469.58 |
|   2012 |         83 |    477.53 |
|   2013 |         80 |    450.58 |
