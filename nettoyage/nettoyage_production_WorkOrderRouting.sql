-- =============================================
-- Description: Script de nettoyage des données pour la table Production.WorkOrderRouting
-- =============================================

-- Création d'une table nettoyée à partir de Production.WorkOrderRouting
SELECT WorkOrderID, ProductID, OperationSequence, ActualResourceHrs, LocationID, ActualStartDate
INTO Production.WorkOrderRouting_Clean
FROM Production.WorkOrderRouting;

-- Suppression de la contrainte DF_WorkOrderRouting_ModifiedDate (si elle existe)
IF EXISTS (SELECT 1
           FROM sys.default_constraints
           WHERE parent_object_id = OBJECT_ID('Production.WorkOrderRouting')
             AND parent_column_id = (SELECT column_id
                                      FROM sys.columns
                                      WHERE name = 'ModifiedDate'
                                        AND object_id = OBJECT_ID('Production.WorkOrderRouting')))
BEGIN
    ALTER TABLE Production.WorkOrderRouting
    DROP CONSTRAINT DF_WorkOrderRouting_ModifiedDate;
END

-- Suppression de la colonne ModifiedDate de la table originale
ALTER TABLE Production.WorkOrderRouting
DROP COLUMN ModifiedDate;

-- Suppression des enregistrements invalides dans la table nettoyée (WorkOrderRouting_Clean)
DELETE FROM Production.WorkOrderRouting_Clean
WHERE WorkOrderID IS NULL
   OR ProductID IS NULL
   OR OperationSequence IS NULL
   OR ActualResourceHrs IS NULL
   OR ActualResourceHrs <= 0  -- Vérifie que les heures réelles ne sont pas négatives ou nulles
   OR LocationID IS NULL;

-- Vérification des doublons dans la table nettoyée (WorkOrderRouting_Clean) 
WITH CTE_Duplicates AS (
    SELECT *, 
           ROW_NUMBER() OVER (PARTITION BY WorkOrderID, ProductID, LocationID ORDER BY ActualStartDate) AS RowNum
    FROM Production.WorkOrderRouting_Clean
)
DELETE FROM CTE_Duplicates
WHERE RowNum > 1;

-- Vérification de l'intégrité des relations avec la table WorkOrder
DELETE FROM Production.WorkOrderRouting_Clean
WHERE WorkOrderID NOT IN (SELECT WorkOrderID FROM Production.WorkOrder);

-- Vérification finale du contenu de la table nettoyée
SELECT * 
FROM Production.WorkOrderRouting_Clean;
