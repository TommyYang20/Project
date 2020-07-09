INSERT INTO Tickets (theaterID, seatNum, showingDate, startTime, customerID, ticketPrice)
	VALUES(111, 3, '2009-06-23', '09:00:00', 225, 5.00);

INSERT INTO Tickets (theaterID, seatNum, showingDate, startTime, customerID, ticketPrice)
	VALUES(222, 7, '2019-06-24', '09:00:00', 15, 5.00);

INSERT INTO Tickets (theaterID, seatNum, showingDate, startTime, customerID, ticketPrice)
	VALUES(222, 7, '2019-06-24', '09:00:00', 1010, 5.00);


UPDATE Tickets
	SET ticketPrice = 16.00
	WHERE customerID = 225;

UPDATE Customers
	SET joinDate = '2015-12-01'
	WHERE customerID = 225;

UPDATE Showings
	SET movieID = NULL
	WHERE priceCode = 'A';


UPDATE Tickets
	SET ticketPrice = 0
	WHERE customerID = 225;

UPDATE Customers
	SET joinDate = '2015-11-25'
	WHERE customerID = 225;

UPDATE Showings
	SET movieID = 101, priceCode = NULL 
	WHERE movieID = 101;