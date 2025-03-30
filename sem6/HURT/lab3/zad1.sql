-- baza danych: AdventureWorks2022
-- zad1: Wykorzystanie funkcji grupujących (rollup, cube, grouping sets):

--a) Przygotować zestawienie przedstawiające, ile pieniędzy wydali poszczególni klienci na zamówienia na przestrzeni poszczególnych lat. Wykonaj zestawienie przy użyciu poleceń rollup, cube, grouping sets.

--rollup
SELECT
    COALESCE(CONCAT(FirstName, ' ', LastName), '') as "Customer",
    COALESCE(CAST(DATEPART(YEAR, OrderDate) AS VARCHAR), '') as "Year",
    SUM(TotalDue) as "Total"
FROM Sales.SalesOrderHeader SOH
    JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID
    JOIN Person.Person P ON C.PersonID = P.BusinessEntityID
GROUP BY ROLLUP((FirstName, LastName), YEAR(OrderDate)),
         ROLLUP((YEAR(OrderDate)))
ORDER BY "Customer", "Year";

--cube
SELECT
    COALESCE(CONCAT(FirstName, ' ', LastName), '') as "Customer",
    COALESCE(CAST(DATEPART(YEAR, OrderDate) AS VARCHAR), '') as "Year",
    SUM(TotalDue) as "Total"
FROM Sales.SalesOrderHeader SOH
    JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID
    JOIN Person.Person P ON C.PersonID = P.BusinessEntityID
GROUP BY CUBE((FirstName, LastName), YEAR(OrderDate))
ORDER BY "Customer", "Year";
    
--grouping sets
SELECT
    COALESCE(CONCAT(FirstName, ' ', LastName), '') as "Customer",
    COALESCE(CAST(DATEPART(YEAR, OrderDate) AS VARCHAR), '') as "Year",
    SUM(TotalDue) as "Total"
FROM Sales.SalesOrderHeader SOH
         JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID
         JOIN Person.Person P ON C.PersonID = P.BusinessEntityID
GROUP BY GROUPING SETS ((Year(OrderDate), CONCAT(FirstName, ' ', LastName)), 
                        (Year(OrderDate)), (CONCAT(FirstName, ' ', LastName)), ())
ORDER BY 1, 2;

--b) Przygotować zestawienie przedstawiające łączną kwotę zniżek z podziałem na kategorie, produkty oraz lata. (rozwiązanie tylko w jednej wersji - dowolnej (rollup, cube, grouping sets))

SELECT
    COALESCE(PC.Name, '') as "Category",
    COALESCE(P.Name, '') as "Product",
    COALESCE(CAST(DATEPART(YEAR, OrderDate) AS VARCHAR), '') as "Year",
    ROUND(SUM(SOD.OrderQty * SOD.UnitPrice * SOD.UnitPriceDiscount), 2) as "Discount"
FROM Sales.SalesOrderDetail SOD
         JOIN Production.Product P ON SOD.ProductID = P.ProductID
         JOIN Production.ProductSubcategory PSC ON P.ProductSubcategoryID = PSC.ProductSubcategoryID
         JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
         JOIN Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
GROUP BY GROUPING SETS ((PC.Name, P.Name, YEAR(OrderDate)), (PC.Name, P.Name), (PC.Name), ())

-- zad2: Wykorzystanie funkcji okienkowych (over, over partition by, row_number, rank, dense_rank, ntile)
-- a) Dla kategorii ‘Bikes’ przygotuj zestawienie prezentujące procentowy udział kwot
-- sprzedaży produktów tej kategorii w poszczególnych latach w stosunku do łącznej
-- kwoty sprzedaży dla tej kategorii. W zadaniu wykorzystaj funkcje okna.
-- Wykonaj podoobne zestawienie dla pozoatałych kategorii. (Bikes, Components, Clothing, Accessories)

WITH BikesSales AS (
    SELECT
        YEAR(SOH.OrderDate) AS Rok,
        SUM(SOD.LineTotal) AS SalesAmount
    FROM Sales.SalesOrderHeader SOH
        JOIN Sales.SalesOrderDetail SOD ON SOH.SalesOrderID = SOD.SalesOrderID
        JOIN Production.Product P ON SOD.ProductID = P.ProductID
        JOIN Production.ProductSubcategory PS ON P.ProductSubcategoryID = PS.ProductSubcategoryID
        JOIN Production.ProductCategory PC ON PS.ProductCategoryID = PC.ProductCategoryID
    WHERE PC.Name = 'Bikes'
    GROUP BY YEAR(SOH.OrderDate)
)
SELECT Nazwa, Rok, Procent
FROM (
     SELECT
         'Bikes' AS Nazwa,
         CAST(Rok AS VARCHAR(4)) AS Rok,
         CAST(ROUND(100.0 * SalesAmount / SUM(SalesAmount) OVER (), 2) AS DECIMAL(5,2)) AS Procent,
         Rok AS SortOrder
     FROM BikesSales
    
     UNION ALL
    
     SELECT
         '' AS Nazwa,
         '' AS Rok,
         CAST(100.00 AS DECIMAL(5,2)) AS Procent,
         9999 AS SortOrder
) AS T
ORDER BY SortOrder;

-- b) Przygotuj zestawienie dla sprzedawców z podziałem na lata i miesiące prezentujące
-- liczbę obsłużonych przez nich zamówień w ciągu roku, w ciągu roku narastająco oraz
-- sumarycznie w obecnym i poprzednim miesiącu. W zadaniu wykorzystaj funkcje okna.

-- oczekiwane kolumny: Imię nazwisko, Rok, Miesiąc, W miesiącu, W roku, W roku narastająco, Obecny i poprzedni miesiąc

