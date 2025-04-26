-- Baza danych: AdventureWorks2022
-- Podstawy Integration Services oraz Analysis Services
-- Zad 1. Przygotowanie schematu
-- W bazie danych należy utworzyć schemat, którego nazwa będzie odpowiadać nazwisku
-- wykonującego ćwiczenie (zapisać zapytanie tworzące ten schemat).

CREATE SCHEMA Stepaniuk;

-- Zad 2. Tworzenie tabel wymiarów i tabeli faktów
-- W nowo utworzonym schemacie utworzyć tabele wymiarów: klienta, produktu i sprzedawcy
-- (zapisać skrypt CREATE TABLE), opisane w następujących schematach:
-- DIM_CUSTOMER (CustomerID, FirstName, LastName, Title, City, TerritoryName, CounrtyRegionCode, Group)
-- DIM_PRODUCT (ProductID, Name, ListPrice, Color, SubCategoryName, CategoryName, Weight, Size, IsPurchased)
-- DIM_SALESPERSON (SalesPersonID, FirstName, LastName, Title, Gender, CountryRegionCode, Group)
-- oraz tabelę faktów:
-- FACT_SALES (ProductID, CustomerID, SalesPersonID, OrderDate, ShipDate, OrderQty, UnitPrice, UnitPriceDiscount, LineTotal)

CREATE TABLE Stepaniuk.DIM_CUSTOMER (
    CustomerID INT PRIMARY KEY,
    FirstName NVARCHAR(50),
    LastName NVARCHAR(50),
    Title NVARCHAR(50),
    City NVARCHAR(50),
    TerritoryName NVARCHAR(50),
    CountryRegionCode NVARCHAR(10),
    [Group] NVARCHAR(50)
);

CREATE TABLE Stepaniuk.DIM_PRODUCT (
    ProductID INT PRIMARY KEY,
    Name NVARCHAR(50) NOT NULL,
    ListPrice MONEY NOT NULL,
    Color NVARCHAR(50),
    SubCategoryName NVARCHAR(50),
    CategoryName NVARCHAR(50),
    Weight DECIMAL(18, 2),
    Size NVARCHAR(50),
    IsPurchased BIT NOT NULL
);

CREATE TABLE Stepaniuk.DIM_SALESPERSON (
    SalesPersonID INT PRIMARY KEY,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Title NVARCHAR(50),
    Gender NVARCHAR(10),
    CountryRegionCode NVARCHAR(10),
    [Group] NVARCHAR(50)
);

CREATE TABLE Stepaniuk.FACT_SALES (
    FactID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT,
    CustomerID INT,
    SalesPersonID INT,
    OrderDate INT NOT NULL,
    ShipDate INT,
    OrderQty INT NOT NULL,
    UnitPrice MONEY NOT NULL,
    UnitPriceDiscount MONEY NOT NULL,
    LineTotal AS (ISNULL(OrderQty, 0) * ISNULL(UnitPrice, 0) * (1 - ISNULL(UnitPriceDiscount, 0)))
);

-- old lab4 facts
CREATE TABLE Stepaniuk.FACT_SALES (
    FactID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_PRODUCT(ProductID),
    CustomerID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_CUSTOMER(CustomerID),
    SalesPersonID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_SALESPERSON(SalesPersonID),
    OrderDate INT NOT NULL,
    ShipDate INT,
    OrderQty INT NOT NULL,
    UnitPrice MONEY NOT NULL,
    UnitPriceDiscount MONEY NOT NULL,
    LineTotal AS (ISNULL(OrderQty, 0) * ISNULL(UnitPrice, 0) * (1 - ISNULL(UnitPriceDiscount, 0)))
);

-- Zad. 3. Wypełnianie danych – denormalizacja źródłowej bazy
-- Wypełnić nowoutworzone tabele danymi znajdującymi się w tabelach źródłowych. Do
-- wypełnienia użyć instrukcji INSERT INTO. Proszę sprawdzić liczbę skopiowanych
-- rekordów.
-- Uwaga 1. Do tabeli DIM_PRODUCT należy także skopiować produkty, które nie mają
-- przypisanej podkategorii.
-- Uwaga 2. Do tabeli FACT_SALES należy skopiować również transakcje, które nie mają
-- sprzedawcy.


