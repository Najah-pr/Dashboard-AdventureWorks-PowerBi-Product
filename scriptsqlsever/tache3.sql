-- Supprimer les doublons dans WorkOrder, ne garder que la ligne la plus récente
;WITH CTE AS (
    SELECT 
        WorkOrderID,    -- ID de l'ordre de travail
        ProductID,      -- ID du produit
        StartDate,      -- Date de début
        ModifiedDate,   -- Date de modification
        ROW_NUMBER() OVER (PARTITION BY ProductID, StartDate ORDER BY ModifiedDate DESC) AS rn
    FROM Production.WorkOrder
)
-- Supprimer les doublons dans WorkOrder en gardant la ligne la plus récente
DELETE FROM Production.WorkOrder
WHERE WorkOrderID IN (
    SELECT WorkOrderID
    FROM CTE
    WHERE rn > 1  -- Supprimer les doublons
);

-- Supprimer les doublons dans WorkOrderRouting où WorkOrderID correspond à des doublons dans WorkOrder
;WITH CTE AS (
    SELECT 
        WorkOrderID,  -- ID de l'ordre de travail
        ROW_NUMBER() OVER (PARTITION BY ProductID, StartDate ORDER BY ModifiedDate DESC) AS rn
    FROM Production.WorkOrder
)
-- Supprimer les références dans WorkOrderRouting pour les WorkOrderID avec rn > 1
DELETE FROM Production.WorkOrderRouting
WHERE WorkOrderID IN (
    SELECT WorkOrderID
    FROM CTE
    WHERE rn > 1  -- Sélectionner les doublons
);
-- Modifier la contrainte de clé étrangère pour ajouter la suppression en cascade
ALTER TABLE Production.WorkOrderRouting
DROP CONSTRAINT FK_WorkOrderRouting_WorkOrder_WorkOrderID;

ALTER TABLE Production.WorkOrderRouting
ADD CONSTRAINT FK_WorkOrderRouting_WorkOrder_WorkOrderID
FOREIGN KEY (WorkOrderID)
REFERENCES Production.WorkOrder(WorkOrderID)
ON DELETE CASCADE;
-- Calcul du taux de rendement par ligne avec les tables 'WorkOrder' et 'Product' sous le schéma 'Production'
SELECT 
    wo.WorkOrderID,      -- ID de l'ordre de travail
    wo.ProductID,        -- ID du produit
    wo.OrderQty,         -- Quantité totale commandée
    wo.StockedQty,       -- Quantité produite et stockée
    wo.ScrappedQty,      -- Quantité mise au rebut
    -- Calcul du taux de rendement en pourcentage
    CASE 
        WHEN (wo.OrderQty - wo.ScrappedQty) > 0 THEN (wo.StockedQty * 1.0 / (wo.OrderQty - wo.ScrappedQty)) * 100
        ELSE 0  -- Si la différence entre OrderQty et ScrappedQty est 0 ou négative, le rendement est défini à 0
    END AS RendementPercentage
FROM 
    Production.WorkOrder wo  -- Table WorkOrder sous le schéma 'Production'
JOIN 
    Production.Product p ON wo.ProductID = p.ProductID  -- Table Product sous le schéma 'Production'
WHERE 
    wo.OrderQty > 0 AND (wo.OrderQty - wo.ScrappedQty) > 0  -- Exclure les ordres avec des quantités invalides
ORDER BY 
    RendementPercentage DESC;  -- Trier par taux de rendement décroissant
