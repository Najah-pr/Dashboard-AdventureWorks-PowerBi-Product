WITH WorkOrderFailures AS (
    SELECT 
        wo.WorkOrderID,
        wo.ProductID,
        DATEDIFF(MINUTE, wo.StartDate, wo.EndDate) AS OperatingTimeMinutes,
        wo.ScrappedQty,
        sr.Name AS ScrapReason
    FROM 
        Production.WorkOrder wo
    LEFT JOIN 
        Production.ScrapReason sr ON wo.ScrapReasonID = sr.ScrapReasonID
    WHERE 
        wo.ScrappedQty > 0 -- Filtrer uniquement les ordres de travail avec défaillances
),
MTBF_Calculation AS (
    SELECT 
        SUM(OperatingTimeMinutes) AS TotalOperatingTimeMinutes,
        COUNT(WorkOrderID) AS TotalFailures
    FROM 
        WorkOrderFailures
)
SELECT 
    CASE 
        WHEN TotalFailures = 0 THEN NULL -- Éviter la division par zéro
        ELSE ROUND(CAST(TotalOperatingTimeMinutes AS FLOAT) / TotalFailures, 2)
    END AS MTBF_Minutes
FROM 
    MTBF_Calculation;
