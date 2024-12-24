WITH ChangeoverTimes AS (
    SELECT 
        wor.WorkOrderID,
        wor.LocationID,
        wor.OperationSequence,
        wor.ScheduledStartDate AS CurrentOperationEnd,  -- Fin de l'op�ration actuelle
        wor.ScheduledEndDate AS NextOperationStart,    -- D�but de la prochaine op�ration
        LEAD(wor.ScheduledStartDate) OVER (PARTITION BY wor.LocationID ORDER BY wor.OperationSequence) AS NewNextOperationStart,
        LEAD(wor.ScheduledEndDate) OVER (PARTITION BY wor.LocationID ORDER BY wor.OperationSequence) AS NewCurrentOperationEnd
    FROM 
        Production.WorkOrderRouting wor
)
SELECT 
    WorkOrderID,
    LocationID,
    OperationSequence,
    CurrentOperationEnd,    -- Fin de l'op�ration actuelle
    NextOperationStart,     -- D�but de la prochaine op�ration
    DATEDIFF(MINUTE, CurrentOperationEnd, NextOperationStart) AS ChangeoverTimeMinutes  -- Calcul du temps de changement
FROM 
    ChangeoverTimes
WHERE 
    NextOperationStart > CurrentOperationEnd  -- Assurez-vous que la prochaine op�ration commence apr�s la fin de l'actuelle
ORDER BY 
    WorkOrderID, OperationSequence;
