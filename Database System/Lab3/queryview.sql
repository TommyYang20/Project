SELECT m.rating , COUNT (*) AS misreportCount 
FROM earningsView e 
JOIN Movies m 
ON e.movieID = m.movieID 
WHERE e.computedEarnings != m.totalEarned
GROUP BY m.rating
HAVING EVERY(m.year < 2019);

-- rating | misreportcount 
----------+----------------
-- P      |              1
-- G      |              2
--(2 rows)




DELETE FROM Tickets
WHERE theaterID = 111
	AND seatNum = 1
	AND showingDate = DATE '2009-06-23'
	AND startTime = Time '11:00:00';

DELETE FROM Tickets
WHERE theaterID = 444
	AND seatNum = 5
	AND showingDate = DATE '2020-06-24'
	AND startTime = Time '15:00:00';
--output after delete
-- rating | misreportcount 
----------+----------------
-- G      |              2
--(1 row)
