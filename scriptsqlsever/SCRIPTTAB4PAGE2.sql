WITH EquipmentData AS (
    SELECT 
        wor.LocationID AS MachineID,
        DATEDIFF(MINUTE, wor.ScheduledStartDate, wor.ScheduledEndDate) AS ScheduledTimeMinutes,
        DATEDIFF(MINUTE, wor.ActualStartDate, wor.ActualEndDate) AS ActualTimeMinutes,
        wor.PlannedCost, -- Utilisé pour la performance (si applicable)
        wor.ActualCost, -- Utilisé pour la performance (si applicable)
        wor.ActualResourceHrs AS ActualProductionHours,
        wo.OrderQty AS TotalProduced,
        wo.ScrappedQty AS ScrapQuantity
    FROM 
        Production.WorkOrderRouting wor
    INNER JOIN 
        Production.WorkOrder wo ON wor.WorkOrderID = wo.WorkOrderID
),
TRS_Calculation AS (
    SELECT 
        MachineID,
        -- Disponibilité : Temps réel de fonctionnement par rapport au temps planifié
        CASE 
            WHEN SUM(ScheduledTimeMinutes) = 0 THEN 0
            ELSE ROUND((CAST(SUM(ActualTimeMinutes) AS FLOAT) / SUM(ScheduledTimeMinutes)) * 100, 2)
        END AS Availability,

        -- Performance : Production réelle par rapport à la production théorique (simplifié ici)
        CASE 
            WHEN SUM(ActualProductionHours) = 0 THEN 0
            ELSE ROUND((CAST(SUM(ActualProductionHours) AS FLOAT) / SUM(ScheduledTimeMinutes)) * 100, 2)
        END AS Performance,

        -- Qualité : Quantité bonne par rapport à la quantité totale produite
        CASE 
            WHEN SUM(TotalProduced) = 0 THEN 0
            ELSE ROUND(((SUM(TotalProduced) - SUM(ScrapQuantity)) / CAST(SUM(TotalProduced) AS FLOAT)) * 100, 2)
        END AS Quality
    FROM 
        EquipmentData
    GROUP BY 
        MachineID
)
SELECT 
    MachineID,
    Availability,
    Performance,
    Quality,
    ROUND((Availability * Performance * Quality) / 10000, 2) AS TRS -- Division par 100^2 pour obtenir le % final
FROM 
    TRS_Calculation;
