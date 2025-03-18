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
-- a) ilu różnych klientów dokonału zakupów w kolejnych miesiącach roku w każdej z grup? 
-- b) ilu klientów w poszczególnych grupach dokonało zakupu dokładnie raz?
    
--a) 
SELECT * FROM
(
SELECT
    YEAR(S.OrderDate) as "Year",
    CASE
        WHEN DATEDIFF(YEAR, C.BirthDate, GETDATE()) BETWEEN 0 AND 30 THEN '0-30'
        WHEN DATEDIFF(YEAR, C.BirthDate, GETDATE()) BETWEEN 31 AND 60 THEN '31-60'
        WHEN DATEDIFF(YEAR, C.BirthDate, GETDATE()) >= 61 THEN '61+'
    END AS "AgeGroup",
    COUNT(DISTINCT C.CustomerID) as "Customers"
FROM Sales.SalesOrderHeader S
    JOIN Sales.Customer C ON S.CustomerID = C.CustomerID
GROUP BY YEAR(S.OrderDate), CASE
        WHEN DATEDIFF(YEAR, C.BirthDate, GETDATE()) BETWEEN 0 AND 30 THEN '0-30'
        WHEN DATEDIFF(YEAR, C.BirthDate, GETDATE()) BETWEEN 31 AND 60 THEN '31-60'
        WHEN DATEDIFF(YEAR, C.BirthDate, GETDATE()) >= 61 THEN '61+'
    END
) AS SourceTable
PIVOT
(
SUM(Customers)
FOR AgeGroup IN ([0-30], [31-60], [61+])
) AS PivotTable
ORDER BY Year;

--b)
SELECT * FROM
(
SELECT
    CASE
        WHEN DATEDIFF(YEAR, C.BirthDate, GETDATE()) BETWEEN 0 AND 30 THEN '0-30'
        WHEN DATEDIFF(YEAR, C.BirthDate, GETDATE()) BETWEEN 31 AND 60 THEN '31-60'
        WHEN DATEDIFF(YEAR, C.BirthDate, GETDATE()) >= 61 THEN '61+'
    END AS "AgeGroup",
    COUNT(DISTINCT C.CustomerID) as "Customers"
FROM Sales.SalesOrderHeader S
    JOIN Sales.Customer C ON S.CustomerID = C.CustomerID
GROUP BY CASE
        WHEN DATEDIFF(YEAR, C.BirthDate, GETDATE()) BETWEEN 0 AND 30 THEN '0-30'
        WHEN DATEDIFF(YEAR, C.BirthDate, GETDATE()) BETWEEN 31 AND 60 THEN '31-60'
        WHEN DATEDIFF(YEAR, C.BirthDate, GETDATE()) >= 61 THEN '61+'
    END
HAVING COUNT(DISTINCT C.CustomerID) = 1
) AS SourceTable
ORDER BY AgeGroup;

    

--3) przygotuj zestawienie produktów, których sprzedaje się miesięcznie minimum 20 sztuk. Dla każdego produktu podaj jego kategorie. Jeżeli warto użyć CTE to porównaj efektywność rozwiązania z wersją i bez CTE
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
