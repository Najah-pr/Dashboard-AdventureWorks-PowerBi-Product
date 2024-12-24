-- Vérifier les enregistrements avec des valeurs manquantes pour OrderQty, ScrappedQty ou StartDate
SELECT *
FROM Production.WorkOrder
WHERE OrderQty IS NULL OR ScrappedQty IS NULL OR StartDate IS NULL;
-- Mettre à jour les valeurs nulles pour OrderQty et ScrappedQty
UPDATE Production.WorkOrder
SET OrderQty = 0
WHERE OrderQty IS NULL;

UPDATE Production.WorkOrder
SET ScrappedQty = 0
WHERE ScrappedQty IS NULL;

UPDATE Production.WorkOrder
SET StartDate = '1900-01-01'  -- Remplacer les dates manquantes par une valeur par défaut (à ajuster selon vos besoins)
WHERE StartDate IS NULL;
-- Vérifier les enregistrements avec des valeurs négatives pour OrderQty ou ScrappedQty
SELECT *
FROM Production.WorkOrder
WHERE OrderQty < 0 OR ScrappedQty < 0;
-- Mettre à jour les valeurs négatives pour OrderQty et ScrappedQty
UPDATE Production.WorkOrder
SET OrderQty = 0
WHERE OrderQty < 0;

UPDATE Production.WorkOrder
SET ScrappedQty = 0
WHERE ScrappedQty < 0;
-- Volume de produit par mois avec les tables 'WorkOrder' et 'Product' sous le schéma 'Production'
SELECT 
    YEAR(wo.StartDate) AS Year,  -- Extraire l'année de la colonne StartDate
    MONTH(wo.StartDate) AS Month,  -- Extraire le mois de la colonne StartDate
    SUM(wo.OrderQty) AS TotalVolume  -- Calculer le volume total des produits produits
FROM 
    Production.WorkOrder wo  -- Table WorkOrder sous le schéma 'Production'
JOIN 
    Production.Product p ON wo.ProductID = p.ProductID  -- Table Product sous le schéma 'Production'
GROUP BY 
    YEAR(wo.StartDate), MONTH(wo.StartDate)  -- Regrouper les résultats par année et mois
ORDER BY 
    Year DESC, Month DESC;  -- Trier les résultats par année et mois (du plus récent au plus ancien)
-- Volume de produit par trimestre avec les tables 'WorkOrder' et 'Product' sous le schéma 'Production'
SELECT 
    YEAR(wo.StartDate) AS Year,  -- Extraire l'année de la colonne StartDate
    DATEPART(QUARTER, wo.StartDate) AS Quarter,  -- Extraire le trimestre de la colonne StartDate
    SUM(wo.OrderQty) AS TotalVolume  -- Calculer le volume total des produits produits
FROM 
    Production.WorkOrder wo  -- Table WorkOrder sous le schéma 'Production'
JOIN 
    Production.Product p ON wo.ProductID = p.ProductID  -- Table Product sous le schéma 'Production'
GROUP BY 
    YEAR(wo.StartDate), DATEPART(QUARTER, wo.StartDate)  -- Regrouper les résultats par année et trimestre
ORDER BY 
    Year DESC, Quarter DESC;  -- Trier les résultats par année et trimestre (du plus récent au plus ancien)

