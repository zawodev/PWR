--AdventureWorks2022
--1) Utworzyć zestawienie, które dla poszczególnych miesięcy i lat przedstawi informację o liczbie różnych klientów. Przygotuj zapytanie z i bez użycia polecenia pivot.

--a) zapytanie z użyciem polecenia pivot
SELECT * FROM
(
SELECT 
    YEAR(OrderDate) AS Year, 
    MONTH(OrderDate) AS Month, 
    COUNT(DISTINCT CustomerID) AS Customers
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
) AS SourceTable
PIVOT
(
SUM(Customers)
FOR Month IN ([1], [2], [3], [4], [5], [6], [7], [8], [9], [10], [11], [12])
) AS PivotTable;
         
--b) zapytanie bez użycia polecenia pivot
SELECT 
    YEAR(OrderDate) AS Year, 
    MONTH(OrderDate) AS Month, 
    COUNT(DISTINCT CustomerID) AS Customers
FROM Sales.SalesOrderHeader
GROUP BY YEAR(OrderDate), MONTH(OrderDate)
ORDER BY Year, Month;

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
    CAST(SUM(TotalDue) AS DECIMAL(16,2)) AS TotalSum,
    COUNT(DISTINCT ProductID) AS Products
FROM Sales.SalesOrderHeader SOH
    JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY YEAR(OrderDate), MONTH(OrderDate), DAY(OrderDate)
) AS SourceTable
ORDER BY Year, Month, Day;

--4) Wykorzystując polecenie CASE przygotować podsumowania do zestawienia z poprzedniego zadania tak, aby sumowane były kwoty zamówień oraz obliczana liczba różnych produktów dla poszczególnych miesięcy i dni tygodnia.
--   Uwaga: Pamiętaj o wybraniu właściwego atrybutu funkcji datepart tak, aby zgadzała się nazwa dnia tygodnia.

SELECT
    CASE MONTH(OrderDate)
        WHEN 1 THEN 'January'
        WHEN 2 THEN 'February'
        WHEN 3 THEN 'March'
        WHEN 4 THEN 'April'
        WHEN 5 THEN 'May'
        WHEN 6 THEN 'June'
        WHEN 7 THEN 'July'
        WHEN 8 THEN 'August'
        WHEN 9 THEN 'September'
        WHEN 10 THEN 'October'
        WHEN 11 THEN 'November'
        WHEN 12 THEN 'December'
    END MonthName,
    CASE DATEPART(WEEKDAY, OrderDate)
        WHEN 1 THEN 'Sunday'
        WHEN 2 THEN 'Monday'
        WHEN 3 THEN 'Tuesday'
        WHEN 4 THEN 'Wednesday'
        WHEN 5 THEN 'Thursday'
        WHEN 6 THEN 'Friday'
        WHEN 7 THEN 'Saturday'
    END DayName,
    CAST(SUM(TotalDue) AS DECIMAL(16,2)) AS TotalSum,
    COUNT(DISTINCT ProductID) AS ProductsCount
FROM Sales.SalesOrderHeader SOH
JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
GROUP BY MONTH(OrderDate), DATEPART(WEEKDAY, OrderDate)
ORDER BY MONTH(OrderDate), DATEPART(WEEKDAY, OrderDate);
                     
--5) Przygotować zestawienie, w którym dla wybranych klientów przygotujemy kartę lojalnościową:
--a. srebrną, jeśli klient wykonał co najmniej 2 transakcje w sklepie;
--b. złotą, jeśli wykonał co najmniej 4 transakcje w sklepie, w tym co najmniej 2 transakcje, których łączna kwota przekraczała 250% średniej wartości zamówień w bazie;
-- c. platynową, jeśli klient spełniał warunki otrzymania karty złotej oraz w co najmniej jednej transakcji kupił jednocześnie produkty ze wszystkich kategorii.
--Schemat wynikowej tabeli powinien wyglądać następująco:
--KartyLojalnosciowe(Imie, Nazwisko, Liczba transakcji, Łączna kwota transakcji, Kolor karty)

CREATE TABLE KartyLojalnosciowe (
    Imie NVARCHAR(50),
    Nazwisko NVARCHAR(50),
    LiczbaTransakcji INT,
    SumaKwot DECIMAL(16,2),
    KolorKarty NVARCHAR(50)
);

DECLARE @Srednia DECIMAL(16, 2);
SET @Srednia = (SELECT AVG(TotalDue) FROM Sales.SalesOrderHeader);

INSERT INTO KartyLojalnosciowe (Imie, Nazwisko, LiczbaTransakcji, SumaKwot, KolorKarty)
SELECT
    P.FirstName,
    P.LastName,
    T.liczba,
    T.kwota,
    CASE
        WHEN T.liczba >= 4
            AND T.duzeZamowienia >= 2
            AND EXISTS (
                SELECT 1
                FROM Sales.SalesOrderHeader SOH
                         JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
                         JOIN Production.Product PP ON SOD.ProductID = PP.ProductID
                         JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
                         JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
                WHERE SOH.CustomerID = T.CustomerID
                GROUP BY SOH.SalesOrderID
                HAVING COUNT(DISTINCT PC.ProductCategoryID) =
                       (SELECT COUNT(*) FROM Production.ProductCategory)
            ) THEN 'Platinum'
        WHEN T.liczba >= 4 AND T.duzeZamowienia >= 2 THEN 'Gold'
        WHEN T.liczba >= 2 THEN 'Silver'
        ELSE NULL
        END
FROM
    (
        SELECT
            C.CustomerID,
            COUNT(SOH.SalesOrderID) AS liczba,
            SUM(SOH.TotalDue) AS kwota,
            SUM(CASE WHEN SOH.TotalDue > 2.5 * @Srednia THEN 1 ELSE 0 END) AS duzeZamowienia
        FROM Sales.Customer C
                 JOIN Sales.SalesOrderHeader SOH ON C.CustomerID = SOH.CustomerID
        WHERE C.PersonID IS NOT NULL -- pomijamy firmy które nie mają danych osobowych w tabeli Person.Person
        GROUP BY C.CustomerID
    ) AS T
        JOIN Sales.Customer C ON T.CustomerID = C.CustomerID
        JOIN Person.Person P ON C.PersonID = P.BusinessEntityID;


-- test1
SELECT * FROM KartyLojalnosciowe;

-- test2
SELECT KolorKarty, COUNT(*) as "Liczba kart"
FROM KartyLojalnosciowe
GROUP BY KolorKarty
ORDER BY 2;



