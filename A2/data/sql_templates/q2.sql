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
DROP VIEW IF EXISTS dr_35 CASCADE;
DROP VIEW IF EXISTS dr_50 CASCADE;
DROP VIEW IF EXISTS ir_35 CASCADE;
DROP VIEW IF EXISTS ir_50 CASCADE;
DROP VIEW IF EXISTS dr_35_final CASCADE;
DROP VIEW IF EXISTS dr_50_final CASCADE;                                                                                
DROP VIEW IF EXISTS ir_35_final CASCADE;
DROP VIEW IF EXISTS solution CASCADE;

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
inbound_flights.id = outbound_flights.id and inbound_flights.country != outbound_flights.country;                                                                                                                                               -- Find the domestic flights with 35% refund

-- Find the domestic flights with 35% refund
CREATE VIEW dr_35 AS
SELECT domestic_flights.id as id, domestic_flights.airline, departure.datetime as dep_time
FROM domestic_flights JOIN departure ON departure.flight_id = domestic_flights.id
JOIN arrival ON domestic_flights.id = arrival.flight_id
WHERE (departure.datetime - domestic_flights.s_dep) < '10:00:00' and
(departure.datetime - domestic_flights.s_dep) >= '05:00:00' and
(departure.datetime - domestic_flights.s_dep) <= 2 * (arrival.datetime - domestic_flights.s_arv);

-- Find the domestic flights with 50% refund
CREATE VIEW dr_50 AS
SELECT domestic_flights.id as id, domestic_flights.airline, departure.datetime as dep_time
FROM domestic_flights JOIN departure ON departure.flight_id = domestic_flights.id
JOIN arrival ON domestic_flights.id = arrival.flight_id
WHERE (departure.datetime - domestic_flights.s_dep) >= '10:00:00' and
(departure.datetime - domestic_flights.s_dep) <= 2 * (arrival.datetime - domestic_flights.s_arv);

-- Find the international flights with 35% refund
CREATE VIEW ir_35 AS
SELECT inter_flights.id, inter_flights.airline, departure.datetime as dep_time
FROM inter_flights JOIN departure ON departure.flight_id = inter_flights.id
JOIN arrival ON arrival.flight_id = inter_flights.id
WHERE (departure.datetime - inter_flights.s_dep) >= '08:00:00' and
(departure.datetime - inter_flights.s_dep) < '12:00:00' and
(departure.datetime - inter_flights.s_dep) <= 2 * (arrival.datetime - inter_flights.s_arv);

-- Find the international flights with 50% refund
CREATE VIEW ir_50 AS
SELECT inter_flights.id, inter_flights.airline, departure.datetime as dep_time
FROM inter_flights JOIN departure ON inter_flights.id = departure.flight_id
JOIN arrival ON inter_flights.id = arrival.flight_id
WHERE (departure.datetime - inter_flights.s_dep) >= '12:00:00' and
(departure.datetime - inter_flights.s_dep) <= 2 * (arrival.datetime - inter_flights.s_arv);

-- Find the required information for domestic refunds for 35%
CREATE VIEW dr_35_final AS
SELECT dr_35.id, flight.airline as airline, airline.name, 0.35 * booking.price as refund, booking.seat_class,
EXTRACT(YEAR FROM dr_35.dep_time) as year
FROM dr_35 JOIN booking ON dr_35.id = booking.flight_id
JOIN flight ON flight.id = dr_35.id
JOIN airline ON airline.code = flight.airline;

-- Find the required information for domestic refunds for 50%
CREATE VIEW dr_50_final AS
SELECT dr_50.id, flight.airline as airline, airline.name, 0.50 * booking.price as refund, booking.seat_class,
EXTRACT(YEAR FROM dr_50.dep_time) as year
FROM dr_50 JOIN booking ON dr_50.id = booking.flight_id
JOIN flight ON flight.id = dr_50.id
JOIN airline ON airline.code = flight.airline;

-- Find the required information for international refunds for 35% 
CREATE VIEW ir_35_final AS                                                                                              
SELECT ir_35.id, flight.airline as airline, airline.name, 0.35 * booking.price as refund, booking.seat_class,
EXTRACT(YEAR FROM ir_35.dep_time) as year
FROM ir_35 JOIN booking ON ir_35.id = booking.flight_id
JOIN flight ON flight.id = ir_35.id
JOIN airline ON airline.code = flight.airline;

-- Find the required information for international refunds for 50%
CREATE VIEW ir_50_final AS
SELECT ir_50.id, flight.airline as airline, airline.name, 0.50 * booking.price as refund, booking.seat_class,
EXTRACT(YEAR FROM ir_50.dep_time) as year
FROM ir_50 JOIN booking on ir_50.id = booking.flight_id
JOIN flight ON flight.id = ir_50.id
JOIN airline ON airline.code = flight.airline;

-- Combine all the final queries created
CREATE VIEW solution AS
(SELECT * FROM dr_35_final)
UNION
(SELECT * FROM dr_50_final)
UNION
(SELECT * FROM ir_35_final)
UNION
(SELECT * FROM ir_50_final);

-- Your query that answers the question goes below the "insert into" line:                                              
INSERT INTO q2                                                                                                          
SELECT airline, name, year, seat_class, sum(refund) as refund
FROM solution
GROUP BY airline, name, year, seat_class;
SELECT * from q2;