WITH data AS (
    SELECT DISTINCT
        c.CustomerID,
        p.FirstName,
        p.LastName,
        p.Title,
        a.City,
        st.Name,
        st.CountryRegionCode,
        st.[Group]
    FROM Sales.Customer c
        LEFT JOIN Person.Person p ON c.PersonID = p.BusinessEntityID
        LEFT JOIN Person.BusinessEntityAddress bea ON p.BusinessEntityID = bea.BusinessEntityID
        LEFT JOIN Person.Address a ON bea.AddressID = a.AddressID
        LEFT JOIN Person.StateProvince sp ON a.StateProvinceID = sp.StateProvinceID
        LEFT JOIN Sales.SalesTerritory st ON c.TerritoryID = st.TerritoryID
        LEFT JOIN Person.AddressType at ON bea.AddressTypeID = at.AddressTypeID
    WHERE at.Name = 'Home' OR at.Name IS NULL
)
INSERT INTO Stepaniuk.DIM_CUSTOMER
SELECT * FROM data;

WITH data AS (
    SELECT DISTINCT
        p.ProductID,
        p.Name,
        p.ListPrice,
        p.Color,
        ps.Name AS SubCategoryName,
        pc.Name AS CategoryName,
        p.Weight,
        p.Size,
        CASE WHEN COUNT(sod.SalesOrderId) > 0 THEN 1 ELSE 0 END AS IsPurchased
    FROM Production.Product p
             LEFT JOIN Production.ProductSubcategory ps ON p.ProductSubcategoryID = ps.ProductSubcategoryID
             LEFT JOIN Production.ProductCategory pc ON ps.ProductCategoryID = pc.ProductCategoryID
             LEFT JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
    GROUP BY
        p.ProductID,
        p.Name,
        p.ListPrice,
        p.Color,
        ps.Name,
        pc.Name,
        p.Weight,
        p.Size
)
INSERT INTO Stepaniuk.DIM_PRODUCT
SELECT * FROM data;

WITH data AS (
    SELECT DISTINCT
        sp.BusinessEntityID,
        p.FirstName,
        p.LastName,
        p.Title,
        e.Gender,
        st.CountryRegionCode,
        st.[Group]
    FROM Person.Person p
        JOIN HumanResources.Employee e ON p.BusinessEntityID = e.BusinessEntityID
        JOIN Sales.SalesPerson sp ON e.BusinessEntityID = sp.BusinessEntityID
        LEFT JOIN Sales.SalesTerritory st ON sp.TerritoryID = st.TerritoryID
)
INSERT INTO Stepaniuk.DIM_SALESPERSON
SELECT * FROM data;

WITH data AS (
    SELECT
        sod.ProductID,
        soh.CustomerID,
        soh.SalesPersonID,
        DATEPART(YYYY, soh.OrderDate) * 10000 + DATEPART(MM, soh.OrderDate) * 100 + DATEPART(DD, soh.OrderDate) AS OrderDate,
        DATEPART(YYYY, soh.ShipDate) * 10000 + DATEPART(MM, soh.ShipDate) * 100 + DATEPART(DD, soh.ShipDate) AS ShipDate,
        sod.OrderQty,
        sod.UnitPrice,
        sod.UnitPriceDiscount
    FROM Sales.SalesOrderHeader soh
        JOIN Sales.SalesOrderDetail sod ON soh.SalesOrderID = sod.SalesOrderID
)
INSERT INTO Stepaniuk.FACT_SALES
SELECT * FROM data;

-- Zad. 4. Więzy integralności
-- 1. Dodać integralność referencyjną i klucze główne do tabel już zdefiniowanych.

ALTER TABLE Stepaniuk.FACT_SALES ADD 
CONSTRAINT FK_ProductID FOREIGN KEY (ProductID) REFERENCES Stepaniuk.DIM_PRODUCT(ProductID),
CONSTRAINT FK_CustomerID FOREIGN KEY (CustomerID) REFERENCES Stepaniuk.DIM_CUSTOMER(CustomerID),
CONSTRAINT FK_SalesPersonID FOREIGN KEY (SalesPersonID) REFERENCES Stepaniuk.DIM_SALESPERSON(SalesPersonID),
CONSTRAINT FK_OrderDate FOREIGN KEY (OrderDate) REFERENCES Stepaniuk.DIM_TIME(PK_TIME),
CONSTRAINT FK_ShipDate FOREIGN KEY (ShipDate) REFERENCES Stepaniuk.DIM_TIME(PK_TIME);


    
    
