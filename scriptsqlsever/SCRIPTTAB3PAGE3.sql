SELECT 
    wo.ProductID,
    p.Name AS ProductName,
    SUM(wo.OrderQty) AS TotalProducedQty,
    SUM(wo.ScrappedQty) AS TotalScrappedQty,
    CASE 
        WHEN SUM(wo.OrderQty) = 0 THEN 0
        ELSE ROUND(((SUM(wo.OrderQty) - SUM(wo.ScrappedQty)) / CAST(SUM(wo.OrderQty) AS FLOAT)) * 100, 2)
    END AS FirstPassYieldPercentage
FROM 
    Production.WorkOrder wo
INNER JOIN 
    Production.Product p ON wo.ProductID = p.ProductID
LEFT JOIN 
    Production.ScrapReason sr ON wo.ScrapReasonID = sr.ScrapReasonID
GROUP BY 
    wo.ProductID, p.Name
ORDER BY 
    FirstPassYieldPercentage DESC;
