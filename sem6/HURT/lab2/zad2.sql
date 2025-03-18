-- Adventure Works 2022
-- Kolejne 5 zadań przedstawić w przy użyciu Tableau.

--1) Kartogram przedstawiający ilość zamówień w poszczególnych regionach (dane do wykresu poniżej:)
SELECT    
    ST.CountryRegionCode as "Region",
    COUNT(SOD.SalesOrderID) as "Orders"
FROM Production.Product PP
            JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
            JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
            JOIN Sales.SalesOrderDetail SOD ON PP.ProductID = SOD.ProductID
            JOIN Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
            JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID
            JOIN Sales.SalesTerritory ST ON C.TerritoryID = ST.TerritoryID
GROUP BY ST.CountryRegionCode
ORDER BY ST.CountryRegionCode

--2) Wykres liniowy przedstawiający ilość zamówień w poszczególnych latach
SELECT
    Year(S.OrderDate) as "Year",
    COUNT(S.SalesOrderID) as "Orders"
FROM Sales.SalesOrderHeader S
GROUP BY Year(S.OrderDate)
ORDER BY Year(S.OrderDate);

--3) Wykres kołowy przedstawiający ilość zamówień w poszczególnych kategoriach produktów
SELECT
    PC.Name as "Category",
    COUNT(SOD.SalesOrderID) as "Orders"
FROM Production.Product PP
            JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
            JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
            JOIN Sales.SalesOrderDetail SOD ON PP.ProductID = SOD.ProductID
            JOIN Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
            JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID
            JOIN Sales.SalesTerritory ST ON C.TerritoryID = ST.TerritoryID
GROUP BY PC.Name
ORDER BY PC.Name


--4) Wykres słupkowy przedstawiający ilość zamówień w poszczególnych miesiącach roku
SELECT
    Month(S.OrderDate) as "Month",
    COUNT(S.SalesOrderID) as "Orders"
FROM Sales.SalesOrderHeader S
GROUP BY Month(S.OrderDate)
ORDER BY Month(S.OrderDate)
    
--5) Wykres obrazujący wartość sprzedanych produktów ze względu na kategorie i podkategorie
SELECT
    PC.Name as "Category",
    PSC.Name as "Subcategory",
    SUM(SOD.LineTotal) as "Total"
FROM Production.Product PP
            JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
            JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
            JOIN Sales.SalesOrderDetail SOD ON PP.ProductID = SOD.ProductID
            JOIN Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
            JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID
            JOIN Sales.SalesTerritory ST ON C.TerritoryID = ST.TerritoryID
GROUP BY PC.Name, PSC.Name
ORDER BY PC.Name, PSC.Name

--6) to samo co 5 tylko ilość sprzedanych sztuk
SELECT
    PC.Name as "Category",
    PSC.Name as "Subcategory",
    SUM(SOD.OrderQty) as "Sold"
FROM Production.Product PP
            JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
            JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
            JOIN Sales.SalesOrderDetail SOD ON PP.ProductID = SOD.ProductID
            JOIN Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
            JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID
            JOIN Sales.SalesTerritory ST ON C.TerritoryID = ST.TerritoryID
GROUP BY PC.Name, PSC.Name
ORDER BY PC.Name, PSC.Name
