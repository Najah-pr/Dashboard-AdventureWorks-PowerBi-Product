-- Vérifier les données avec des valeurs invalides dans ScrappedQty
SELECT * 
FROM Production.WorkOrder  
WHERE ScrappedQty < 0 OR ScrappedQty IS NULL;
-- Nettoyer les valeurs invalides dans ScrappedQty
UPDATE Production.WorkOrder
SET ScrappedQty = 0
WHERE ScrappedQty < 0 OR ScrappedQty IS NULL;
-- Calcul des produits mis au rebut par catégorie, en excluant les ScrapReasonID NULL
SELECT 
    pc.Name AS CategoryName, 
    COALESCE(SUM(wo.ScrappedQty), 0) AS TotalScrapped  -- Utiliser COALESCE pour inclure les catégories sans ScrapQty
FROM 
    Production.ProductCategory pc  -- Table ProductCategory sous le schéma 'Production'
LEFT JOIN 
    Production.ProductSubcategory ps ON pc.ProductCategoryID = ps.ProductCategoryID  -- Table ProductSubcategory sous le schéma 'Production'
LEFT JOIN 
    Production.Product p ON ps.ProductSubcategoryID = p.ProductSubcategoryID  -- Table Product sous le schéma 'Production'
LEFT JOIN 
    Production.WorkOrder wo ON p.ProductID = wo.ProductID  -- Table WorkOrder sous le schéma 'Production'
WHERE
    wo.ScrapReasonID IS NOT NULL  -- Exclure les enregistrements où ScrapReasonID est NULL
GROUP BY 
    pc.Name
ORDER BY 
    TotalScrapped DESC;
-- Calcul des produits mis au rebut par catégorie, incluant toutes les catégories même sans produits mis au rebut
SELECT 
    pc.Name AS CategoryName, 
    COALESCE(SUM(wo.ScrappedQty), 0) AS TotalScrapped  -- Remplacer NULL par 0 pour les catégories sans scrap
FROM 
    Production.ProductCategory pc  -- Table ProductCategory sous le schéma 'Production'
LEFT JOIN 
    Production.ProductSubcategory ps ON pc.ProductCategoryID = ps.ProductCategoryID  -- Table ProductSubcategory
LEFT JOIN 
    Production.Product p ON ps.ProductSubcategoryID = p.ProductSubcategoryID  -- Table Product
LEFT JOIN 
    Production.WorkOrder wo ON p.ProductID = wo.ProductID  -- Table WorkOrder
GROUP BY 
    pc.Name  -- Groupement par nom de catégorie
ORDER BY 
    TotalScrapped DESC;  -- Trier par le total de produits mis au rebut en ordre décroissant






