/*
* File: faa135_Assignment2_EDIT.sql
*
* Author: Aleem, Firas
* Student ID Number: [REDACTED]
* Institutional mail prefix: [REDACTED]
*/


/*
*  Assume a user account 'fsad' with password 'fsad2022' with permission
* to create  databases already exists. You do NO need to include the commands
* to create the user nor to give it permission in you solution.
* For your testing, the following command may be used:
*
* CREATE USER fsad PASSWORD 'fsad2022' CREATEDB;
* GRANT pg_read_server_files TO fsad;
*/


/* *********************************************************
* Exercise 1. Create the Smoked Trout database
* 
************************************************************ */

-- The first time you login to execute this file with \i it may
-- be convenient to change the working directory.
-- \cd '/Users/firas/Uni/⭑FSAD/Assignments/Assignment 2'
\connect postgres;
DROP DATABASE IF EXISTS "SmokedTrout";

-- In PostgreSQL, folders are identified with '/'


-- 1) Create a database called SmokedTrout.
CREATE DATABASE "SmokedTrout" WITH OWNER = fsad ENCODING = 'UTF8' CONNECTION LIMIT = -1;

-- 2) Connect to the database
\c "SmokedTrout" fsad





/* *********************************************************
* Exercise 2. Implement the given design in the Smoked Trout database
* 
************************************************************ */

-- 1) Create a new ENUM type called materialState for storing the raw material state

CREATE TYPE "materialState" AS ENUM ('Gas', 'Liquid', 'Solid', 'Plasma');

-- 2) Create a new ENUM type called materialComposition for storing whether
-- a material is Fundamental or Composite.

CREATE TYPE "materialComposition" AS ENUM ('Fundamental', 'Composite');

-- 3) Create the table TradingRoute with the corresponding attributes.
CREATE TABLE "TradingRoute" (
  "MonitoringKey" SERIAL NOT NULL,
  "FleetSize" integer,
  "OperatingCompany" varchar(40),
  "LastYearRevenue" real,
  PRIMARY KEY ("MonitoringKey")
);

-- 4) Create the table Planet with the corresponding attributes.
CREATE TABLE "Planet" (
  "PlanetID" SERIAL NOT NULL,
  "StarSystem" varchar(40),
  "Name" varchar(40),
  "Population" integer,
  PRIMARY KEY ("PlanetID")
);

-- 5) Create the table SpaceStation with the corresponding attributes.
CREATE TABLE "SpaceStation" (
  "StationID" SERIAL NOT NULL,
  "PlanetID" integer,
  "Name" varchar(40),
  "Longitude" varchar(40),
  "Latitude" varchar(40),
  PRIMARY KEY ("StationID"),
  FOREIGN KEY ("PlanetID") REFERENCES "Planet"("PlanetID") ON UPDATE CASCADE ON DELETE CASCADE
);

-- 6) Create the parent table Product with the corresponding attributes.
CREATE TABLE "Product" (
  "ProductID" SERIAL NOT NULL,
  "Name" varchar(40),
  "VolumePerTon" real,
  "ValuePerTon" real,
  PRIMARY KEY ("ProductID")
);
-- 7) Create the child table RawMaterial with the corresponding attributes.
CREATE TABLE "RawMaterial"(
  "State" "materialState",
  "FundamentalOrComposite" "materialComposition"
) INHERITS ("Product");

-- 8) Create the child table ManufacturedGood. 
CREATE TABLE "ManufacturedGood"(
) INHERITS ("Product");

-- 9) Create the table MadeOf with the corresponding attributes.
CREATE TABLE "MadeOf"(
  "ProductID" integer,
  "ManufacturedGoodID" integer,
  PRIMARY KEY ("ProductID", "ManufacturedGoodID") 
);

-- 10) Create the table Batch with the corresponding attributes.
CREATE TABLE "Batch" (
  "BatchID" SERIAL NOT NULL,
  "ProductID" integer,
  "ExtractionOrManufacturingDate" date,
  "OriginalFrom" integer,
  PRIMARY KEY ("BatchID"),
  FOREIGN KEY ("OriginalFrom") REFERENCES "Planet"("PlanetID") ON UPDATE CASCADE ON DELETE CASCADE
);
-- 11) Create the table Sells with the corresponding attributes.
CREATE TABLE "Sells"(
  "BatchID" integer,
  "StationID" integer,
  PRIMARY KEY ("BatchID", "StationID"),
  FOREIGN KEY ("BatchID") REFERENCES "Batch"("BatchID") ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY ("StationID") REFERENCES "SpaceStation"("StationID") ON UPDATE CASCADE ON DELETE CASCADE
);

