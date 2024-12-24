-- Afficher le nombre de produits par cat�gorie
SELECT 
    pc.Name AS Cat�gorie,          -- Nom de la cat�gorie
    COUNT(p.ProductID) AS nombredeproduit  -- Nombre total de produits dans cette cat�gorie
FROM 
    Production.Product p  -- Table des produits
JOIN 
    Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID  -- Jointure avec les sous-cat�gories
JOIN 
    Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID  -- Jointure avec les cat�gories
GROUP BY 
    pc.Name  -- Grouper par cat�gorie
ORDER BY 
    nombredeproduit DESC;  -- Trier par nombre de produits (descendant)
