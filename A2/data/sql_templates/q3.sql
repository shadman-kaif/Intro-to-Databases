-- Q3. North and South Connections

-- You must not change the next 2 lines or the table definition.
SET SEARCH_PATH TO air_travel, public;
DROP TABLE IF EXISTS q3 CASCADE;

CREATE TABLE q3 (
    outbound VARCHAR(30),
    inbound VARCHAR(30),
    direct INT,
    one_con INT,
    two_con INT,
    earliest timestamp
);

-- Do this for each of the views that define your intermediate steps.  
-- (But give them better names!) The IF EXISTS avoids generating an error 
-- the first time this file is imported.
DROP VIEW IF EXISTS inbound_flights CASCADE;
DROP VIEW IF EXISTS outbound_flights CASCADE;
DROP VIEW IF EXISTS master_list_combinations CASCADE;
DROP VIEW IF EXISTS us_can_direct_flights CASCADE;
DROP VIEW IF EXISTS us_can_link CASCADE; 
DROP VIEW IF EXISTS one_connection CASCADE; 
DROP VIEW IF EXISTS two_connection CASCADE; 
DROP VIEW IF EXISTS one_connection_final CASCADE;
DROP VIEW IF EXISTS direct_connection_final CASCADE;
DROP VIEW IF EXISTS two_connection_final CASCADE;
DROP VIEW IF EXISTS solution CASCADE;

-- Define views for your intermediate steps here:

-- Find the inbound flights that occur on April 30, 2021
CREATE VIEW inbound_flights AS
SELECT *
FROM flight JOIN airport ON flight.inbound = airport.code
WHERE
EXTRACT(YEAR FROM s_dep) = 2021 and
EXTRACT(MONTH FROM s_dep) = 04 and
EXTRACT(DAY FROM s_dep) = 30 and
EXTRACT(YEAR FROM s_arv) = 2021 and
EXTRACT(MONTH FROM s_arv) = 04 and
EXTRACT(DAY FROM s_arv) = 30;

-- Find the outbound flights that occur on April 30, 2021
CREATE VIEW outbound_flights AS
SELECT *
FROM flight JOIN airport ON flight.outbound = airport.code
WHERE
EXTRACT(YEAR FROM s_dep) = 2021 and
EXTRACT(MONTH FROM s_dep) = 04 and
EXTRACT(DAY FROM s_dep) = 30 and
EXTRACT(YEAR FROM s_arv) = 2021 and
EXTRACT(MONTH FROM s_arv) = 04 and
EXTRACT(DAY FROM s_arv) = 30;

-- Master List of combinations from Canada to US
CREATE VIEW master_list_combinations AS
SELECT DISTINCT a1.city as out, a2.city as in
FROM airport as a1, airport as a2
WHERE ((a1.country = 'USA' and a2.country = 'Canada') OR (a1.country = 'Canada' and a2.country = 'USA'));

-- Find any flights that take place from Canada to Canada, US to US, Canada to US or US to Canada
-- This will be useful in finding different connections throughout the day
CREATE VIEW us_can_link AS
SELECT outbound_flights.id, inbound_flights.country as country_to, outbound_flights.country as country_from,
inbound_flights.city as city_to, outbound_flights.city as city_from, outbound_flights.s_dep, outbound_flights.s_arv
FROM outbound_flights JOIN inbound_flights ON inbound_flights.id = outbound_flights.id;

-- Find the direct flights from US to Canada or Canada to US that occur on April 4, 2021
CREATE VIEW us_can_direct_flights AS
SELECT outbound_flights.id, inbound_flights.country as country_to, outbound_flights.country as country_from,
inbound_flights.city as city_to, outbound_flights.city as city_from, outbound_flights.s_dep, outbound_flights.s_arv
FROM outbound_flights JOIN inbound_flights ON inbound_flights.id = outbound_flights.id
WHERE (inbound_flights.country = 'USA' and outbound_flights.country = 'Canada') or
(inbound_flights.country = 'Canada' and outbound_flights.country = 'USA');

