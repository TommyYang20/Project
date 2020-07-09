--Find the ID and name of each customer whose name has the letter ‘a’ or ‘A’ anywhere in it
--and who bought tickets to at least 2 different movies
--a customer who bought 2 or more tickets to the same movie doesn't qualify
--No duplicate

SELECT Customers.customerID AS ID, Customers.name AS name
FROM Customers, Tickets, Showings
WHERE (Customers.name LIKE '%a%' OR Customers.name LIKE '%A%')
AND Customers.customerID = Tickets.customerID
And Showings.theaterID = Tickets.theaterID
AND Showings.showingDate = Tickets.showingDate
AND Showings.startTime = Tickets.startTime
GROUP BY Customers.customerID
HAVING COUNT(DISTINCT Showings.movieID) >= 2

