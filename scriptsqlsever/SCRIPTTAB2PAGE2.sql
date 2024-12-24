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
    MachineID,
    SUM(DATEDIFF(MINUTE, PreviousTaskEnd, NextTaskStart)) AS TotalDowntimeMinutes
FROM 
    MachineDowntime
WHERE 
    NextTaskStart IS NOT NULL -- Éviter les dernières tâches sans successeur
    AND DATEDIFF(MINUTE, PreviousTaskEnd, NextTaskStart) > 0 -- Temps d'arrêt positif uniquement
GROUP BY 
    MachineID
ORDER BY 
    MachineID;
