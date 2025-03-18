-- AdventureWorks2022
-- Zadanie: Połącz Case z Pivotem i zdefiniuj zapytanie, gdzie dla poszczególnych miesięcy i rozmiarów rowerów (duże średnie małe) przedstawisz informację o liczbie sprzedanych sztuk rowerów. 3 rozmiary rowerów (S, M, L) to liczby od 38 do 62, gdzie S to liczby od 38 do 45, M to liczby od 46 do 54, a L to liczby od 55 do 62.
-- uważaj na błąd: Conversion failed when converting the nvarchar value 'M' to data type int.

SELECT * FROM (
                  SELECT
                      CASE
                          WHEN MONTH(S.OrderDate) = 1 THEN 'January'
            WHEN MONTH(S.OrderDate) = 2 THEN 'February'
            WHEN MONTH(S.OrderDate) = 3 THEN 'March'
            WHEN MONTH(S.OrderDate) = 4 THEN 'April'
            WHEN MONTH(S.OrderDate) = 5 THEN 'May'
            WHEN MONTH(S.OrderDate) = 6 THEN 'June'
            WHEN MONTH(S.OrderDate) = 7 THEN 'July'
            WHEN MONTH(S.OrderDate) = 8 THEN 'August'
            WHEN MONTH(S.OrderDate) = 9 THEN 'September'
            WHEN MONTH(S.OrderDate) = 10 THEN 'October'
            WHEN MONTH(S.OrderDate) = 11 THEN 'November'
            WHEN MONTH(S.OrderDate) = 12 THEN 'December'
END AS Month,
        CASE
            WHEN TRY_CONVERT(int, PP.Size) BETWEEN 38 AND 45 THEN 'S'
            WHEN TRY_CONVERT(int, PP.Size) BETWEEN 46 AND 54 THEN 'M'
            WHEN TRY_CONVERT(int, PP.Size) BETWEEN 55 AND 62 THEN 'L'
END AS Size,
        SUM(SOD.OrderQty) AS Sold
    FROM Production.Product PP
		JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
		JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
        JOIN Sales.SalesOrderDetail SOD ON PP.ProductID = SOD.ProductID
        JOIN Sales.SalesOrderHeader S ON SOD.SalesOrderID = S.SalesOrderID
    WHERE TRY_CONVERT(int, PP.Size) BETWEEN 38 AND 62 AND PC.Name = 'Bikes'
    GROUP BY MONTH(S.OrderDate), PP.Size
) AS SourceTable
PIVOT
(
    SUM(Sold)
    FOR Size IN ([S], [M], [L])
) AS PivotTable
ORDER BY CASE
    WHEN Month = 'January' THEN 1
    WHEN Month = 'February' THEN 2
    WHEN Month = 'March' THEN 3
    WHEN Month = 'April' THEN 4
    WHEN Month = 'May' THEN 5
    WHEN Month = 'June' THEN 6
    WHEN Month = 'July' THEN 7
    WHEN Month = 'August' THEN 8
    WHEN Month = 'September' THEN 9
    WHEN Month = 'October' THEN 10
    WHEN Month = 'November' THEN 11
    WHEN Month = 'December' THEN 12
END;





-- ze wszystkich rowerów wyświetl min size i max size
SELECT 
    MIN(PP.Size) AS MinSize,
    MAX(PP.Size) AS MaxSize
FROM Production.Product PP
    JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
    JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
WHERE PC.Name = 'Bikes';



SELECT * FROM Production.Product PP
                  JOIN Production.ProductSubcategory PSC ON PP.ProductSubcategoryID = PSC.ProductSubcategoryID
                  JOIN Production.ProductCategory PC ON PSC.ProductCategoryID = PC.ProductCategoryID
WHERE PC.Name = 'Bikes';
