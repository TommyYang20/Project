BEGIN TRANSACTION;
SET TRANSACTION READ WRITE ISOLATION LEVEL SERIALIZABLE;
INSERT INTO Showings(theaterID, showingDate, startTime, movieID, priceCode)
	SELECT theaterID, showingDate, startTime, movieID, NULL
	FROM ModifyShowings M
	WHERE NOT EXISTS(
		SELECT *
		FROM Showings
		WHERE Showings.theaterID = M.theaterID
			AND Showings.showingDate = M.showingDate
			AND Showings.startTime = M.startTime
	);
UPDATE Showings
SET movieID = M.movieID
FROM ModifyShowings M
WHERE EXISTS(
	SELECT *
	FROM Showings
	WHERE Showings.theaterID = M.theaterID
		AND Showings.showingDate = M.showingDate
		AND Showings.startTime = M.startTime
		);
COMMIT TRANSACTION;