-- 12)  Create the table Buys with the corresponding attributes.
CREATE TABLE "Buys"(
  "BatchID" integer,
  "StationID" integer,
  PRIMARY KEY ("BatchID", "StationID"),
  FOREIGN KEY ("BatchID") REFERENCES "Batch"("BatchID") ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY ("StationID") REFERENCES "SpaceStation"("StationID") ON UPDATE CASCADE ON DELETE CASCADE
);

-- 13)  Create the table CallsAt with the corresponding attributes.
CREATE TABLE "CallsAt"(
  "MonitoringKey" integer,
  "StationID" integer,
  "VisitOrder" integer,
  PRIMARY KEY ("MonitoringKey", "StationID"),
  FOREIGN KEY ("MonitoringKey") REFERENCES "TradingRoute"("MonitoringKey") ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY ("StationID") REFERENCES "SpaceStation"("StationID") ON UPDATE CASCADE ON DELETE CASCADE
);

-- 14)  Create the table Distance with the corresponding attributes.
CREATE TABLE "Distance"(
  "PlanetOrigin" integer,
  "PlanetDestination" integer,
  "Distance" DECIMAL,
  --previously real
  PRIMARY KEY ("PlanetOrigin", "PlanetDestination"),
  FOREIGN KEY ("PlanetOrigin") REFERENCES "Planet"("PlanetID") ON UPDATE CASCADE ON DELETE CASCADE,
  FOREIGN KEY ("PlanetDestination") REFERENCES "Planet"("PlanetID") ON UPDATE CASCADE ON DELETE CASCADE
);

/* *********************************************************
* Exercise 3. Populate the Smoked Trout database
* 
************************************************************ */
/* *********************************************************
* NOTE: The copy statement is NOT standard SQL.
* The copy statement does NOT permit on-the-fly renaming columns,
* hence, whenever necessary, we:
* 1) Create a dummy table with the column name as in the file
* 2) Copy from the file to the dummy table
* 3) Copy from the dummy table to the real table
* 4) Drop the dummy table (This is done further below, as I keep
*    the dummy table also to imporrt the other columns)
************************************************************ */



-- 1) Unzip all the data files in a subfolder called data from where you have your code file 
-- NO CODE GOES HERE. THIS STEP IS JUST LEFT HERE TO KEEP CONSISTENCY WITH THE ASSIGNMENT STATEMENT

-- 2) Populate the table TradingRoute with the data in the file TradeRoutes.csv.
CREATE TABLE Dummy ( 
  MonitoringKey SERIAL,
  FleetSize integer,
  OperatingCompany varchar(40),
  LastYearRevenue real NOT NULL);

\copy Dummy FROM './data/TradeRoutes.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "TradingRoute" ("MonitoringKey", "OperatingCompany", "FleetSize", "LastYearRevenue")
SELECT MonitoringKey, OperatingCompany, FleetSize, LastYearRevenue FROM Dummy;

DROP TABLE Dummy;
-- 3) Populate the table Planet with the data in the file Planets.csv.
CREATE TABLE Dummy ( 
  PlanetID SERIAL,
  StarSystem varchar(40),
  Planet varchar(40),
  Population_inMillions_ integer);

\copy Dummy FROM './data/Planets.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Planet" ("PlanetID", "StarSystem", "Name", "Population")
SELECT PlanetID, StarSystem, Planet, Population_inMillions_ FROM Dummy;

DROP TABLE Dummy;

-- 4) Populate the table SpaceStation with the data in the file SpaceStations.csv.
CREATE TABLE Dummy ( 
  StationID SERIAL,
  PlanetID integer,
  SpaceStations varchar(40),
  Longitude varchar(40),
  Latitude varchar(40));

\copy Dummy FROM './data/SpaceStations.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "SpaceStation" ("StationID", "PlanetID", "Name", "Longitude", "Latitude")
SELECT StationID, PlanetID, SpaceStations, Longitude, Latitude FROM Dummy;

DROP TABLE Dummy;

-- 5) Populate the tables RawMaterial and Product with the data in the file Products_Raw.csv. 

