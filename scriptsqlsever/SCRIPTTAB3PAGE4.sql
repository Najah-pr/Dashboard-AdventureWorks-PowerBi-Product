SELECT 
    so.SalesOrderID,
    so.OrderQty AS OrderQuantity,
    wo.WorkOrderID,
    wo.DueDate AS DeliveryDueDate,
    wo.EndDate AS ActualDeliveryDate,
    CASE
        WHEN wo.EndDate <= wo.DueDate THEN 1  -- Commande livrée à temps
        ELSE 0  -- Commande en retard
    END AS DeliveredOnTime
FROM 
    Sales.SalesOrderDetail so
INNER JOIN 
    Production.WorkOrder wo ON so.ProductID = wo.ProductID  -- Jointure basée sur ProductID
ORDER BY 
    so.SalesOrderID;
