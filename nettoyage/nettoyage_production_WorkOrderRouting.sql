 /*** nettoyage de WorkOrderRouting ***/

-- V�rifier la structure de la table
-- V�rification des contraintes associ�es aux colonnes avant suppression

SELECT name
FROM sys.default_constraints
WHERE parent_object_id = OBJECT_ID('Production.WorkOrderRouting')
AND parent_column_id = (
    SELECT column_id
    FROM sys.columns
    WHERE name = 'ModifiedDate'
    AND object_id = OBJECT_ID('Production.WorkOrderRouting')
);
ALTER TABLE Production.WorkOrderRouting
DROP CONSTRAINT DF_WorkOrderRouting_ModifiedDate;

-- Suppression des colonnes inutiles
ALTER TABLE Production.WorkOrderRouting
DROP COLUMN ModifiedDate;

-- V�rification des donn�es manquantes ou incorrectes
-- V�rification des NULL ou des donn�es invalides dans les colonnes cl�s
SELECT *
FROM Production.WorkOrderRouting
WHERE WorkOrderID IS NULL
   OR ProductID IS NULL
   OR OperationSequence IS NULL
   OR ActualResourceHrs IS NULL OR ActualResourceHrs <= 0  -- V�rifie que les heures r�elles ne sont pas n�gatives ou nulles
   OR LocationID IS NULL;

-- V�rification des doublons
-- Rechercher les doublons potentiels bas�s sur les colonnes cl�s
SELECT WorkOrderID, ProductID, LocationID, COUNT(*) AS DuplicateCount
FROM Production.WorkOrderRouting
GROUP BY WorkOrderID, ProductID, LocationID
HAVING COUNT(*) > 1;

-- Suppression des doublons (en conservant une seule occurrence)
WITH CTE AS (
    SELECT *,
           ROW_NUMBER() OVER (PARTITION BY WorkOrderID, ProductID, LocationID ORDER BY ActualStartDate) AS RowNum
    FROM Production.WorkOrderRouting
)
DELETE FROM CTE
WHERE RowNum > 1;

-- V�rifier l'int�grit� des relations
SELECT wr.WorkOrderID
FROM Production.WorkOrderRouting wr
LEFT JOIN Production.WorkOrder wo
    ON wr.WorkOrderID = wo.WorkOrderID
WHERE wo.WorkOrderID IS NULL;

-- Supprimer les enregistrements sans correspondance dans la table `Production.WorkOrder`
DELETE FROM Production.WorkOrderRouting
WHERE WorkOrderID NOT IN (SELECT WorkOrderID FROM Production.WorkOrder);

-- Revalidation finale
SELECT * 
FROM Production.WorkOrderRouting;
