-- 01 basics: SELECT, WHERE, ORDER BY, GROUP BY on one table

-- Q1: How big is the store? (customers, invoices, tracks, total revenue)
SELECT
    (SELECT COUNT(*) FROM Customer)            AS customers,
    (SELECT COUNT(*) FROM Invoice)             AS invoices,
    (SELECT COUNT(*) FROM Track)               AS tracks,
    (SELECT ROUND(SUM(Total), 2) FROM Invoice) AS total_revenue;

-- Q2: Which countries do our customers come from?
SELECT Country, COUNT(*) AS customers
FROM Customer
GROUP BY Country
ORDER BY customers DESC, Country;

-- Q3: What are the 10 longest tracks?
SELECT Name, ROUND(Milliseconds / 60000.0, 1) AS minutes
FROM Track
ORDER BY Milliseconds DESC
LIMIT 10;

-- Q4: What prices do tracks have, and how many tracks are at each price?
SELECT UnitPrice, COUNT(*) AS tracks
FROM Track
GROUP BY UnitPrice;

-- Q5: How much revenue did we make each year?
-- (strftime is SQLite; in MySQL use YEAR(InvoiceDate), in PostgreSQL EXTRACT(YEAR FROM ...))
SELECT strftime('%Y', InvoiceDate) AS year,
       COUNT(*)                    AS invoices,
       ROUND(SUM(Total), 2)        AS revenue
FROM Invoice
GROUP BY year
ORDER BY year;
