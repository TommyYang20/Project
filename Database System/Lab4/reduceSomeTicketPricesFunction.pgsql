CREATE OR REPLACE FUNCTION reduceSomeTicketPricesFunction(maxTicketCount integer) 
RETURNS integer AS $$
	DECLARE count INTEGER := 0;
	DECLARE countA INTEGER := 0;
	DECLARE countB INTEGER := 0;
	DECLARE countC INTEGER := 0;
	DECLARE TheaterID1 INTEGER;
	DECLARE SeatNum1 INTEGER;
	DECLARE ShowingDate1 DATE;
	DECLARE StartTIme1 TIME;

	DECLARE A CURSOR FOR
		SELECT T.theaterID, T.seatNum, T.showingDate, T.startTime
		From Tickets T, Showings S
		WHERE T.ticketPrice IS NOT NULL
			AND T.theaterID = S.theaterID
			AND	T.showingDate = S.showingDate
			AND T.startTime = S.startTime
			AND S.priceCode = 'A'
		ORDER BY T.customerID;

	DECLARE B CURSOR FOR
		SELECT T.theaterID, T.seatNum, T.showingDate, T.startTime
		From Tickets T, Showings S
		WHERE T.ticketPrice IS NOT NULL
			AND T.theaterID = S.theaterID
			AND	T.showingDate = S.showingDate
			AND T.startTime = S.startTime
			AND S.priceCode = 'B'
		ORDER BY T.customerID;

	DECLARE C CURSOR FOR
		SELECT T.theaterID, T.seatNum, T.showingDate, T.startTime
		From Tickets T, Showings S
		WHERE T.ticketPrice IS NOT NULL
			AND T.theaterID = S.theaterID
			AND	T.showingDate = S.showingDate
			AND T.startTime = S.startTime
			AND S.priceCode = 'C'
		ORDER BY T.customerID;

	BEGIN
		OPEN A;
		LOOP
			EXIT WHEN count = maxTicketCount;
			FETCH A INTO TheaterID1, SeatNum1, ShowingDate1, StartTIme1;
			EXIT WHEN NOT FOUND;

			UPDATE Tickets
			SET ticketPrice = ticketPrice  - 3
			WHERE theaterID = TheaterID1
				AND seatNum = SeatNum1
				AND showingDate = ShowingDate1
				AND startTime = StartTime1;

			countA:= countA + 1;	
			count:= count + 1;
			
		END LOOP;
		CLOSE A;

		OPEN B;
		LOOP
			EXIT WHEN count = maxTicketCount;
			FETCH B INTO TheaterID1, SeatNum1, ShowingDate1, StartTIme1;
			EXIT WHEN NOT FOUND;

			UPDATE Tickets
			SET ticketPrice = ticketPrice - 2
			WHERE theaterID = TheaterID1
				AND seatNum = SeatNum1
				AND showingDate = ShowingDate1
				AND startTime = StartTime1;

			countB:= countB + 1;	
			count:= count + 1;
			
		END LOOP;
		CLOSE B;

		OPEN C;
		LOOP
			EXIT WHEN count = maxTicketCount;
			FETCH C INTO TheaterID1, SeatNum1, ShowingDate1, StartTIme1;
			EXIT WHEN NOT FOUND;

			UPDATE Tickets
			SET ticketPrice = ticketPrice  - 1
			WHERE theaterID = TheaterID1
				AND seatNum = SeatNum1
				AND showingDate = ShowingDate1
				AND startTime = StartTime1;

			countC:= countC + 1;	
			count:= count + 1;
			
		END LOOP;
		CLOSE C;

		RETURN (countA*3)+(countB*2)+countC;

	END;

$$ LANGUAGE plpgsql;
