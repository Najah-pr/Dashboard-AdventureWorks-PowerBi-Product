-- V�rification initiale des donn�es
-- Identifier les valeurs nulles, vides ou incoh�rentes

SELECT *
FROM Production.WorkOrder
WHERE WorkOrderID IS NULL
   OR ProductID IS NULL
   OR OrderQty IS NULL
   OR StartDate IS NULL
   OR EndDate IS NULL
   OR DATEDIFF(DAY, StartDate, EndDate) < 0; -- V�rifie si EndDate est avant StartDate

-- V�rification des doublons bas�s sur WorkOrderID
SELECT WorkOrderID, COUNT(*) AS Count
FROM Production.WorkOrder
GROUP BY WorkOrderID
HAVING COUNT(*) > 1;

-- Suppression des doublons
-- Conserver uniquement la premi�re occurrence des doublons
WITH CTE_Duplicates AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY WorkOrderID ORDER BY ModifiedDate DESC) AS RowNum
    FROM Production.WorkOrder
)
DELETE FROM CTE_Duplicates
WHERE RowNum > 1;

-- Suppression des enregistrements invalides
DELETE FROM Production.WorkOrder
WHERE WorkOrderID IS NULL
   OR ProductID IS NULL
   OR OrderQty IS NULL
   OR StartDate IS NULL
   OR EndDate IS NULL
   OR DATEDIFF(DAY, StartDate, EndDate) < 0;

-- Identifier la contrainte par d�faut sur ModifiedDate (si elle existe)
-- V�rifier les colonnes existantes dans la table
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'WorkOrder';

-- Suppression des contraintes li�es aux colonnes inutiles, si n�cessaire
SELECT name
FROM sys.default_constraints
WHERE parent_object_id = OBJECT_ID('Production.WorkOrder')
  AND parent_column_id = (
      SELECT column_id
      FROM sys.columns
      WHERE name = 'ModifiedDate'
        AND object_id = OBJECT_ID('Production.WorkOrder')
  );

-- Supprimer la contrainte associ�e (exemple pour 'ModifiedDate')
ALTER TABLE Production.WorkOrder
DROP CONSTRAINT DF_WorkOrder_ModifiedDate;

-- Suppression des colonnes inutiles, en conservant celles n�cessaires pour les calculs
-- Colonnes n�cessaires : ProductID, StartDate, EndDate, StockedQty, ScrappedQtyS
ALTER TABLE Production.WorkOrder
DROP COLUMN ModifiedDate, DueDate,ScrapReasonID; -- Ajouter ici les colonnes jug�es inutiles

-- V�rification apr�s suppression des colonnes
SELECT *
FROM Production.WorkOrder;
