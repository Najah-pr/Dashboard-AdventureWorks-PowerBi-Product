-- V�rifier les enregistrements avec des valeurs manquantes pour OrderQty, ScrappedQty ou StartDate
SELECT *
FROM Production.WorkOrder
WHERE OrderQty IS NULL OR ScrappedQty IS NULL OR StartDate IS NULL;
-- Mettre � jour les valeurs nulles pour OrderQty et ScrappedQty
UPDATE Production.WorkOrder
SET OrderQty = 0
WHERE OrderQty IS NULL;

UPDATE Production.WorkOrder
SET ScrappedQty = 0
WHERE ScrappedQty IS NULL;

UPDATE Production.WorkOrder
SET StartDate = '1900-01-01'  -- Remplacer les dates manquantes par une valeur par d�faut (� ajuster selon vos besoins)
WHERE StartDate IS NULL;
-- V�rifier les enregistrements avec des valeurs n�gatives pour OrderQty ou ScrappedQty
SELECT *
FROM Production.WorkOrder
WHERE OrderQty < 0 OR ScrappedQty < 0;
-- Mettre � jour les valeurs n�gatives pour OrderQty et ScrappedQty
UPDATE Production.WorkOrder
SET OrderQty = 0
WHERE OrderQty < 0;

UPDATE Production.WorkOrder
SET ScrappedQty = 0
WHERE ScrappedQty < 0;
-- Volume de produit par mois avec les tables 'WorkOrder' et 'Product' sous le sch�ma 'Production'
SELECT 
    YEAR(wo.StartDate) AS Year,  -- Extraire l'ann�e de la colonne StartDate
    MONTH(wo.StartDate) AS Month,  -- Extraire le mois de la colonne StartDate
    SUM(wo.OrderQty) AS TotalVolume  -- Calculer le volume total des produits produits
FROM 
    Production.WorkOrder wo  -- Table WorkOrder sous le sch�ma 'Production'
JOIN 
    Production.Product p ON wo.ProductID = p.ProductID  -- Table Product sous le sch�ma 'Production'
GROUP BY 
    YEAR(wo.StartDate), MONTH(wo.StartDate)  -- Regrouper les r�sultats par ann�e et mois
ORDER BY 
    Year DESC, Month DESC;  -- Trier les r�sultats par ann�e et mois (du plus r�cent au plus ancien)
-- Volume de produit par trimestre avec les tables 'WorkOrder' et 'Product' sous le sch�ma 'Production'
SELECT 
    YEAR(wo.StartDate) AS Year,  -- Extraire l'ann�e de la colonne StartDate
    DATEPART(QUARTER, wo.StartDate) AS Quarter,  -- Extraire le trimestre de la colonne StartDate
    SUM(wo.OrderQty) AS TotalVolume  -- Calculer le volume total des produits produits
FROM 
    Production.WorkOrder wo  -- Table WorkOrder sous le sch�ma 'Production'
JOIN 
    Production.Product p ON wo.ProductID = p.ProductID  -- Table Product sous le sch�ma 'Production'
GROUP BY 
    YEAR(wo.StartDate), DATEPART(QUARTER, wo.StartDate)  -- Regrouper les r�sultats par ann�e et trimestre
ORDER BY 
    Year DESC, Quarter DESC;  -- Trier les r�sultats par ann�e et trimestre (du plus r�cent au plus ancien)

