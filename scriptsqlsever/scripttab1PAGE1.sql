-- Afficher la production par date, ligne de production et quantité produite
SELECT 
    wo.StartDate AS ProductionDate,        -- Date de production
    p.ProductLine AS ProductionLine,       -- Ligne de production
    SUM(wo.OrderQty) AS QuantityProduced   -- Quantité produite
FROM 
    Production.WorkOrder wo                -- Table WorkOrder
JOIN 
    Production.Product p ON wo.ProductID = p.ProductID  -- Jointure avec la table Product
GROUP BY 
    wo.StartDate, p.ProductLine            -- Grouper par date et ligne de production
ORDER BY 
    ProductionDate ASC, ProductionLine ASC;  -- Trier par date et ligne de production