-- 2. Przygotować instrukcję INSERT INTO, która sprawdzi poprawność integralności referencyjnej oraz klucze główne.
-- 2a) Próba dodania rekordu z nieistniejącym ID klienta
INSERT INTO Stepaniuk.FACT_SALES (ProductID, CustomerID, SalesPersonID, OrderDate, ShipDate, OrderQty, UnitPrice, UnitPriceDiscount)
VALUES (1, 999999, 1, 20230101, 20230102, 10, 100.00, 0.10);
SELECT * FROM Stepaniuk.FACT_SALES WHERE CustomerID = 999999;
-- 2b) Próba dodania rekordu z nieistniejącym ID produktu
INSERT INTO Stepaniuk.FACT_SALES (ProductID, CustomerID, SalesPersonID, OrderDate, ShipDate, OrderQty, UnitPrice, UnitPriceDiscount)
VALUES (999999, 1, 1, 20230101, 20230102, 10, 100.00, 0.10);
SELECT * FROM Stepaniuk.FACT_SALES WHERE ProductID = 999999;
-- 2c) Próba dodania rekordu z nieistniejącym ID sprzedawcy
INSERT INTO Stepaniuk.FACT_SALES (ProductID, CustomerID, SalesPersonID, OrderDate, ShipDate, OrderQty, UnitPrice, UnitPriceDiscount)
VALUES (1, 1, 999999, 20230101, 20230102, 10, 100.00, 0.10);
SELECT * FROM Stepaniuk.FACT_SALES WHERE SalesPersonID = 999999;

-- Zad 5. Tworzenie kostki
-- Należy utworzyć projekt Analysis Services, w którym zostanie przygotowana kostka
-- zawierająca utworzone wymiary (klienta, produktu i sprzedawcy) oraz tabelę faktów.
-- Używając Visual Studio utworzyć projekt typu Analysis Services Project (Menu File -> New
-- Project)
-- a) Dodać źródło danych (Solution Explorer -> Data Sources -> New Data Source), które
-- będzie wskazywało na bazę danych, która przechowuje tabele faktów i wymiarów.
-- Przeanalizować opcje związane z bezpieczeństwem dostępu do danych.
-- b) Utworzyć nowy widok źródła danych (Solution Explorer -> Data Source Views -> New
-- Data Source View). Dodać wcześniej utworzone tabele.
-- c) Utworzyć nową kostkę za pomocą asystenta (Solution Explorer -> Cubes -> New
-- Cube):
-- o Wybrać utworzenie kostki na podstawie istniejących tabel (Use existing tables)
-- o Wybrać, utworzony w poprzednim punkcie, widok źródła danych
-- o Jako tabelę faktów (Measure group tables) wybrać FACT_SALES
-- o Na stronie dotyczącej miar wybrać OrderQty, UnitPriceDiscount, Line Total.
-- Zastanowić się nad użytecznością wybranych miar. Dlaczego nie wszystkie
-- atrybuty tabeli FACT_SALES mogą być użyte jako miary?
-- o Na stronie dotyczącej wymiarów wybrać wszystkie tabele z przedrostkiem
-- DIM.
-- Po utworzeniu kostki dokonać edycji wymiarów (Solution Explorer -> Dimensions lub
-- zakładka Cube Structure -> Dimensions).
-- Dla każdego z wymiarów zdefiniować potrzebne atrybuty. Przykładowo wymiar produkt
-- powinien zawierać: Nazwę, Cenę, Kolor, Podkategorię i Kategorię. W przypadku tabeli
-- Produkt należy zmienić jej definicję i sposób ładowania, tak aby zawierała ona zarówno
-- kategorię jak i podkategorię (jeśli nie zrobiło się tego już podczas pracy z kreatorem dodawania
-- nowej kostki).