WITH SalesPerSalesPerson AS (
    SELECT
        P.FirstName + ' ' + P.LastName AS SalesPerson,
        YEAR(SOH.OrderDate) AS Year,
        MONTH(SOH.OrderDate) AS Month,
        COUNT(SOH.SalesOrderID) AS Orders
    FROM Sales.SalesOrderHeader SOH
        JOIN Sales.SalesPerson SP ON SOH.SalesPersonID = SP.BusinessEntityID
        JOIN Person.Person P ON SP.BusinessEntityID = P.BusinessEntityID
    GROUP BY P.FirstName, P.LastName, YEAR(SOH.OrderDate), MONTH(SOH.OrderDate)
)

SELECT
    SalesPerson,
    Year,
    Month,
    Orders,
    SUM(Orders) OVER (PARTITION BY SalesPerson, Year, Month) AS "W miesiącu",
    SUM(Orders) OVER (PARTITION BY SalesPerson, Year) AS "W roku",
    SUM(Orders) OVER (PARTITION BY SalesPerson, Year ORDER BY Month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS "W roku narastająco",
    SUM(Orders) OVER (PARTITION BY SalesPerson ORDER BY Year, Month ROWS BETWEEN 1 PRECEDING AND CURRENT ROW) AS "Obecny i poprzedni miesiąc"
FROM SalesPerSalesPerson
ORDER BY SalesPerson, Year, Month;

-- c) Przygotuj ranking klientów w zależności od liczby zakupionych produktów. Porównaj rozwiązania uzyskane przez funkcje rank i dense_rank.
-- kolumny: Imię, Nazwisko, Suma produktów, DENSE_RANK, RANK

WITH CustomersProducts AS (
    SELECT
        P.FirstName,
        P.LastName,
        SUM(SOD.OrderQty) AS Products
    FROM Sales.SalesOrderDetail SOD
        JOIN Sales.SalesOrderHeader SOH ON SOD.SalesOrderID = SOH.SalesOrderID
        JOIN Sales.Customer C ON SOH.CustomerID = C.CustomerID
        JOIN Person.Person P ON C.PersonID = P.BusinessEntityID
    GROUP BY P.FirstName, P.LastName
)

SELECT
    FirstName,
    LastName,
    Products,
    DENSE_RANK() OVER (ORDER BY Products DESC) AS DenseRank,
    RANK() OVER (ORDER BY Products DESC) AS Rank
FROM CustomersProducts
ORDER BY Products DESC;

-- d) Przygotuj ranking produktów w zależności od średniej liczby sprzedanych sztuk. Wyróżnij 3 (prawie równoliczne) grupy produktów: sprzedających się najlepiej, średnio i najsłabiej.
-- kolumny: Nazwa produktu, Średnia liczba sprzedanych sztuk, nazwa grupy (dwa produkty o tej samej liczbie sprzedanych sztuk powinny być w tej samej grupie)

WITH ProductsSales AS (
    SELECT
        P.Name AS Product,
        AVG(SOD.OrderQty) AS AvgSold
    FROM Sales.SalesOrderDetail SOD
        JOIN Production.Product P ON SOD.ProductID = P.ProductID
    GROUP BY P.Name
)

SELECT
    Product,
    AvgSold,
    CASE NTILE(3) OVER (ORDER BY AvgSold DESC)
    WHEN 1 THEN 'najlepiej'
        WHEN 2 THEN 'srednio'
        ELSE 'najslabiej'
END ranking
FROM ProductsSales
ORDER BY AvgSold DESC;


-- wnioski:
-- Wykorzystanie funkcji grupujących (rollup, cube, grouping sets) okazało się przydatne do uzyskania dodatkowych informacji 
-- o danych, takich jak sumy całkowite, sumy częściowe czy rankingu i podsumowania na różnych poziomach szczegółow w relatywnie
-- prosty sposób. Wyniki takiego zapytania są właściwie gotowe do użycia w raportach i analizach.

-- Największe zniżki dotyczą produktów z kategorii 'Bikes'. Łączna kwota zniżek dla tej kategorii wynosi ponad 0,5 miliona. Widać, że
-- niektóre produkty nigdy nie potrzebowały zniżki, co może sugerować ich wysoką jakość lub popularność. Inne produkty były przeceniane
-- tylko w niektórych latach lub miesiącach, co może być związane z sezonowością sprzedaży lub innymi czynnikami rynkowymi.
-- 
-- Najwięcej zniżek zostało udzielonych w 2012 i 2013 roku (około 200tys w 2012 i 300tys w 2013) - może to sugerować, że w tych latach
-- sklep dynamicznie się rozwijał i wprowadzał nowe promocje, aby przyciągnąć klientów (pik w sprzedaży 2013 rok).

-- Najlepszym pracownikiem był Jillian Carson, który w ciągu 2013 roku obsłużył 185 transakcji (w każdym miesiącu regularnie radził
-- sobie dobrze, najgorszym był Amy Alberts, który obsłużył zaledwie 3 transakcje.

-- Najlepszym klientem był Reuben D'Sa który zakupił aż 2737 produktów.
-- Najgorszych klientów było ponad 3500, czyli tych, którzy kupili tylko jeden produkt.

-- Najlepszym produktem był Full-Finger Gloves L (9 sztuk średnio sprzedanych). Na drugim miejscu ten sam produkt w rozmiarze M.

-- Pandas Profiling jest doskonałym narzędziem, aby automatycznie wygenerować ciekawe statystyki dotyczące zbioru danych.
-- Udało się z łatwością zobaczyć ile jest unikalnych wartości, brakujących rekordów i inne ciekawe statystyki.