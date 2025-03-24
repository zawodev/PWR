-- dla bazy danych Adventure Works 2022

-- 1) Jaka jest łączna suma transakcji (salesorderheader.subtotal) w poszczególnych latach dla kolejnych dni tygodnia
SELECT
    YEAR(S.OrderDate) as "Year",
    DATEPART(WEEKDAY, S.OrderDate) as "DayOfWeek",
    SUM(S.SubTotal) as "Total"
FROM Sales.SalesOrderHeader S
GROUP BY YEAR(S.OrderDate), DATEPART(WEEKDAY, S.OrderDate)
ORDER BY YEAR(S.OrderDate), DATEPART(WEEKDAY, S.OrderDate);

--wersja pivot (dni tygodnia zamiast numerów to nazwy)
SELECT * FROM
(
SELECT
    YEAR(S.OrderDate) as "Year",
    DATENAME(WEEKDAY, S.OrderDate) as "DayOfWeek",
    SUM(S.SubTotal) as "Total"
FROM Sales.SalesOrderHeader S
GROUP BY YEAR(S.OrderDate), DATENAME(WEEKDAY, S.OrderDate)
) AS SourceTable
PIVOT
(
SUM(Total)
FOR DayOfWeek IN ([Monday], [Tuesday], [Wednesday], [Thursday], [Friday], [Saturday], [Sunday])
) AS PivotTable
ORDER BY Year;



--2) Zaproponuj podział klientów na 3 rozłączne grupy wiekowe (0-30, 31-60, 61+), 
-- a) ilu różnych klientów dokonywało zakupów w kolejnych miesiącach roku w każdej z grup? 
-- b) ilu klientów w poszczególnych grupach dokonało zakupu dokładnie raz?
    
--a) (pivot, gdzie wiersze to miesiące, kolumny to grupy wiekowe, wartości to liczba klientów)

--a)
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey' as ns)
SELECT * FROM
(
SELECT
    FORMAT(S.OrderDate, 'yyyy-MM') AS OrderMonth,
    CASE
        WHEN DATEDIFF(YEAR, BD, GETDATE()) <= 50 THEN '0-50'
        WHEN DATEDIFF(YEAR, BD, GETDATE()) <= 60 THEN '51-60'
        ELSE '61+'
    END AS AgeGroup,
    COUNT(DISTINCT S.CustomerID) AS UniqueCustomers
FROM Sales.SalesOrderHeader S
         JOIN Sales.Customer C ON S.CustomerID = C.CustomerID
         JOIN Person.Person P ON C.PersonID = P.BusinessEntityID
CROSS APPLY (
SELECT P.Demographics.value('(/ns:IndividualSurvey/ns:BirthDate)[1]', 'datetime') AS BD
) AS BirthData
GROUP BY FORMAT(S.OrderDate, 'yyyy-MM'), CASE
    WHEN DATEDIFF(YEAR, BD, GETDATE()) <= 50 THEN '0-50'
    WHEN DATEDIFF(YEAR, BD, GETDATE()) <= 60 THEN '51-60'
    ELSE '61+'
END
) AS SourceTable
PIVOT
(
SUM(UniqueCustomers)
FOR AgeGroup IN ([0-50], [51-60], [61+])
) AS PivotTable
ORDER BY OrderMonth;


    
--b)
WITH XMLNAMESPACES ('http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey' as ns),
     CustomerOrders AS (
         SELECT
             S.CustomerID,
             COUNT(*) AS OrderCount,
             CASE
                 WHEN DATEDIFF(YEAR, BD, GETDATE()) <= 50 THEN '0-50'
                 WHEN DATEDIFF(YEAR, BD, GETDATE()) <= 60 THEN '51-60'
                 ELSE '61+'
                 END AS AgeGroup
         FROM Sales.SalesOrderHeader S
                  JOIN Sales.Customer C ON S.CustomerID = C.CustomerID
                  JOIN Person.Person P ON C.PersonID = P.BusinessEntityID
    CROSS APPLY (
    SELECT P.Demographics.value('(/ns:IndividualSurvey/ns:BirthDate)[1]', 'datetime') AS BD
    ) AS BirthData
GROUP BY
    S.CustomerID,
    CASE
    WHEN DATEDIFF(YEAR, BD, GETDATE()) <= 50 THEN '0-50'
    WHEN DATEDIFF(YEAR, BD, GETDATE()) <= 60 THEN '51-60'
    ELSE '61+'
END
)
SELECT
    AgeGroup,
    COUNT(*) AS OneTimeBuyers
FROM CustomerOrders
WHERE OrderCount = 1
GROUP BY AgeGroup;

    

--3) przygotuj zestawienie produktów, których sprzedaje się miesięcznie minimum 20 sztuk. Dla każdego produktu podaj jego kategorie. Jeżeli warto użyć CTE to porównaj efektywność rozwiązania z wersją i bez CTE
-- a) bez CTE
SET STATISTICS IO, TIME ON

WITH Products AS
(
SELECT
    PP.ProductID as "ProductID",
    PP.Name as "Product",
    PC.Name as "Category",
    SUM(SOD.OrderQty) as "Sold"
FROM Production.Product PP
    JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
    JOIN Sales.SalesOrderDetail SOD ON PP.ProductID = SOD.ProductID
    JOIN Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
GROUP BY PP.ProductID, PP.Name, PC.Name
HAVING SUM(SOD.OrderQty) >= 20
)
SELECT * FROM Products;

