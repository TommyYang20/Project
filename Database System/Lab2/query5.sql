--the ticket was bought by a customer whose name starts with ‘D’ (capital D)
--the ticket is for a showing whose price code isn't NULL, and
--the ticket is on a date between June 1, 2019 and June 30, 2019 (including those dates), and
--the ticket is for a theater that has more than 5 seats

SELECT Customers.customerID AS custID, Customers.name AS custName, Customers.address AS custAddress, Theaters.address AS theaterAddress, Theaters.numSeats AS theaterSeats, Showings.priceCode AS priceCode
From Tickets, Customers, Theaters, Showings
WHERE Tickets.customerID = Customers.customerID
AND Customers.name LIKE 'D%'
AND Tickets.theaterID = Showings.theaterID
AND Showings.showingDate = Tickets.showingDate
AND Showings.startTime = Tickets.startTime
AND Showings.priceCode IS NOT NULL
AND Showings.showingDate BETWEEN '2019-06-01' AND '2019-06-30'
AND Tickets.theaterID = Theaters.theaterID
AND Theaters.numSeats > 5;