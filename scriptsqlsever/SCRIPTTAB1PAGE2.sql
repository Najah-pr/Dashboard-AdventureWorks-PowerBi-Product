SELECT 
    LocationID AS MachineID,
    CONVERT(DATE, ScheduledStartDate) AS ProductionDate,
    SUM(DATEDIFF(MINUTE, ActualStartDate, ActualEndDate)) AS ActualUsageMinutes,
    SUM(DATEDIFF(MINUTE, ScheduledStartDate, ScheduledEndDate)) AS PlannedUsageMinutes,
    CASE 
        WHEN SUM(DATEDIFF(MINUTE, ScheduledStartDate, ScheduledEndDate)) = 0 THEN 0
        ELSE ROUND(
            (CAST(SUM(DATEDIFF(MINUTE, ActualStartDate, ActualEndDate)) AS FLOAT) / 
            SUM(DATEDIFF(MINUTE, ScheduledStartDate, ScheduledEndDate))) * 100, 2)
    END AS UtilizationRate
FROM 
    Production.WorkOrderRouting
GROUP BY 
    LocationID, CONVERT(DATE, ScheduledStartDate)
ORDER BY 
    MachineID, ProductionDate;