SELECT * FROM
(
SELECT
    PP.ProductID as "ProductID",
    PP.Name as "Product",
    PC.Name as "Category",
    SUM(SOD.OrderQty) as "Sold"
FROM Production.Product PP
    JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
    JOIN Sales.SalesOrderDetail SOD ON PP.ProductID = SOD.ProductID
    JOIN Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
GROUP BY PP.ProductID, PP.Name, PC.Name
HAVING SUM(SOD.OrderQty) >= 20
) AS SourceTable;



-- 4) Przygotuj zestawienie, w którym przeanalizujesz, ilu jest różnych klientów dla każdej płci w kolejnych miesiącach (05.2011 – 06.2014)? Jak procentowo rozkłada się ich udział w całkowitej wartości sprzedaży (Sales.SalesOrderHeader.TotalDue)
WITH CustomerGender AS (
    SELECT
        c.CustomerID,
        Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/IndividualSurvey/Gender)[1]', 'NVARCHAR(10)') AS Gender
    FROM Sales.Customer c JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
    WHERE c.PersonID IS NOT NULL AND Demographics.value('declare default element namespace "http://schemas.microsoft.com/sqlserver/2004/07/adventure-works/IndividualSurvey"; (/IndividualSurvey/Gender)[1]', 'NVARCHAR(10)') IN ('M', 'F')
),
 CustomersMonthly AS (
     SELECT
         FORMAT(soh.OrderDate, 'yyyy-MM') AS OrderMonthYear,
         cg.Gender,
         COUNT(DISTINCT soh.CustomerID) AS UniqueCustomers,
         SUM(soh.TotalDue) AS TotalSales
     FROM Sales.SalesOrderHeader soh JOIN CustomerGender cg ON soh.CustomerID = cg.CustomerID
     WHERE soh.OrderDate BETWEEN '2011-05-01' AND '2014-06-30'
     GROUP BY FORMAT(soh.OrderDate, 'yyyy-MM'), cg.Gender
 )
SELECT
    OrderMonthYear,
    Gender,
    TotalSales,
    (TotalSales * 100.0 / SUM(TotalSales) OVER (PARTITION BY OrderMonthYear)) AS SalesPercentage,
    UniqueCustomers
FROM CustomersMonthly
ORDER BY OrderMonthYear, Gender;

-- 5) Przeanalizuj udział sprzedanych produktów w poszczególnych podkategoriach w stosunku do całych kategorii (zarówno pod względem liczbowym jak i wartościowym).
WITH ProductSales AS (
    SELECT
        PC.Name AS Category,
        PSC.Name AS Subcategory,
        SUM(SOD.OrderQty) AS SoldQty,
        SUM(SOD.LineTotal) AS SoldValue
    FROM Production.Product PP
             JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
             JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
             JOIN Sales.SalesOrderDetail SOD ON PP.ProductID = SOD.ProductID
    GROUP BY PC.Name, PSC.Name
),
CategorySales AS (
     SELECT
         PC.Name AS Category,
         SUM(SOD.OrderQty) AS SoldQty,
         SUM(SOD.LineTotal) AS SoldValue
     FROM Production.Product PP
              JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
              JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
              JOIN Sales.SalesOrderDetail SOD ON PP.ProductID = SOD.ProductID
     GROUP BY PC.Name
)
SELECT
    PS.Category,
    PS.Subcategory,
    PS.SoldQty,
    PS.SoldValue,
    (PS.SoldQty * 100.0 / CS.SoldQty) AS QtyPercentage,
    (PS.SoldValue * 100.0 / CS.SoldValue) AS ValuePercentage
FROM ProductSales PS
         JOIN CategorySales CS ON PS.Category = CS.Category
ORDER BY PS.Category, PS.Subcategory;    

-- 6) Przygotuj zestawienie (pivot), w którym możliwa będzie analiza regionalna z uwzględnieniem lokalnej waluty (kwoty sprzedaży w zależności od waluty i regionu). 
-- Wiersze: regiony, kolumny: waluty, wartości: suma kwot sprzedaży (Sales.SalesOrderHeader.TotalDue)
SELECT * FROM
    (
        SELECT
            st.CountryRegionCode AS Region,
            cr.FromCurrencyCode AS Currency,
            SUM(soh.TotalDue) AS TotalSales
        FROM Sales.SalesOrderHeader soh
                 JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
                 JOIN Sales.CurrencyRate cr ON soh.CurrencyRateID = cr.CurrencyRateID
        GROUP BY st.CountryRegionCode, cr.FromCurrencyCode
    ) AS SourceTable
    PIVOT
(
SUM(TotalSales)
FOR Currency IN ([USD], [EUR], [PLN])
) AS PivotTable
ORDER BY Region;


SELECT
    cr.FromCurrencyCode AS Currency,
    st.Name AS Territory
FROM Sales.SalesOrderHeader soh
         LEFT JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
         LEFT JOIN Sales.CurrencyRate cr ON soh.CurrencyRateID = cr.CurrencyRateID
GROUP BY cr.FromCurrencyCode, st.Name
ORDER BY cr.FromCurrencyCode, st.Name;

