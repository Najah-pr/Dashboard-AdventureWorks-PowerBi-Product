SELECT 
    pch.ProductID,
    p.Name AS ProductName,
    pch.StartDate AS CostStartDate,
    pch.StandardCost AS UnitCost,  -- Remplacé 'UnitCost' par 'StandardCost'
    SUM(wo.OrderQty) AS TotalProducedQty,
    CASE 
        WHEN SUM(wo.OrderQty) = 0 THEN 0
        ELSE ROUND(SUM(wo.OrderQty) * pch.StandardCost / SUM(wo.OrderQty), 2)
    END AS CostPerUnitProduced
FROM 
    Production.ProductCostHistory pch
INNER JOIN 
    Production.Product p ON pch.ProductID = p.ProductID
INNER JOIN 
    Production.WorkOrder wo ON wo.ProductID = pch.ProductID
GROUP BY 
    pch.ProductID, p.Name, pch.StartDate, pch.StandardCost
ORDER BY 
    CostPerUnitProduced DESC;
