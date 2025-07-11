SELECT * FROM
(
SELECT
    PC.Name as "Category",
    ST.CountryRegionCode as "Region",
    SUM(SOD.OrderQty) as "Sold"
FROM Production.Product PP
    JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
    JOIN Sales.SalesOrderDetail SOD ON PP.ProductID = SOD.ProductID
    JOIN Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
    JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID
    JOIN Sales.SalesTerritory ST ON C.TerritoryID = ST.TerritoryID
GROUP BY PC.Name, ST.CountryRegionCode
) AS SourceTable
PIVOT
(
SUM(Sold)
FOR Region IN ([AU], [CA], [DE], [FR], [GB], [JP], [US])
) AS PivotTable
ORDER BY Category
