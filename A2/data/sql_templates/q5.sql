-- Q5. Flight Hopping

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q5 CASCADE;

CREATE TABLE q5 (
	destination CHAR(3),
	num_flights INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS intermediate_step CASCADE;
DROP VIEW IF EXISTS day CASCADE;
DROP VIEW IF EXISTS n CASCADE;

CREATE VIEW day AS
SELECT day::date as day FROM q5_parameters;
-- can get the given date using: (SELECT day from day)

CREATE VIEW n AS
SELECT n FROM q5_parameters;
-- can get the given number of flights using: (SELECT n from n)

-- HINT: You can answer the question by writing one recursive query below, without any more views.
-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q5

WITH RECURSIVE maxFlights AS (
	
	(
	SELECT inbound, outbound, s_dep, s_arv, 1 as flight_num, n
	FROM Flight, n, day
	WHERE outbound = 'YYZ' and date(s_dep) = (SELECT day from day)
	)

	UNION ALL

	(
	SELECT Flight.inbound, Flight.outbound, Flight.s_dep, Flight.s_arv, (maxFlights.flight_num+1) as flight_num, n
	FROM Flight, maxFlights
	WHERE Flight.outbound = maxFlights.inbound and (maxFlights.flight_num + 1) < (SELECT n from n) and (Flight.s_dep - maxFlights.s_arv) <= '24:00:00' and (Flight.s_dep - maxFlights.s_arv) >= '00:00:00'
	)

)SELECT inbound as destination, flight_num as num_flights
FROM maxFlights;

SELECT * FROM q5;














