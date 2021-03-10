-- Q2. Refunds!

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q2 CASCADE;

CREATE TABLE q2 (
    airline CHAR(2),
    name VARCHAR(50),
    year CHAR(4),
    seat_class seat_class,
    refund REAL
);

-- Do this for each of the views that define your intermediate steps.
-- (But give them better names!) The IF EXISTS avoids generating an error
-- the first time this file is imported.
DROP VIEW IF EXISTS inbound_flights CASCADE;
DROP VIEW IF EXISTS outbound_flights CASCADE;
DROP VIEW IF EXISTS domestic_flights CASCADE;
DROP VIEW IF EXISTS inter_flights CASCADE;

-- Define views for your intermediate steps here:
-- Match the code for airports with inbound flight code
CREATE VIEW inbound_flights AS
SELECT *
FROM flight JOIN airport ON airport.code = flight.inbound;

-- Match the code for airports with outbound flight code
CREATE VIEW outbound_flights AS
SELECT *
FROM flight JOIN airport ON airport.code = flight.outbound;

-- Find the domestic flights
CREATE VIEW domestic_flights AS
SELECT outbound_flights.id, outbound_flights.airline, outbound_flights.s_dep, outbound_flights.s_arv
FROM inbound_flights JOIN outbound_flights ON
inbound_flights.id = outbound_flights.id and inbound_flights.country = outbound_flights.country;

-- Find the international flights
CREATE VIEW inter_flights AS
SELECT outbound_flights.id, outbound_flights.airline, outbound_flights.s_dep, outbound_flights.s_arv
FROM inbound_flights JOIN outbound_flights ON
inbound_flights.id = outbound_flights.id and inbound_flights.country != outbound_flights.country;

-- Your query that answers the question goes below the "insert into" line:
--INSERT INTO q2
SELECT * FROM inter_flights;
SELECT * FROM domestic_flights;