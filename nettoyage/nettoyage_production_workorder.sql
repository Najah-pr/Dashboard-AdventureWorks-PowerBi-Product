-- =============================================
-- Description: Script de nettoyage des données pour la table Production.WorkOrder
-- =============================================
-- Création d'une nouvelle table de nettoyage sans les colonnes inutiles
SELECT WorkOrderID, ProductID, OrderQty, StartDate, EndDate, StockedQty, ScrappedQty
INTO Production.WorkOrder_Clean
FROM Production.WorkOrder;

-- Vérification et suppression des enregistrements invalides dans WorkOrder_Clean
DELETE FROM Production.WorkOrder_Clean
WHERE WorkOrderID IS NULL
   OR ProductID IS NULL
   OR OrderQty IS NULL
   OR StartDate IS NULL
   OR EndDate IS NULL
   OR DATEDIFF(DAY, StartDate, EndDate) < 0;

-- Suppression des doublons dans WorkOrder_Clean, en conservant la première occurrence
WITH CTE_Duplicates AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY WorkOrderID ORDER BY StartDate DESC) AS RowNum
    FROM Production.WorkOrder_Clean
)
DELETE FROM CTE_Duplicates WHERE RowNum > 1;

-- Calcul du pourcentage de valeurs nulles pour chaque colonne (hors colonnes inutiles)
DECLARE @sql NVARCHAR(MAX) = '';
DECLARE @columnName NVARCHAR(128);
DECLARE @tableName NVARCHAR(128) = 'Production.WorkOrder_Clean';

DECLARE column_cursor CURSOR FOR
SELECT COLUMN_NAME
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'WorkOrder_Clean' AND TABLE_SCHEMA = 'Production'
  AND COLUMN_NAME NOT IN ('ScrapReasonID', 'ModifiedDate'); -- Exclure ScrapReasonID et ModifiedDate

OPEN column_cursor;
FETCH NEXT FROM column_cursor INTO @columnName;

-- Génération de la requête dynamique pour le calcul du pourcentage de valeurs nulles
WHILE @@FETCH_STATUS = 0
BEGIN
    SET @sql = @sql + 
    'SELECT ''' + @columnName + ''' AS ColumnName, ' +
    '       SUM(CASE WHEN ' + QUOTENAME(@columnName) + ' IS NULL THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS NullPercentage ' +
    'FROM ' + @tableName + ' ' +
    'UNION ALL ';
    FETCH NEXT FROM column_cursor INTO @columnName;
END

CLOSE column_cursor;
DEALLOCATE column_cursor;

-- Exécution de la requête dynamique pour obtenir le pourcentage de nulls
SET @sql = LEFT(@sql, LEN(@sql) - 10); -- Supprime le dernier UNION ALL
EXEC sp_executesql @sql;

-- Vérification finale du contenu de la table WorkOrder_Clean après nettoyage
SELECT *
FROM Production.WorkOrder_Clean;
