SELECT DISTINCT Theaters.theaterID, Theaters.address
FROM Theaters, TheaterSeats
WHERE Theaters.theaterID = TheaterSeats.theaterID
AND TheaterSeats.brokenSeat = TRUE