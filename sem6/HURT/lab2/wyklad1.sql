SET STATISTICS IO, TIME ON;


-- NO CTE
SELECT TOP 20
    p.Name AS ProductName,
        pc.Name AS CategoryName,
       SUM(sod.OrderQty) AS TotalSold
FROM Sales.SalesOrderDetail sod
         JOIN Production.Product p ON sod.ProductID = p.ProductID
         JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
         JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
GROUP BY p.Name, pc.Name
ORDER BY TotalSold DESC;



-- CTE
WITH ProductSales AS (
    SELECT
        sod.ProductID,
        SUM(sod.OrderQty) AS TotalSold
    FROM Sales.SalesOrderDetail sod
    GROUP BY sod.ProductID
)
SELECT TOP 20
    p.Name AS ProductName,
        pc.Name AS CategoryName,
       ps.TotalSold
FROM ProductSales ps
         JOIN Production.Product p ON ps.ProductID = p.ProductID
         JOIN Production.ProductSubcategory psc ON p.ProductSubcategoryID = psc.ProductSubcategoryID
         JOIN Production.ProductCategory pc ON psc.ProductCategoryID = pc.ProductCategoryID
ORDER BY ps.TotalSold DESC;
