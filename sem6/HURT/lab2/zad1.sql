--AdventureWorks2022
--1) Utworzyć zestawienie, które dla poszczególnych miesięcy i lat przedstawi informację o liczbie różnych klientów. Przygotuj zapytanie z i bez użycia polecenia pivot.

--a) zapytanie z użyciem polecenia pivot
SELECT * FROM
(
SELECT YEAR(OrderDate) AS Year, MONTH(OrderDate) AS Month, COUNT(DISTINCT CustomerID) AS Customers
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
) AS SourceTable
PIVOT
(
SUM(Customers)
FOR Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS PivotTable
         
--b) zapytanie bez użycia polecenia pivot
SELECT YEAR(OrderDate) AS Year, MONTH(OrderDate) AS Month, COUNT(DISTINCT CustomerID) AS Customers
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Year, Month

--2) Używając PIVOT, utworzyć zestawienie zawierające w wierszach imiona i nazwiska sprzedawców, a w kolumnach kolejne lata. Wartością będzie liczba obsłużonych transakcji. Wyświetlić tylko tych sprzedawców, którzy pracowali przez wszystkie 4 lata.

SELECT * FROM
(
SELECT
    P.FirstName + ' ' + P.LastName AS SalesPerson,
    YEAR(SOH.OrderDate) AS Year,
    COUNT(SOH.SalesOrderID) AS Orders
FROM Sales.SalesOrderHeader SOH
    JOIN Sales.SalesPerson SP ON SOH.SalesPersonID = SP.BusinessEntityID
    JOIN Person.Person P ON SP.BusinessEntityID = P.BusinessEntityID
GROUP BY P.FirstName, P.LastName, YEAR(SOH.OrderDate)
) AS SourceTable
PIVOT
(
SUM(Orders)
FOR Year IN ([2011], [2012], [2013], [2014])
) AS PivotTable
WHERE [2011] IS NOT NULL AND [2012] IS NOT NULL AND [2013] IS NOT NULL AND [2014] IS NOT NULL

--3) Zdefiniować zapytanie wyznaczające sumę kwot sprzedaży towarów oraz liczbę różnych produktów w zamówieniach w poszczególnych latach, miesiącach, dniach.

SELECT * FROM
(
SELECT
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    DAY(OrderDate) AS Day,
    SUM(TotalDue) AS Total,
    COUNT(DISTINCT ProductID) AS Products
FROM Sales.SalesOrderHeader SOH
    JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY YEAR(OrderDate), MONTH(OrderDate), DAY(OrderDate)
) AS SourceTable
ORDER BY Year, Month, Day

--4) Wykorzystując polecenie CASE przygotować podsumowania do zestawienia z poprzedniego zadania tak, aby sumowane były kwoty zamówień oraz obliczana liczba różnych produktów dla poszczególnych miesięcy i dni tygodnia.
--   Uwaga: Pamiętaj o wybraniu właściwego atrybutu funkcji datepart tak, aby zgadzała się nazwa dnia tygodnia.
--te jest zle imo
SELECT * FROM
(
SELECT
    YEAR(OrderDate) AS Year,
    MONTH(OrderDate) AS Month,
    CASE
        WHEN DATEPART(WEEKDAY, OrderDate) = 1 THEN 'Sunday'
        WHEN DATEPART(WEEKDAY, OrderDate) = 2 THEN 'Monday'
        WHEN DATEPART(WEEKDAY, OrderDate) = 3 THEN 'Tuesday'
        WHEN DATEPART(WEEKDAY, OrderDate) = 4 THEN 'Wednesday'
        WHEN DATEPART(WEEKDAY, OrderDate) = 5 THEN 'Thursday'
        WHEN DATEPART(WEEKDAY, OrderDate) = 6 THEN 'Friday'
        WHEN DATEPART(WEEKDAY, OrderDate) = 7 THEN 'Saturday'
    END AS DayOfWeek,
    SUM(TotalDue) AS Total,
    COUNT(DISTINCT ProductID) AS Products
FROM Sales.SalesOrderHeader SOH
    JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY YEAR(OrderDate), MONTH(OrderDate), DATEPART(WEEKDAY, OrderDate)
) AS SourceTable
ORDER BY Year, Month, DayOfWeek


