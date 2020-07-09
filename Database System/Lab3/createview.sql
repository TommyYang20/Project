CREATE VIEW earningsView
AS
  SELECT DISTINCT M.movieID AS movieID, CASE
    WHEN SUM(T.ticketPrice) IS NOT NULL
      THEN SUM (T.ticketPrice)
      ELSE 0
    END AS computedEarnings
  From ((Movies M LEFT JOIN Showings S
    ON M.movieID = S.movieID) LEFT JOIN Tickets T
  ON S.theaterID = T.theaterID
        AND S.showingDate = T.showingDate
        AND S.startTime = T.startTime)
    GROUP BY M.movieID;



