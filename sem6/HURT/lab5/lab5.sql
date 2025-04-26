-- Baza danych: AdventureWorks2022
-- Zad 1. Usunąć tabele stworzone w liście 4

IF EXISTS(
   SELECT * 
   FROM INFORMATION_SCHEMA.TABLES 
   WHERE TABLE_SCHEMA = 'Stepaniuk'
   AND TABLE_NAME = 'FACT_SALES'
)
BEGIN
    DROP TABLE Stepaniuk.FACT_SALES;
END

IF EXISTS(
   SELECT * 
   FROM INFORMATION_SCHEMA.TABLES 
   WHERE TABLE_SCHEMA = 'Stepaniuk'
   AND TABLE_NAME = 'DIM_CUSTOMER'
)
BEGIN
   DROP TABLE Stepaniuk.DIM_CUSTOMER;
END

IF EXISTS(
   SELECT * 
   FROM INFORMATION_SCHEMA.TABLES 
   WHERE TABLE_SCHEMA = 'Stepaniuk'
   AND TABLE_NAME = 'DIM_PRODUCT'
)
BEGIN
   DROP TABLE Stepaniuk.DIM_PRODUCT;
END

IF EXISTS(
   SELECT * 
   FROM INFORMATION_SCHEMA.TABLES 
   WHERE TABLE_SCHEMA = 'Stepaniuk'
   AND TABLE_NAME = 'DIM_SALESPERSON'
)
BEGIN
   DROP TABLE Stepaniuk.DIM_SALESPERSON;
END

IF EXISTS(
   SELECT * 
   FROM INFORMATION_SCHEMA.SCHEMATA 
   WHERE SCHEMA_NAME = 'Stepaniuk'
)
BEGIN
   DROP SCHEMA Stepaniuk;
END

-- Zad 2. Wymiar czasowy
-- Przygotować wymiar czasowy: utworzyć i wypełnić danymi tabelę DIM_TIME. Tabela
-- DIM_TIME powinna być tabelą zawierającą wymiar czasowy (klucze obce do tej tabeli
-- znajdują się w tabeli faktów).
-- Tabela DIM_TIME powinna zawierać następujące kolumny:
-- • PK_TIME (klucz główny – liczba całkowita postaci yyyymmdd – format taki sam jak kolumn OrderDate, ShipDate)
-- • Rok
-- • Kwartał
-- • Miesiąc
-- • Miesiąc słownie (wykorzystać tabelę pomocniczą z 12 rekordami dokonać odpowiedniego złączenia)
-- • Dzień tygodnia słownie (wykorzystać tabelę pomocniczą z 7 rekordami dokonać odpowiedniego złączenia)
-- • Dzień miesiąca

CREATE TABLE Stepaniuk.DIM_TIME (
    PK_TIME INT PRIMARY KEY,
    Year INT NOT NULL,
    Quarter INT NOT NULL,
    Month INT NOT NULL,
    MonthName NVARCHAR(50) NOT NULL,
    WeekdayName NVARCHAR(50) NOT NULL,
    DayOfMonth INT NOT NULL
);

-- tabele pomocnicze:
CREATE TABLE Stepaniuk.Months (
    MonthID INT IDENTITY(1,1) PRIMARY KEY,
    MonthName NVARCHAR(50) NOT NULL
);
INSERT INTO Stepaniuk.Months (MonthName) VALUES
('Styczeń'),
('Luty'),
('Marzec'),
('Kwiecień'),
('Maj'),
('Czerwiec'),
('Lipiec'),
('Sierpień'),
('Wrzesień'),
('Październik'),
('Listopad'),
('Grudzień');

CREATE TABLE Stepaniuk.Weekdays (
    WeekdayID INT IDENTITY(1,1) PRIMARY KEY,
    WeekdayName NVARCHAR(50) NOT NULL
);
INSERT INTO Stepaniuk.Weekdays (WeekdayName) VALUES
('Poniedziałek'),
('Wtorek'),
('Środa'),
('Czwartek'),
('Piątek'),
('Sobota'),
('Niedziela');

