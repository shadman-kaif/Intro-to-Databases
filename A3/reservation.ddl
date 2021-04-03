-- reservadation.ddl
-- Created by:
-- Shadman Kaif 1005303137
-- Abdurrafay Khan 1005215517

-- Table definition
DROP SCHEMA IF EXISTS reservation CASCADE;
CREATE SCHEMA reservation;
SET SEARCH_PATH TO reservation;

-- Enforced Constraints:
-- The age must be greater than 0
-- The rating must be between 0 and 5

-- Redundancies Allowed:
-- None.

-- Skipper
CREATE TABLE skipper (
    -- sID is a primary key and functionally determines sName, rating and age
    sID INT NOT NULL PRIMARY KEY,
    -- sName is a variable char
    sName VARCHAR(50) NOT NULL,
    -- rating is an integer [0, 5]
    rating INT NOT NULL,
    CHECK (rating >= 0 and rating <= 5),
    -- age is an integer that is greater than 0
    age INT NOT NULL,
    CHECK(age > 0)
); 

-- Craft
CREATE TABLE craft (
    -- cID is a primary key and functionally determines cName and length
    cID INT NOT NULL PRIMARY KEY,
    -- cName is a variable char
    cName VARCHAR(50) NOT NULL,
    -- length is an integer in feet
    length INT NOT NULL 
); 

-- Skipper makes reservation of craft
CREATE TABLE reserve (
    sID INT NOT NULL,
    cID INT NOT NULL,
    date TIMESTAMP NOT NULL
);