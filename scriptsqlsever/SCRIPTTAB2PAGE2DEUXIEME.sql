WITH MachineDowntime AS (
    SELECT 
        wor.LocationID AS MachineID,
        wor.WorkOrderID,
        wor.ScheduledEndDate AS PreviousTaskEnd,
        LEAD(wor.ScheduledStartDate) OVER (PARTITION BY wor.LocationID ORDER BY wor.ScheduledStartDate) AS NextTaskStart
    FROM 
        Production.WorkOrderRouting wor
)
SELECT 
    loc.LocationID AS MachineID,
    ISNULL(SUM(CASE 
        WHEN DATEDIFF(MINUTE, PreviousTaskEnd, NextTaskStart) > 0 
        THEN DATEDIFF(MINUTE, PreviousTaskEnd, NextTaskStart) 
        ELSE 0 
    END), 0) AS TotalDowntimeMinutes
FROM 
    Production.Location loc
LEFT JOIN 
    MachineDowntime md ON loc.LocationID = md.MachineID
GROUP BY 
    loc.LocationID
ORDER BY 
    loc.LocationID;
