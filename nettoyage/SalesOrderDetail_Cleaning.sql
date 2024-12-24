-- =============================================
-- Description: Script de nettoyage des donn�es pour la table Sales.SalesOrderDetail
-- =============================================
IF OBJECT_ID('Sales.SalesOrderDetail_Clean', 'U') IS NOT NULL
    DROP TABLE Sales.SalesOrderDetail_Clean;

-- 1. Cr�er une copie propre de la table SalesOrderDetail
SELECT SalesOrderID, SalesOrderDetailID, OrderQty, LineTotal, UnitPrice,UnitPriceDiscount, 
       ProductID, SpecialOfferID
INTO Sales.SalesOrderDetail_Clean
FROM Sales.SalesOrderDetail;

BEGIN TRANSACTION;

-- Remplacer les valeurs NULL par des valeurs par d�faut
UPDATE Sales.SalesOrderDetail_Clean
SET OrderQty = 0
WHERE OrderQty IS NULL;

UPDATE Sales.SalesOrderDetail_Clean
SET LineTotal = 0
WHERE LineTotal IS NULL;

UPDATE Sales.SalesOrderDetail_Clean
SET UnitPrice = 0
WHERE UnitPrice IS NULL;

-- Supprimer les lignes avec des valeurs incorrectes (n�gatives)
DELETE FROM Sales.SalesOrderDetail_Clean
WHERE OrderQty < 0 OR LineTotal < 0 OR UnitPrice < 0;

-- Suppression des doublons
WITH CTE_Duplicates AS (
    SELECT *, ROW_NUMBER() OVER (PARTITION BY SalesOrderID, SalesOrderDetailID ORDER BY SalesOrderDetailID DESC) AS RowNum
    FROM Sales.SalesOrderDetail_Clean
)
DELETE FROM CTE_Duplicates
WHERE RowNum > 1;

-- Validation des actions (V�rification des anomalies restantes)
SELECT SalesOrderID, SalesOrderDetailID, OrderQty, LineTotal, UnitPrice
FROM Sales.SalesOrderDetail_Clean
WHERE OrderQty < 0 OR LineTotal < 0 OR UnitPrice < 0;

-- Committer la transaction
COMMIT;

-- Afficher les donn�es de la table nettoy�e
SELECT * FROM Sales.SalesOrderDetail_Clean;
