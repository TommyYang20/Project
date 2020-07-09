-- Find the ID,name,year and length for every movie which was longer than the 2011 movie Avengers.
-- movies with the largest year should appear first
-- movies should be in alphabetized by name
-- No duplicate

SELECT movieID, name, year, length
FROM Movies
WHERE length > (SELECT length FROM Movies WHERE name = 'Avengers' AND year = 2011)
ORDER BY year DESC, name