SELECT 
    wo.ProductID,
    p.Name AS ProductName,
    SUM(wo.ScrappedQty) AS TotalRejectedQty, -- Total des rejets en production
    CASE 
        WHEN SUM(wo.OrderQty) = 0 THEN 0
        ELSE ROUND((CAST(SUM(wo.ScrappedQty) AS FLOAT) / SUM(wo.OrderQty)) * 100, 2)
    END AS RejectionRatePercentage, -- Taux de rejet (%)
    ISNULL(rc.TotalReturnedQty, 0) AS TotalReturnedQty -- Total des retours clients
FROM 
    Production.WorkOrder wo
INNER JOIN 
    Production.Product p ON wo.ProductID = p.ProductID
LEFT JOIN 
    (
        -- Sous-requête pour calculer les retours clients
        SELECT 
            ProductID,
            SUM(OrderQty) AS TotalReturnedQty
        FROM 
            Sales.SalesOrderDetail
        WHERE 
            SpecialOfferID = -1 -- Identifier les retours clients (ajuster si nécessaire)
        GROUP BY 
            ProductID
    ) rc ON wo.ProductID = rc.ProductID
GROUP BY 
    wo.ProductID, p.Name, rc.TotalReturnedQty
ORDER BY 
    TotalRejectedQty DESC;
