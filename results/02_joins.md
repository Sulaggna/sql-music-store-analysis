# Results: 02_joins

## Q6: Which 10 albums sold the most tracks?

```sql
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
```

| album                                    | artist                         |   tracks_sold |
|:-----------------------------------------|:-------------------------------|--------------:|
| Minha Historia                           | Chico Buarque                  |            27 |
| Greatest Hits                            | Lenny Kravitz                  |            26 |
| Unplugged                                | Eric Clapton                   |            25 |
| Acústico                                 | Titãs                          |            22 |
| Greatest Kiss                            | Kiss                           |            20 |
| Chronicle, Vol. 2                        | Creedence Clearwater Revival   |            19 |
| My Generation - The Very Best Of The Who | The Who                        |            19 |
| Prenda Minha                             | Caetano Veloso                 |            19 |
| Acústico MTV                             | Os Paralamas Do Sucesso        |            18 |
| Battlestar Galactica (Classic), Season 1 | Battlestar Galactica (Classic) |            18 |

## Q7: Which 10 artists earned the most?

```sql
SELECT ar.Name                                 AS artist,
       ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue
FROM InvoiceLine il
JOIN Track  t  ON t.TrackId  = il.TrackId
JOIN Album  al ON al.AlbumId = t.AlbumId
JOIN Artist ar ON ar.ArtistId = al.ArtistId
GROUP BY ar.ArtistId, ar.Name
ORDER BY revenue DESC
LIMIT 10;
```

| artist                  |   revenue |
|:------------------------|----------:|
| Iron Maiden             |    138.6  |
| U2                      |    105.93 |
| Metallica               |     90.09 |
| Led Zeppelin            |     86.13 |
| Lost                    |     81.59 |
| The Office              |     49.75 |
| Os Paralamas Do Sucesso |     44.55 |
| Deep Purple             |     43.56 |
| Faith No More           |     41.58 |
| Eric Clapton            |     39.6  |

## Q8: Revenue by genre, with each genre's share of the total

```sql
SELECT g.Name AS genre,
       ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue,
       ROUND(100.0 * SUM(il.UnitPrice * il.Quantity) /
             (SELECT SUM(UnitPrice * Quantity) FROM InvoiceLine), 1) AS pct_of_revenue
FROM InvoiceLine il
JOIN Track t ON t.TrackId = il.TrackId
JOIN Genre g ON g.GenreId = t.GenreId
GROUP BY g.GenreId, g.Name
ORDER BY revenue DESC;
```

| genre              |   revenue |   pct_of_revenue |
|:-------------------|----------:|-----------------:|
| Rock               |    826.65 |             35.5 |
| Latin              |    382.14 |             16.4 |
| Metal              |    261.36 |             11.2 |
| Alternative & Punk |    241.56 |             10.4 |
| TV Shows           |     93.53 |              4   |
| Jazz               |     79.2  |              3.4 |
| Blues              |     60.39 |              2.6 |
| Drama              |     57.71 |              2.5 |
| R&B/Soul           |     40.59 |              1.7 |
| Classical          |     40.59 |              1.7 |
| Sci Fi & Fantasy   |     39.8  |              1.7 |
| Reggae             |     29.7  |              1.3 |
| Pop                |     27.72 |              1.2 |
| Soundtrack         |     19.8  |              0.9 |
| Comedy             |     17.91 |              0.8 |
| Hip Hop/Rap        |     16.83 |              0.7 |
| Bossa Nova         |     14.85 |              0.6 |
| Alternative        |     13.86 |              0.6 |
| World              |     12.87 |              0.6 |
| Science Fiction    |     11.94 |              0.5 |
| Heavy Metal        |     11.88 |              0.5 |
| Electronica/Dance  |     11.88 |              0.5 |
| Easy Listening     |      9.9  |              0.4 |
| Rock And Roll      |      5.94 |              0.3 |

## Q9: Which media types sell?

```sql
SELECT mt.Name AS media_type,
       COUNT(*) AS lines_sold,
       ROUND(SUM(il.UnitPrice * il.Quantity), 2) AS revenue
FROM InvoiceLine il
JOIN Track t      ON t.TrackId = il.TrackId
JOIN MediaType mt ON mt.MediaTypeId = t.MediaTypeId
GROUP BY mt.MediaTypeId, mt.Name
ORDER BY revenue DESC;
```

| media_type                  |   lines_sold |   revenue |
|:----------------------------|-------------:|----------:|
| MPEG audio file             |         1976 |   1956.24 |
| Protected MPEG-4 video file |          111 |    220.89 |
| Protected AAC audio file    |          146 |    144.54 |
| Purchased AAC audio file    |            4 |      3.96 |
| AAC audio file              |            3 |      2.97 |

## Q10: Which sales support agent's customers spent the most?

```sql
SELECT e.FirstName || ' ' || e.LastName AS agent,
       COUNT(DISTINCT c.CustomerId)     AS customers,
       ROUND(SUM(i.Total), 2)           AS revenue
FROM Employee e
JOIN Customer c ON c.SupportRepId = e.EmployeeId
JOIN Invoice  i ON i.CustomerId   = c.CustomerId
GROUP BY e.EmployeeId, agent
ORDER BY revenue DESC;
```

| agent         |   customers |   revenue |
|:--------------|------------:|----------:|
| Jane Peacock  |          21 |    833.04 |
| Margaret Park |          20 |    775.4  |
| Steve Johnson |          18 |    720.16 |
