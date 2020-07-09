--Find the name and year of all movies for which a customer named Donald Duck 
--No duplicate
SELECT DISTINCT Movies.name AS name, Movies.year AS year
From Movies, Customers, Showings, Tickets
WHERE Customers.name = 'Donald Duck'
AND Customers.customerID = Tickets.customerID
AND Tickets.theaterID = Showings.theaterID
AND Movies.movieID = Showings.movieID
AND Showings.showingDate =Tickets.showingDate
AND Showings.startTime = Tickets.startTime