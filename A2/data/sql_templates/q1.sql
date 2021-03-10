-- Q1. Airlines

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q1 CASCADE;

CREATE TABLE q1 (
   pass_id INT,
   name VARCHAR(100),
   airlines INT
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS flights_done CASCADE;

-- Define views for your intermediate steps here:
-- Create view that finds all successful landed flights
CREATE VIEW flights_done AS
SELECT *
FROM arrival JOIN flight ON arrival.flight_id = flight.id;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q1

-- Select required columns

-- Extract pass_id, concatonated name, and distinct num of airlines
SELECT booking.pass_id as pass_id, CONCAT(passenger.firstname, ' ', passenger.surname), count(distinct airline) as airlines
-- Perform three right joins, preserving the containments of the queries                                                
FROM flights_done RIGHT JOIN booking ON booking.flight_id = flights_done.flight_id
RIGHT JOIN passenger ON passenger.id = booking.pass_id
-- Group by the extracted pieces of information
GROUP BY booking.pass_id, passenger.firstname, passenger.surname;