USE DATABASE FactoryDB;
USE SCHEMA RawData;

--RAWDATA
SELECT
  *
FROM
  "FACTORYDB"."RAWDATA"."RAWMACHINEDATA"
LIMIT
  10;

-- FINAL OUTPUT
SELECT * FROM FinalDashboardView;

-- TOP 5 RISK MACHINES
SELECT * FROM MachineRankView
ORDER BY RiskRank
LIMIT 5;

-- LOW EFFICIENCY MACHINES
SELECT * FROM MachineRankView
WHERE MachineStatus = 'Low Efficiency';

-- ACTION SUMMARY
SELECT 
    ActionRequired,
    COUNT(*) AS MachineCount
FROM FinalDashboardView
GROUP BY ActionRequired;