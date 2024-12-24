WITH ChangeoverTimes AS (
    SELECT 
        wor.WorkOrderID,
        wor.LocationID,
        wor.OperationSequence,
        wor.ScheduledStartDate AS CurrentOperationEnd,  -- Fin de l'opération actuelle
        wor.ScheduledEndDate AS NextOperationStart,    -- Début de la prochaine opération
        LEAD(wor.ScheduledStartDate) OVER (PARTITION BY wor.LocationID ORDER BY wor.OperationSequence) AS NewNextOperationStart,
        LEAD(wor.ScheduledEndDate) OVER (PARTITION BY wor.LocationID ORDER BY wor.OperationSequence) AS NewCurrentOperationEnd
    FROM 
        Production.WorkOrderRouting wor
)
SELECT 
    WorkOrderID,
    LocationID,
    OperationSequence,
    CurrentOperationEnd,    -- Fin de l'opération actuelle
    NextOperationStart,     -- Début de la prochaine opération
    DATEDIFF(MINUTE, CurrentOperationEnd, NextOperationStart) AS ChangeoverTimeMinutes  -- Calcul du temps de changement
FROM 
    ChangeoverTimes
WHERE 
    NextOperationStart > CurrentOperationEnd  -- Assurez-vous que la prochaine opération commence après la fin de l'actuelle
ORDER BY 
    WorkOrderID, OperationSequence;
