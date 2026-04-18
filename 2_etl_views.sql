USE DATABASE FactoryDB;
USE SCHEMA RawData;

--------------------------------------------------
-- STEP 1: LOAD DIM TABLES
--------------------------------------------------

-- DIM TIME
INSERT INTO DimTime (EventTime, Hour, Day, Shift)
SELECT DISTINCT
    EventTime,
    EXTRACT(HOUR FROM EventTime),
    TO_CHAR(EventTime, 'Day'),
    Shift
FROM RawMachineData;

-- DIM LOCATION
INSERT INTO DimLocation (LocationName, Plant, Region)
SELECT DISTINCT 
    Location,
    Location,
    'India'
FROM RawMachineData;

-- DIM FAULT
INSERT INTO DimFault (FaultType, Severity, Description)
SELECT DISTINCT
    FaultType,
    CASE 
        WHEN FaultType = 'Critical Failure' THEN 'High'
        WHEN FaultType = 'Overheat' THEN 'Medium'
        ELSE 'Low'
    END,
    'Auto generated'
FROM RawMachineData;

--------------------------------------------------
-- STEP 2: LOAD FACT TABLE
--------------------------------------------------

INSERT INTO FactMachineLogs (
    MachineID, TimeID, LocationID, FaultID,
    Temperature, Vibration, RunTime, DownTime, ProductionOutput
)
SELECT
    r.MachineID,
    t.TimeID,
    l.LocationID,
    f.FaultID,
    r.Temperature,
    r.Vibration,
    r.RunTime,
    r.DownTime,
    r.ProductionOutput
FROM RawMachineData r
JOIN DimTime t ON r.EventTime = t.EventTime
JOIN DimLocation l ON r.Location = l.LocationName
JOIN DimFault f ON r.FaultType = f.FaultType;

--------------------------------------------------
-- STEP 3: FINAL MACHINE VIEW (CORE LOGIC)
--------------------------------------------------

CREATE OR REPLACE VIEW MachineFinalView AS
SELECT 
    MachineID,

    AVG(
        Temperature * 0.4 + Vibration * 100 * 0.3 + DownTime * 10 * 0.3
    ) AS AvgRisk,

    AVG(
        ProductionOutput / NULLIF(RunTime, 0)
    ) AS AvgEfficiency,

    CASE 
        WHEN AVG(Temperature * 0.4 + Vibration * 100 * 0.3 + DownTime * 10 * 0.3) > 45.5 
             AND AVG(ProductionOutput / NULLIF(RunTime,0)) < 23 
        THEN 'Critical'

        WHEN AVG(Temperature * 0.4 + Vibration * 100 * 0.3 + DownTime * 10 * 0.3) > 45.2 
        THEN 'High Risk'

        WHEN AVG(ProductionOutput / NULLIF(RunTime,0)) < 23.5 
        THEN 'Low Efficiency'

        ELSE 'Healthy'
    END AS MachineStatus

FROM RawMachineData
GROUP BY MachineID;

--------------------------------------------------
-- STEP 4: RANK VIEW
--------------------------------------------------

CREATE OR REPLACE VIEW MachineRankView AS
SELECT *,
       RANK() OVER (ORDER BY AvgRisk DESC) AS RiskRank
FROM MachineFinalView;

--------------------------------------------------
-- STEP 5: FINAL DASHBOARD VIEW
--------------------------------------------------

CREATE OR REPLACE VIEW FinalDashboardView AS
SELECT *,
CASE 
    WHEN MachineStatus = 'Critical' THEN 'Immediate Shutdown'
    WHEN MachineStatus = 'High Risk' THEN 'Urgent Maintenance'
    WHEN MachineStatus = 'Low Efficiency' THEN 'Performance Tuning'
    ELSE 'Normal Operation'
END AS ActionRequired
FROM MachineRankView;

