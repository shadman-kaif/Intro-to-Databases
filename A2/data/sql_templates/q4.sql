-- Q4. Plane Capacity Histogram

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q4 CASCADE;

CREATE TABLE q4 (
	airline CHAR(2),
	tail_number CHAR(5),
	very_low INT,
	low INT,
	fair INT,
	normal INT,
	high INT
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS tot_capacity CASCADE;
DROP VIEW IF EXISTS percent_calc CASCADE;
DROP VIEW IF EXISTS v_low_capacity CASCADE;
DROP VIEW IF EXISTS low_capacity CASCADE;
DROP VIEW IF EXISTS fair_capacity CASCADE;
DROP VIEW IF EXISTS normal_capacity CASCADE;
DROP VIEW IF EXISTS high_capacity CASCADE;
DROP VIEW IF EXISTS solution CASCADE;

-- Define views for your intermediate steps here:

-- Combine 3 tables to find required info such as: consider only flights that depart,
-- find total capacity, and count the number of people that use the flight
CREATE VIEW tot_capacity AS
SELECT flight.id, flight.airline, plane.tail_number, 
(plane.capacity_economy + plane.capacity_business + plane.capacity_first) as capacity,
count(*) as people_count
FROM departure JOIN flight ON flight.id = departure.flight_id 
JOIN plane ON plane.tail_number = flight.plane
JOIN booking ON booking.flight_id = flight.id
GROUP BY flight.id, flight.airline, plane.tail_number; 

-- Find the percent of the flight that is occupied by passengers
CREATE VIEW percent_calc AS
SELECT id, airline, tail_number, capacity, people_count, CAST(people_count as FLOAT)/CAST(capacity as FLOAT) as percent
FROM tot_capacity;

-- Find the count of the very low, low, fair, normal, and high occupancies

-- Find the very low occupany by checking 0% to 20% capacity
CREATE VIEW v_low_capacity AS
SELECT airline, tail_number, count(*) as very_low
FROM percent_calc
WHERE percent >= 0 and percent < 0.20
GROUP BY airline, tail_number;

-- Find the low occupany by checking 20% to 40% capacity
CREATE VIEW low_capacity AS
SELECT airline, tail_number, count(*) as low
FROM percent_calc
WHERE percent >= 0.20 and percent < 0.40
GROUP BY airline, tail_number;

-- Find the fair occupany by checking 40% to 60% capacity
CREATE VIEW fair_capacity AS
SELECT airline, tail_number, count(*) as fair
FROM percent_calc
WHERE percent >= 0.40 and percent < 0.60
GROUP BY airline, tail_number;

-- Find the normal occupany by checking 40% to 60% capacity
CREATE VIEW normal_capacity AS
SELECT airline, tail_number, count(*) as normal
FROM percent_calc
WHERE percent >= 0.60 and percent < 0.80
GROUP BY airline, tail_number;

-- Find the high occupany by checking >= 80%
CREATE VIEW high_capacity AS
SELECT airline, tail_number, count(*) as high
FROM percent_calc
WHERE percent >= 0.80
GROUP BY airline, tail_number;

-- Natural left join all the columns and pad all null values with 0
CREATE VIEW solution AS
SELECT airline, tail_number, COALESCE(very_low, 0) as very_low, COALESCE(low, 0) as low,
COALESCE(fair, 0) as fair, COALESCE(normal, 0) as normal, COALESCE(high, 0) as high
FROM 
plane NATURAL LEFT JOIN
v_low_capacity NATURAL LEFT JOIN
low_capacity NATURAL LEFT JOIN
fair_capacity NATURAL LEFT JOIN
normal_capacity NATURAL LEFT JOIN
high_capacity;

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q4
SELECT * FROM solution;