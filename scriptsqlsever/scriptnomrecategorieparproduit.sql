-- Afficher le nombre de produits par catégorie
SELECT 
    pc.Name AS Catégorie,          -- Nom de la catégorie
    COUNT(p.ProductID) AS nombredeproduit  -- Nombre total de produits dans cette catégorie
FROM 
    Production.Product p  -- Table des produits
JOIN 
    Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID  -- Jointure avec les sous-catégories
JOIN 
    Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID  -- Jointure avec les catégories
GROUP BY 
    pc.Name  -- Grouper par catégorie
ORDER BY 
    nombredeproduit DESC;  -- Trier par nombre de produits (descendant)
