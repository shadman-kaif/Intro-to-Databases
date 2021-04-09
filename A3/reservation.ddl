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
-- The rating must be in range [0,5]
-- Length must be greater than equal to 0 feet
-- sID is a primary key constraint within skipper
-- cID is a primary key constraint within craft
-- sID is a foreign key constraint within reserve from skipper
-- cID is a foreign key constraint within reserve from craft

-- Real Life Constraint not Enforced:
-- one skipper can reserve two different crafts at the same time,
-- and one craft can be reserved by two different skippers at the same time.
-- This is not allowed as no FDs determine day and the use of assertions or triggers 
-- to mitigate this constraint is not allowed.

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
    CHECK (age > 0)
); 

-- Craft
CREATE TABLE craft (
    -- cID is a primary key and functionally determines cName and length
    cID INT NOT NULL PRIMARY KEY,
    -- cName is a variable char
    cName VARCHAR(50) NOT NULL,
    -- length is an integer in feet greater than equal to 0
    length INT NOT NULL,
    CHECK (length >= 0)
); 

-- Skipper makes reservation of craft
CREATE TABLE reserve (
    sID INT NOT NULL,
    cID INT NOT NULL,
    -- day is of timestamp
    day TIMESTAMP NOT NULL,
    -- sID and cID are foreign key constraints from their respective tables
    PRIMARY KEY (sID, cID),
    FOREIGN KEY (sID) REFERENCES skipper,
    FOREIGN KEY (cID) REFERENCES craft
);