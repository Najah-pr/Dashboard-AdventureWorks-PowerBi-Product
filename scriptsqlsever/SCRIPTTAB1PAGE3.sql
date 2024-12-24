SELECT 
    wo.ProductID,
    p.Name AS ProductName,
    SUM(wo.ScrappedQty) AS TotalScrappedQty,
    SUM(wo.OrderQty) AS TotalProducedQty,
    CASE 
        WHEN SUM(wo.OrderQty) = 0 THEN 0
        ELSE ROUND((CAST(SUM(wo.ScrappedQty) AS FLOAT) / SUM(wo.OrderQty)) * 100, 2)
    END AS ScrapRatePercentage
FROM 
    Production.WorkOrder wo
INNER JOIN 
    Production.Product p ON wo.ProductID = p.ProductID
LEFT JOIN 
    Production.ScrapReason sr ON wo.ScrapReasonID = sr.ScrapReasonID
GROUP BY 
    wo.ProductID, p.Name
ORDER BY 
    ScrapRatePercentage DESC;
