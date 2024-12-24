-- =============================================
-- Description: Script de nettoyage des données pour la table Production.ScrapReason
-- =============================================

-- 1. Créer une table nettoyée avec les informations essentielles
SELECT 
    ScrapReasonID,
    Name AS ScrapReasonName
INTO Production.ScrapReason_Clean
FROM 
    Production.ScrapReason
WHERE 
    Name IS NOT NULL;

-- 2. Vérifier la structure de la table Production.ScrapReason_Clean
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ScrapReason_Clean';

-- 3. Traiter les données dans la table nettoyée (ScrapReason_Clean)
-- Nettoyer les valeurs nulles et les espaces inutiles
UPDATE Production.ScrapReason_Clean
SET 
    ScrapReasonName = TRIM(REPLACE(REPLACE(ScrapReasonName, CHAR(9), ' '), CHAR(160), ' '))
WHERE 
    ScrapReasonName IS NOT NULL;

-- 4. Normaliser la casse des raisons de mise au rebut
UPDATE Production.ScrapReason_Clean
SET 
    ScrapReasonName = UPPER(LEFT(ScrapReasonName, 1)) + LOWER(SUBSTRING(ScrapReasonName, 2, LEN(ScrapReasonName)))
WHERE 
    ScrapReasonName IS NOT NULL;

-- 5. Vérifier les doublons et supprimer les doublons dans la table nettoyée
WITH DuplicateCheck AS (
    SELECT 
        ScrapReasonID,
        ScrapReasonName,
        ROW_NUMBER() OVER (PARTITION BY ScrapReasonName ORDER BY ScrapReasonID) as RowNum
    FROM Production.ScrapReason_Clean
)
DELETE FROM DuplicateCheck WHERE RowNum > 1;

-- 6. Ajouter des contraintes pour garantir l'intégrité des données
ALTER TABLE Production.ScrapReason_Clean
ADD CONSTRAINT PK_ScrapReason_Clean PRIMARY KEY (ScrapReasonID);

ALTER TABLE Production.ScrapReason_Clean
ADD CONSTRAINT CHK_ScrapReasonName CHECK (LEN(ScrapReasonName) > 0);

-- 7. Ajouter un index pour améliorer les performances des recherches
CREATE INDEX IX_ScrapReason_Clean_Name 
ON Production.ScrapReason_Clean(ScrapReasonName);

-- 8. Vérification finale des données nettoyées
SELECT * 
FROM Production.ScrapReason_Clean;
