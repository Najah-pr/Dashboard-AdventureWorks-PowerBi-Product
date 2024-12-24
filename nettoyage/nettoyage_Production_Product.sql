-- =============================================
-- Description: Script de nettoyage des données pour la table Production.Product
-- =============================================

-- 1. Supprimer les doublons potentiels
WITH DuplicateCheck AS (
    SELECT 
        ProductID,
        Name,
        SafetyStockLevel,
        ReorderPoint,
        StandardCost,
        ListPrice,
        DaysToManufacture,
        ProductLine,
        ROW_NUMBER() OVER (PARTITION BY Name ORDER BY ProductID) as RowNum
    FROM Production.Product
)
DELETE FROM DuplicateCheck WHERE RowNum > 1;

-- 2. Nettoyer les valeurs nulles ou invalides
UPDATE Production.Product
SET 
    Name = TRIM(Name),
    SafetyStockLevel = COALESCE(NULLIF(SafetyStockLevel, 0), 0),
    ReorderPoint = COALESCE(NULLIF(ReorderPoint, 0), 0),
    StandardCost = COALESCE(NULLIF(StandardCost, 0), 0),
    ListPrice = COALESCE(NULLIF(ListPrice, 0), 0),
    DaysToManufacture = COALESCE(NULLIF(DaysToManufacture, 0), 0),
    ProductLine = UPPER(TRIM(COALESCE(ProductLine, 'Other')))
WHERE ProductID IS NOT NULL;

-- 3. Vérifier la cohérence des prix
UPDATE Production.Product
SET ListPrice = CASE 
                    WHEN ListPrice < StandardCost THEN StandardCost * 1.1 
                    ELSE ListPrice 
                END
WHERE ProductID IS NOT NULL;

-- 4. Créer une table nettoyée avec les colonnes pertinentes
SELECT 
    ProductID,
    Name,
    SafetyStockLevel,
    ReorderPoint,
    StandardCost,
    ListPrice,
    DaysToManufacture,
    CASE ProductLine
        WHEN 'R' THEN 'Road'
        WHEN 'M' THEN 'Mountain'
        WHEN 'T' THEN 'Touring'
        WHEN 'S' THEN 'Sport'
        ELSE 'Other'
    END AS ProductLine
INTO Production.Product_Clean
FROM Production.Product
WHERE 
    Name IS NOT NULL
    AND SafetyStockLevel >= 0
    AND ReorderPoint >= 0
    AND StandardCost >= 0
    AND ListPrice >= 0
    AND DaysToManufacture >= 0;

-- 5. Ajouter des contraintes à la nouvelle table
ALTER TABLE Production.Product_Clean
ADD CONSTRAINT PK_Product_Clean PRIMARY KEY (ProductID);

ALTER TABLE Production.Product_Clean
ADD CONSTRAINT CHK_SafetyStock CHECK (SafetyStockLevel >= 0);

ALTER TABLE Production.Product_Clean
ADD CONSTRAINT CHK_ReorderPoint CHECK (ReorderPoint >= 0);

ALTER TABLE Production.Product_Clean
ADD CONSTRAINT CHK_Prices CHECK (ListPrice >= StandardCost);