CREATE TABLE Dummy ( 
  ProductID SERIAL,
  Product varchar(40),
  Composite varchar(40),
  VolumePerTon real,
  ValuePerTon real,
  State "materialState");


\copy Dummy FROM './data/Products_Raw.csv' WITH (FORMAT CSV, HEADER);

ALTER TABLE dummy ADD COLUMN CompositeEnum "materialComposition";

UPDATE dummy SET CompositeEnum = 'Fundamental' WHERE Composite = 'No';

UPDATE dummy SET CompositeEnum = 'Composite' WHERE Composite = 'Yes';

INSERT INTO "RawMaterial" ("ProductID", "Name", "VolumePerTon", "ValuePerTon", "State", "FundamentalOrComposite")
SELECT ProductID, Product, VolumePerTon, ValuePerTon, State, CompositeEnum FROM Dummy;

DROP TABLE Dummy;

-- 6) Populate the tables ManufacturedGood and Product with the data in the file  Products_Manufactured.csv.
CREATE TABLE Dummy ( 
  ProductID SERIAL,
  Product varchar(40),
  VolumePerTon real,
  ValuePerTon real);

\copy Dummy FROM './data/Products_Manufactured.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "ManufacturedGood" ("ProductID", "Name", "VolumePerTon", "ValuePerTon")
SELECT ProductID, Product, VolumePerTon, ValuePerTon FROM Dummy;

DROP TABLE Dummy;

-- 7) Populate the table MadeOf with the data in the file MadeOf.csv.

CREATE TABLE Dummy(
  ProductID integer,
  ManufacturedGoodID integer);

\copy Dummy FROM './data/MadeOf.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "MadeOf" ("ProductID", "ManufacturedGoodID")
SELECT ProductID, ManufacturedGoodID FROM Dummy;

DROP TABLE Dummy;

-- 8) Populate the table Batch with the data in the file Batches.csv.

CREATE TABLE Dummy(
  BatchID integer,
  ProductID integer,
  ExtractionOrManufacturingDate date,
  OriginalFrom integer);

\copy Dummy FROM './data/Batches.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Batch" ("BatchID", "ProductID", "ExtractionOrManufacturingDate", "OriginalFrom")
SELECT BatchID, ProductID, ExtractionOrManufacturingDate, OriginalFrom FROM Dummy;

DROP TABLE Dummy;

-- 9) Populate the table Sells with the data in the file Sells.csv.
CREATE TABLE Dummy(
  BatchID integer,
  StationID integer);

\copy Dummy FROM './data/Sells.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Sells" ("BatchID", "StationID")
SELECT BatchID, stationID FROM Dummy;

DROP TABLE Dummy;
-- 10) Populate the table Buys with the data in the file Buys.csv.
CREATE TABLE Dummy(
  BatchID integer,
  StationID integer);

\copy Dummy FROM './data/Buys.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Buys" ("BatchID", "StationID")
SELECT BatchID, stationID FROM Dummy;

DROP TABLE Dummy;
-- 11) Populate the table CallsAt with the data in the file CallsAt.csv.
CREATE TABLE Dummy(
  MonitoringKey integer,
  StationID integer,
  VisitOrder integer);

\copy Dummy FROM './data/CallsAt.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "CallsAt" ("MonitoringKey", "StationID", "VisitOrder")
SELECT MonitoringKey, stationID, VisitOrder FROM Dummy;

DROP TABLE Dummy;
-- 12) Populate the table Distance with the data in the file PlanetDistances.csv.
CREATE TABLE Dummy(
  PlanetOrigin integer,
  PlanetDestination integer,
  Distance DECIMAL); --previously real

\copy Dummy FROM './data/PlanetDistances.csv' WITH (FORMAT CSV, HEADER);

INSERT INTO "Distance" ("PlanetOrigin", "PlanetDestination", "Distance")
SELECT PlanetOrigin, PlanetDestination, Distance FROM Dummy;

DROP TABLE Dummy;

/* *********************************************************
* Exercise 4. Query the database
* 
************************************************************ */

-- 4.1 Report last year taxes per company

-- 1) Add an attribute Taxes to table TradingRoute
-- 2) Set the derived attribute taxes as 12% of LastYearRevenue
ALTER TABLE "TradingRoute" ADD COLUMN "Taxes" real GENERATED ALWAYS AS ("LastYearRevenue"*0.12) STORED; 
--previously numeric(15,2)

