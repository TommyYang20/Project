DROP SCHEMA Lab1 CASCADE; 
CREATE SCHEMA Lab1;


CREATE TABLE Movies(
	movieID integer PRIMARY KEY,
	name VARCHAR(30),
	year integer,
	rating CHAR(1),
	length integer,
	totalEarned numeric(7,2)
);

CREATE TABLE Theaters(
	theaterID integer PRIMARY KEY,
	address VARCHAR(40),
	numSeats integer
);

CREATE TABLE TheaterSeats(
	theaterID integer,
	seatNum integer,
	brokenSeat boolean,
	PRIMARY KEY(theaterID, seatNum),
	FOREIGN KEY(theaterID) REFERENCES Theaters
);

CREATE TABLE Showings(
	theaterID integer,
	showingDate date,
	startTime time,
	movieID integer,
	priceCode CHAR(1),
	PRIMARY KEY(theaterID, showingDate,startTime),
	FOREIGN KEY(movieID) REFERENCES Movies,
	FOREIGN KEY(theaterID) REFERENCES Theaters
);

CREATE TABLE Customers(
	customerID integer PRIMARY KEY,
	name VARCHAR(30),
	address VARCHAR(40),
	joinDate date,
	status CHAR(1)
);

CREATE TABLE Tickets(
	theaterID integer,
	seatNum integer,
	showingDate date,
	startTime time,
	customerID integer,
	ticketPrice numeric(4,2),
	PRIMARY KEY(theaterID, seatNum, showingDate, startTime),
	FOREIGN KEY(customerID) REFERENCES Customers,
	FOREIGN KEY(theaterID, showingDate, startTime) REFERENCES Showings,
	FOREIGN KEY(theaterID, seatNum) REFERENCES TheaterSeats
);