-- Find the one connection flights using self join
CREATE VIEW one_connection AS
SELECT link1.id as link1_id, link2.id as link2_id,
link1.city_to as city_to_link1, link1.city_from as city_from_link1,
link2.city_to as city_to_link2, link2.city_from as city_from_link2, link1.s_dep as link1_sdep,
link1.s_arv as link1_sarv, link2.s_dep as link2_sdep, link2.s_arv as link2_sarv 
FROM us_can_link as link1 JOIN us_can_link as link2 ON link1.id != link2.id and
link1.city_to = link2.city_from 
WHERE ((link1.country_from = 'USA' and link2.country_to = 'Canada') OR 
(link1.country_from = 'Canada' and link2.country_to = 'USA'))
and (link2.s_dep - link1.s_arv) >= '00:30:00';

-- Find the two connection flights using triple self join
CREATE VIEW two_connection AS
SELECT link1.id as link1_id, link2.id as link2_id, link3.id as link3_id, 
link1.city_to as city_to_link1, link1.city_from as city_from_link1,
link2.city_to as city_to_link2, link2.city_from as city_from_link2,
link3.city_to as city_to_link3, link3.city_from as city_from_link3,
link1.s_dep as link1_sdep, link1.s_arv as link1_sarv, 
link2.s_dep as link2_sdep, link2.s_arv as link2_sarv, 
link3.s_dep as link3_sdep, link3.s_arv as link3_sarv 
FROM us_can_link as link1 JOIN us_can_link as link2 ON link1.id != link2.id and link1.city_to = link2.city_from
JOIN us_can_link as link3 ON link2.id != link3.id and link2.city_to = link3.city_from
WHERE ((link1.country_from = 'USA' and link3.country_to = 'Canada') OR 
(link1.country_from = 'Canada' and link3.country_to = 'USA'))
and (link2.s_dep - link1.s_arv) >= '00:30:00'
and (link3.s_dep - link2.s_arv) >= '00:30:00';

-- Find the final one connection flight 
CREATE VIEW one_connection_final AS
SELECT master_list_combinations.out, master_list_combinations.in, min(link2_sarv) as earliest, count(link2_sarv)
FROM one_connection RIGHT JOIN master_list_combinations ON 
master_list_combinations.out = one_connection.city_from_link1 
and 
master_list_combinations.in = one_connection.city_to_link2
GROUP BY master_list_combinations.out, master_list_combinations.in;

-- Find the final direct connection flight
CREATE VIEW direct_connection_final AS
SELECT master_list_combinations.out, master_list_combinations.in, min(s_arv) as earliest, count(s_arv)
FROM us_can_direct_flights RIGHT JOIN master_list_combinations ON 
master_list_combinations.out = us_can_direct_flights.city_from
and 
master_list_combinations.in = us_can_direct_flights.city_to
GROUP BY master_list_combinations.out, master_list_combinations.in;

-- Find the final two connection flight
CREATE VIEW two_connection_final AS
SELECT master_list_combinations.out, master_list_combinations.in, min(link3_sarv) as earliest, count(link3_sarv) 
FROM two_connection RIGHT JOIN master_list_combinations ON
master_list_combinations.out = two_connection.city_from_link1
and 
master_list_combinations.in = two_connection.city_to_link3
GROUP BY master_list_combinations.out, master_list_combinations.in;

-- Combine all the connection flights using union
CREATE VIEW solution AS
(SELECT *
FROM one_connection_final)
UNION
(SELECT *
FROM two_connection_final)
UNION
(SELECT *
FROM direct_connection_final);

-- Your query that answers the question goes below the "insert into" line:
INSERT INTO q3
SELECT direct_connection_final.out, direct_connection_final.in, direct_connection_final.count AS direct, 
one_connection_final.count as one_con, two_connection_final.count as two_con, min(solution.earliest) as earliest
FROM direct_connection_final JOIN one_connection_final ON direct_connection_final.out = one_connection_final.out 
and direct_connection_final.in = one_connection_final.in
JOIN two_connection_final ON one_connection_final.out = two_connection_final.out
and one_connection_final.in = two_connection_final.in
JOIN solution ON two_connection_final.out = solution.out and two_connection_final.in = solution.in
GROUP BY direct_connection_final.out, direct_connection_final.in, direct_connection_final.count, one_connection_final.count, two_connection_final.count;
SELECT * FROM q3;