-- 3) Report the operating company and the sum of its taxes group by company.
SELECT "OperatingCompany", SUM("Taxes") FROM "TradingRoute" 
--return value not called taxes
GROUP BY "OperatingCompany";



-- 4.2 What's the longest trading route in parsecs?

-- 1) Create a dummy table RouteLength to store the trading route and their lengths.
CREATE TABLE "RouteLength"(
  "RouteMonitoringKey" SERIAL,
  "RouteTotalDistance" DECIMAL 
  --prev numeric(15,2)
);

-- 2) Create a view EnrichedCallsAt that brings together trading route, space stations and planets.
CREATE VIEW "EnrichedCallsAt" AS SELECT "CallsAt"."MonitoringKey" AS MonitoringKey, "CallsAt"."VisitOrder" AS VisitOrder, "SpaceStation"."PlanetID" AS Planet, "SpaceStation"."StationID" AS StationID FROM "CallsAt" INNER JOIN "SpaceStation" ON "CallsAt"."StationID" = "SpaceStation"."StationID";
-- 3) Add the support to execute an anonymous code block as follows;
DO
$$
DECLARE 

-- 4) Within the declare section, declare a variable of type real to store a route total distance.
routeDistance real := 0.0; 
-- 5) Within the declare section, declare a variable of type real to store a hop partial distance.
hopPartialDistance real:= 0.0;
-- 6) Within the declare section, declare a variable of type record to iterate over routes.
rRoute RECORD;
-- 7) Within the declare section, declare a variable of type record to iterate over hops.
rHop RECORD;

-- 8) Within the declare section, declare a variable of type text to transiently build dynamic queries.
query text;
-- 9) Within the main body section, loop over routes in TradingRoutes
BEGIN 
FOR rRoute IN SELECT "MonitoringKey" FROM "TradingRoute"
LOOP
  -- 10) Within the loop over routes, get all visited planets (in order) by this trading route.
  query := 'CREATE VIEW "PortsOfCall" AS '
  || 'SELECT Planet, VisitOrder '
  || 'FROM "EnrichedCallsAt" '
  || 'WHERE "EnrichedCallsAt".MonitoringKey = '
  || rRoute."MonitoringKey"
  || ' ORDER BY VisitOrder';


  -- 11) Within the loop over routes, execute the dynamic view
  EXECUTE query;

  -- 12) Within the loop over routes, create a view Hops for storing the hops of that route. 
  query := 'CREATE VIEW "Hops" AS '
  || 'SELECT p1.planet P1, p2.planet P2, p1.visitorder '
  || 'FROM "PortsOfCall" p1 '
  || 'INNER JOIN "PortsOfCall" p2 ' 
  || 'ON p1.visitorder + 1 = p2.visitorder';
  EXECUTE query;

  -- 13) Within the loop over routes, initialize the route total distance to 0.0.
  routeDistance := 0.0;
  -- 14) Within the loop over routes, create an inner loop over the hops 
    query := 'CREATE VIEW distances AS '
    || 'SELECT "Hops".p1 AS h1, "Hops".p2 AS h2, "Distance"."Distance" AS distance '
    || 'FROM "Distance" '
    || 'INNER JOIN "Hops" ' 
    || 'ON "Hops".p1 = "Distance"."PlanetOrigin" AND "Hops".p2 = "Distance"."PlanetDestination" '
    || ' ORDER BY "Hops".visitorder';
  
    EXECUTE query;
    query := 'SELECT SUM(distance) FROM distances';
    EXECUTE query into routeDistance;
  -- 18)  Go back to the routes loop and insert into the dummy table RouteLength the pair (RouteMonitoringKey,RouteTotalDistance).
  INSERT INTO "RouteLength" ("RouteMonitoringKey", "RouteTotalDistance") VALUES (rRoute."MonitoringKey", routeDistance);

  -- 19)  Within the loop over routes, drop the view for Hops (and cascade to delete dependent objects).
  DROP VIEW distances;
  DROP VIEW "Hops" CASCADE;

  -- 20)  Within the loop over routes, drop the view for PortsOfCall (and cascade to delete dependent objects).
  DROP VIEW "PortsOfCall" CASCADE;

END LOOP;
END; 
$$;

-- 21)  Finally, just report the longest route in the dummy table RouteLength.
SELECT "RouteMonitoringKey", "RouteTotalDistance" FROM "RouteLength" WHERE "RouteTotalDistance" = (SELECT MAX("RouteTotalDistance") FROM "RouteLength");
