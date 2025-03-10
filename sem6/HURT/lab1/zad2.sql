-- 1) 
SELECT COUNT(*) FROM [Production].[Product] --504
SELECT COUNT(*) FROM [Production].[ProductCategory] --4
SELECT COUNT(*) FROM [Production].[ProductSubcategory] --37

-- 2)
SELECT *
FROM [Production].[Product] P
WHERE P.Color is NULL;

-- 3)
SELECT YEAR(OrderDate) as "Year", SUM(TotalDue) as "Total"
FROM [Sales].[SalesOrderHeader]
GROUP BY YEAR(OrderDate)
ORDER BY YEAR(OrderDate);

-- 4)
--a) ilu jest klientów
SELECT COUNT(DISTINCT(PersonID))
FROM [Sales].[Customer] C
    JOIN [Person].[Person] ON [Person].[BusinessEntityID] = C.PersonID;

--b) ilu jest klientów w danym regionie
SELECT
    Sales.SalesTerritory.Name as "Territory",
    COUNT(DISTINCT(PersonID)) as "Customers"
FROM Sales.Customer
    JOIN Person.Person ON Person.BusinessEntityID = Sales.Customer.PersonID
    JOIN Sales.SalesTerritory ON Sales.Customer.TerritoryID = Sales.SalesTerritory.TerritoryID
GROUP BY SalesTerritory.Name;

--c) ilu jest sprzedawców
SELECT COUNT(*)
FROM [Sales].[SalesPerson] S;

--d) ilu jest sprzedawców w danym regionie (LEFT JOIN Z nullem a join bez nulla)
SELECT
    Sales.SalesTerritory.Name as "Territory",
    COUNT(*) as "SalesPersons"
FROM Sales.SalesPerson
    LEFT JOIN Sales.SalesTerritory ON SalesPerson.TerritoryID = SalesTerritory.TerritoryID
GROUP BY SalesTerritory.Name;


-- 5)
SELECT
    Year(S.OrderDate) as "Year",
    COUNT(S.SalesOrderID) as "Orders"
FROM Sales.SalesOrderHeader S
GROUP BY Year(S.OrderDate)
ORDER BY Year(S.OrderDate);

-- 6) Podaj produkty, które nie zostały kupione przez żadnego klienta. Zestawienie pogrupuj według kategorii i podkategorii.
SELECT
    PC.Name as "Category",
    PSC.Name as "Subcategory",
    PP.ProductID as "ProductID",
    PP.Name as "Product"
FROM Production.Product PP
    LEFT JOIN Sales.SalesOrderDetail SOD ON PP.ProductID = SOD.ProductID
    LEFT JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
WHERE SOD.ProductID IS NULL;

SELECT
    PC.Name as "Category",
    PSC.Name as "Subcategory",
    COUNT(PP.ProductID) as "Products"
FROM Production.Product PP
    LEFT JOIN Sales.SalesOrderDetail SOD ON PP.ProductID = SOD.ProductID
    LEFT JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
    LEFT JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
WHERE SOD.ProductID IS NULL
GROUP BY PC.Name, PSC.Name;

-- 7) Oblicz minimalną i maksymalną kwotę rabatu udzielonego na produkty w poszczególnych podkategoriach.
SELECT
    PSC.Name as "Subcategory",
    MIN(SOD.UnitPriceDiscount) as "MinDiscount",
    MAX(SOD.UnitPriceDiscount) as "MaxDiscount"
FROM [Sales].[SalesOrderDetail] SOD
    JOIN [Production].[Product] PP ON SOD.ProductID = PP.ProductID
    JOIN [Production].[ProductSubcategory] PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
GROUP BY PSC.Name;

SELECT
    PSC.Name as "Subcategory",
    MIN(SOD.UnitPriceDiscount * SOD.OrderQty * SOD.UnitPrice) as "MinDiscount",
    MAX(SOD.UnitPriceDiscount * SOD.OrderQty * SOD.UnitPrice) as "MaxDiscount"
FROM Sales.SalesOrderDetail SOD
    JOIN Production.Product PP ON SOD.ProductID = PP.ProductID
    JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
GROUP BY PSC.Name;

-- 8) Podaj produkty, których cena jest wyższa od średniej ceny produktów w sklepie.
SELECT
    PP.ProductID as "ProductID",
    PP.Name as "ProductName",
    PP.ListPrice as "Price"
FROM [Production].[Product] PP
WHERE PP.ListPrice > (SELECT AVG(ListPrice) FROM [Production].[Product]);

-- 9) Ile średnio produktów w każdej kategorii sprzedaje się w poszczególnych miesiącach?
SELECT
    YEAR(S.OrderDate) as "Year",
    MONTH(S.OrderDate) as "Month",
    PC.Name as "Category",
    COUNT(SOD.ProductID) / COUNT(DISTINCT(SOD.SalesOrderID)) as "AvgProductsSold"
FROM [Sales].[SalesOrderDetail] SOD
    JOIN [Sales].[SalesOrderHeader] S ON SOD.SalesOrderID = S.SalesOrderID
    JOIN [Production].[Product] PP ON SOD.ProductID = PP.ProductID
    JOIN [Production].[ProductSubcategory] PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN [Production].[ProductCategory] PC ON PSC.ProductCategoryID = PC.ProductCategoryID
GROUP BY YEAR(S.OrderDate), MONTH(S.OrderDate), PC.Name
ORDER BY YEAR(S.OrderDate), MONTH(S.OrderDate), PC.Name;

-- 10) Ile średnio czasu klient czeka na dostawę zamówionych produktów? Przygotuj zestawienie w zależności od kodu regionu (SalesTerritory.CountryRegionCode).
SELECT
    ST.CountryRegionCode as "CountryRegionCode",
    AVG(CAST(DATEDIFF(DAY, S.OrderDate, S.ShipDate) as float)) as "AvgDaysToShip"
FROM [Sales].[SalesOrderHeader] S
    JOIN [Sales].[SalesTerritory] ST ON S.TerritoryID = ST.TerritoryID
GROUP BY ST.CountryRegionCode
ORDER BY ST.CountryRegionCode;