IF OBJECT_ID('Production.ProductCostHistory_Clean', 'U') IS NOT NULL
    DROP TABLE Production.ProductCostHistory_Clean;

-- 1. Cr�er la nouvelle table Production.ProductCostHistory_Clean
CREATE TABLE Production.ProductCostHistory_Clean (
    ProductID int NOT NULL,
    StartDate datetime NOT NULL,
    EndDate datetime NULL,
    StandardCost money NOT NULL,
    CONSTRAINT PK_ProductCostHistory_Clean PRIMARY KEY CLUSTERED (ProductID, StartDate)
);

-- 2. Ins�rer les donn�es avec correction des valeurs manquantes
WITH CorrectedData AS (
    SELECT 
        pch.ProductID,
        
        -- Remplacement des StartDate NULL par la premi�re date connue pour le produit
        COALESCE(pch.StartDate, 
            (SELECT MIN(StartDate) 
             FROM Production.ProductCostHistory 
             WHERE ProductID = pch.ProductID 
             AND StartDate IS NOT NULL)) AS StartDate,
        
        -- Remplacement des EndDate NULL par la StartDate de l'enregistrement suivant
        CASE 
            WHEN pch.EndDate IS NULL THEN 
                (SELECT MIN(StartDate)
                 FROM Production.ProductCostHistory 
                 WHERE ProductID = pch.ProductID 
                 AND StartDate > pch.StartDate)
            ELSE pch.EndDate 
        END AS EndDate,
        
        -- Remplacement des StandardCost NULL par la moyenne des co�ts pour le produit
        COALESCE(pch.StandardCost, 
            (SELECT AVG(StandardCost) 
             FROM Production.ProductCostHistory 
             WHERE ProductID = pch.ProductID 
             AND StandardCost IS NOT NULL)) AS StandardCost
    FROM Production.ProductCostHistory pch
    WHERE pch.StartDate IS NOT NULL  -- Filtrer les valeurs nulles de StartDate avant insertion
      AND pch.StandardCost IS NOT NULL -- Filtrer les valeurs nulles de StandardCost avant insertion
)

INSERT INTO Production.ProductCostHistory_Clean (ProductID, StartDate, EndDate, StandardCost)
SELECT ProductID, StartDate, EndDate, StandardCost
FROM CorrectedData
WHERE EndDate IS NOT NULL  -- Filtrer les valeurs nulles de EndDate avant insertion

-- 3. Ajouter la contrainte de cl� �trang�re
ALTER TABLE Production.ProductCostHistory_Clean
ADD CONSTRAINT FK_ProductCostHistory_Clean_Product 
FOREIGN KEY (ProductID) REFERENCES Production.Product(ProductID);

-- 4. Cr�er un index sur EndDate pour optimiser les requ�tes temporelles
CREATE INDEX IX_ProductCostHistory_Clean_EndDate
ON Production.ProductCostHistory_Clean (EndDate);

-- 5. Afficher un r�sum� des modifications et des valeurs qui ont �t� nettoy�es
SELECT 
    'Nombre total d''enregistrements' AS Description,
    COUNT(*) AS Valeur
FROM Production.ProductCostHistory_Clean
UNION ALL
SELECT 
    'Nombre de dates de fin corrig�es' AS Description,
    COUNT(*)
FROM Production.ProductCostHistory_Clean c
LEFT JOIN Production.ProductCostHistory o 
    ON c.ProductID = o.ProductID 
    AND c.StartDate = o.StartDate
WHERE o.EndDate IS NULL AND c.EndDate IS NOT NULL
UNION ALL
SELECT 
    'Nombre de co�ts corrig�s' AS Description,
    COUNT(*)
FROM Production.ProductCostHistory_Clean c
LEFT JOIN Production.ProductCostHistory o 
    ON c.ProductID = o.ProductID 
    AND c.StartDate = o.StartDate
WHERE o.StandardCost IS NULL AND c.StandardCost IS NOT NULL;

SELECT * FROM Production.ProductCostHistory_Clean;
