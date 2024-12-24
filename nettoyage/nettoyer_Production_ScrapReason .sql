-- =============================================
-- Description: Script de nettoyage des donn�es pour la table Production.ScrapReason
-- =============================================

-- 1. Cr�er une table nettoy�e avec les informations essentielles
SELECT 
    ScrapReasonID,
    Name AS ScrapReasonName
INTO Production.ScrapReason_Clean
FROM 
    Production.ScrapReason
WHERE 
    Name IS NOT NULL;

-- 2. V�rifier la structure de la table Production.ScrapReason_Clean
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'ScrapReason_Clean';

-- 3. Traiter les donn�es dans la table nettoy�e (ScrapReason_Clean)
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

-- 5. V�rifier les doublons et supprimer les doublons dans la table nettoy�e
WITH DuplicateCheck AS (
    SELECT 
        ScrapReasonID,
        ScrapReasonName,
        ROW_NUMBER() OVER (PARTITION BY ScrapReasonName ORDER BY ScrapReasonID) as RowNum
    FROM Production.ScrapReason_Clean
)
DELETE FROM DuplicateCheck WHERE RowNum > 1;

-- 6. Ajouter des contraintes pour garantir l'int�grit� des donn�es
ALTER TABLE Production.ScrapReason_Clean
ADD CONSTRAINT PK_ScrapReason_Clean PRIMARY KEY (ScrapReasonID);

ALTER TABLE Production.ScrapReason_Clean
ADD CONSTRAINT CHK_ScrapReasonName CHECK (LEN(ScrapReasonName) > 0);

-- 7. Ajouter un index pour am�liorer les performances des recherches
CREATE INDEX IX_ScrapReason_Clean_Name 
ON Production.ScrapReason_Clean(ScrapReasonName);

-- 8. V�rification finale des donn�es nettoy�es
SELECT * 
FROM Production.ScrapReason_Clean;