-- Wypełnienie tabeli wymiaru czasowego
DELETE FROM Stepaniuk.DIM_TIME;

WITH data AS (
    SELECT DISTINCT
        DATEPART(YYYY, soh.OrderDate) * 10000 + DATEPART(MM, soh.OrderDate) * 100 + DATEPART(DD, soh.OrderDate) AS PK_TIME,
        DATEPART(YYYY, soh.OrderDate) AS Year,
    DATEPART(QQ, soh.OrderDate) AS Quarter,
    DATEPART(MM, soh.OrderDate) AS Month,
    m.MonthName AS MonthName,
    d.WeekdayName AS WeekdayName,
    DATEPART(DD, soh.OrderDate) AS DayOfMonth
FROM
    Sales.SalesOrderHeader AS soh
    JOIN Stepaniuk.Months m ON DATEPART(MM, soh.OrderDate) = m.MonthID
    JOIN Stepaniuk.Weekdays d ON DATEPART(WEEKDAY, DATEADD(DAY, -1, soh.OrderDate)) = d.WeekdayID

UNION

SELECT DISTINCT
    DATEPART(YYYY, soh.ShipDate) * 10000 + DATEPART(MM, soh.ShipDate) * 100 + DATEPART(DD, soh.ShipDate) AS PK_TIME,
    DATEPART(YYYY, soh.ShipDate) AS Year,
        DATEPART(QQ, soh.ShipDate) AS Quarter,
        DATEPART(MM, soh.ShipDate) AS Month,
        m.MonthName AS MonthName,
        d.WeekdayName AS WeekdayName,
        DATEPART(DD, soh.ShipDate) AS DayOfMonth
FROM
    Sales.SalesOrderHeader AS soh
    JOIN Stepaniuk.Months m ON DATEPART(MM, soh.ShipDate) = m.MonthID
    JOIN Stepaniuk.Weekdays d ON DATEPART(WEEKDAY, DATEADD(DAY, -1, soh.ShipDate)) = d.WeekdayID
    )
INSERT INTO Stepaniuk.DIM_TIME (PK_TIME, Year, Quarter, Month, MonthName, WeekdayName, DayOfMonth)
SELECT PK_TIME, Year, Quarter, Month, MonthName, WeekdayName, DayOfMonth
FROM data;
    
SELECT *
FROM Stepaniuk.DIM_TIME;

-- Zad. 3. Elementarne czyszczenie danych
-- Zamienić wszystkie wartości NULL:
-- • w kolumnie Color (tabela DIM_PRODUCT) na „Unknown”,
-- • w kolumnie SubCategoryName (tabela DIM_PRODUCT) na „Unknown”.
-- • w kolumnie CountryRegionCode na 000,
-- • w kolumnie Group na „Unknown”

UPDATE Stepaniuk.DIM_PRODUCT
SET Color = COALESCE(Color, 'Unknown'),
WHERE Color IS NULL;

UPDATE Stepaniuk.DIM_PRODUCT
SET SubCategoryName = COALESCE(SubCategoryName, 'Unknown'),
WHERE SubCategoryName IS NULL;

UPDATE Stepaniuk.DIM_CUSTOMER
SET CountryRegionCode = COALESCE(CountryRegionCode, '000'),
WHERE CountryRegionCode IS NULL;

UPDATE Stepaniuk.DIM_CUSTOMER
SET [Group] = COALESCE([Group], 'Unknown'),
WHERE [Group] IS NULL;

-- BŁĘDY I WYJĄTKI
IF NOT EXISTS(
    SELECT *
    FROM INFORMATION_SCHEMA.SCHEMATA
    WHERE SCHEMA_NAME = 'Stepaniuk'
)
BEGIN
    CREATE SCHEMA Stepaniuk;
END


-- select all different salespersonid from factsales
SELECT DISTINCT SalesPersonID
FROM Stepaniuk.FACT_SALES;
