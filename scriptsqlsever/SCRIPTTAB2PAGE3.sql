SELECT 
    pch.ProductID,
    p.Name AS ProductName,
    pch.StartDate AS CostStartDate,
    pch.StandardCost AS UnitCost
FROM 
    Production.ProductCostHistory pch
INNER JOIN 
    Production.Product p ON pch.ProductID = p.ProductID
WHERE 
    pch.StandardCost IS NOT NULL -- Filtrer uniquement les coûts définis
ORDER BY 
    pch.ProductID, pch.StartDate;
