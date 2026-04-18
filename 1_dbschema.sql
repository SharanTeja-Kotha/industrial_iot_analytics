-- DATABASE & SCHEMA
CREATE DATABASE FactoryDB;
USE DATABASE FactoryDB;

CREATE SCHEMA RawData;
USE SCHEMA RawData;

-- RAW TABLE
CREATE OR REPLACE TABLE RawMachineData (
    MachineID STRING,
    EventTime TIMESTAMP,
    Temperature FLOAT,
    Vibration FLOAT,
    RunTime FLOAT,
    DownTime FLOAT,
    ProductionOutput INT,
    FaultType STRING,
    Shift STRING,
    Location STRING
);

-- DIM TABLES
CREATE OR REPLACE TABLE DimTime (
    TimeID INT AUTOINCREMENT,
    EventTime TIMESTAMP,
    Hour INT,
    Day STRING,
    Shift STRING
);

CREATE OR REPLACE TABLE DimLocation (
    LocationID INT AUTOINCREMENT,
    LocationName STRING,
    Plant STRING,
    Region STRING
);

CREATE OR REPLACE TABLE DimFault (
    FaultID INT AUTOINCREMENT,
    FaultType STRING,
    Severity STRING,
    Description STRING
);

-- FACT TABLE
CREATE OR REPLACE TABLE FactMachineLogs (
    LogID INT AUTOINCREMENT,
    MachineID STRING,
    TimeID INT,
    LocationID INT,
    FaultID INT,
    Temperature FLOAT,
    Vibration FLOAT,
    RunTime FLOAT,
    DownTime FLOAT,
    ProductionOutput INT
);FACTORYDB.RAWDATA.RAWMACHINEDATA