AvgProductsPerOrder :=
DIVIDE(
    SUM( 'Fact Sales'[OrderQuantity] ),
    DISTINCTCOUNT( 'Fact Sales'[SalesOrderNumber] )
)

                    
IIF(
  [Measures].[Order Count] = 0,
  NULL,
  [Measures].[OrderQty] / [Measures].[Order Count]
)

                    
IIF(
  [Measures].[UnitPrice] = 0,
  NULL,
  [Measures].[WeightedQty] / [Measures].[UnitPrice]
)

                    
--AdventureWorks2022 
-- Zad: Oblicz średnią ilość przedmiotów na zamówienie

SELECT 
    AVG(OrderQty) AS AvgOrderQty
FROM
    Sales.SalesOrderDetail
WHERE
    OrderQty IS NOT NULL;



----------------------------------------------------------

CREATE TABLE Stepaniuk.FACT_SALES_2011 (
    FactID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_PRODUCT(ProductID),
    CustomerID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_CUSTOMER(CustomerID),
    SalesPersonID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_SALESPERSON(SalesPersonID),
    OrderDate INT NOT NULL,
    ShipDate INT,
    OrderQty INT NOT NULL,
    UnitPrice MONEY NOT NULL,
    UnitPriceDiscount MONEY NOT NULL,
    LineTotal MONEY NOT NULL
)

CREATE TABLE Stepaniuk.FACT_SALES_2012 (
    FactID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_PRODUCT(ProductID),
    CustomerID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_CUSTOMER(CustomerID),
    SalesPersonID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_SALESPERSON(SalesPersonID),
    OrderDate INT NOT NULL,
    ShipDate INT,
    OrderQty INT NOT NULL,
    UnitPrice MONEY NOT NULL,
    UnitPriceDiscount MONEY NOT NULL,
    LineTotal MONEY NOT NULL
)

CREATE TABLE Stepaniuk.FACT_SALES_2013 (
    FactID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_PRODUCT(ProductID),
    CustomerID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_CUSTOMER(CustomerID),
    SalesPersonID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_SALESPERSON(SalesPersonID),
    OrderDate INT NOT NULL,
    ShipDate INT,
    OrderQty INT NOT NULL,
    UnitPrice MONEY NOT NULL,
    UnitPriceDiscount MONEY NOT NULL,
    LineTotal MONEY NOT NULL
)

CREATE TABLE Stepaniuk.FACT_SALES_2014 (
    FactID INT IDENTITY(1,1) PRIMARY KEY,
    ProductID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_PRODUCT(ProductID),
    CustomerID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_CUSTOMER(CustomerID),
    SalesPersonID INT FOREIGN KEY REFERENCES Stepaniuk.DIM_SALESPERSON(SalesPersonID),
    OrderDate INT NOT NULL,
    ShipDate INT,
    OrderQty INT NOT NULL,
    UnitPrice MONEY NOT NULL,
    UnitPriceDiscount MONEY NOT NULL,
    LineTotal MONEY NOT NULL
)

WITH data AS (
    SELECT 
        Stepaniuk.FACT_SALES.ProductID,
        Stepaniuk.FACT_SALES.CustomerID,
        Stepaniuk.FACT_SALES.SalesPersonID,
        Stepaniuk.FACT_SALES.OrderDate,
        Stepaniuk.FACT_SALES.ShipDate,
        Stepaniuk.FACT_SALES.OrderQty,
        Stepaniuk.FACT_SALES.UnitPrice,
        Stepaniuk.FACT_SALES.UnitPriceDiscount,
        Stepaniuk.FACT_SALES.LineTotal
    FROM
        Stepaniuk.FACT_SALES
    WHERE 
        OrderDate >= 20110101 AND OrderDate < 20120101   
)
INSERT INTO Stepaniuk.FACT_SALES_2011
SELECT * FROM data;

WITH data AS (
    SELECT 
        Stepaniuk.FACT_SALES.ProductID,
        Stepaniuk.FACT_SALES.CustomerID,
        Stepaniuk.FACT_SALES.SalesPersonID,
        Stepaniuk.FACT_SALES.OrderDate,
        Stepaniuk.FACT_SALES.ShipDate,
        Stepaniuk.FACT_SALES.OrderQty,
        Stepaniuk.FACT_SALES.UnitPrice,
        Stepaniuk.FACT_SALES.UnitPriceDiscount,
        Stepaniuk.FACT_SALES.LineTotal
    FROM
        Stepaniuk.FACT_SALES
    WHERE 
        OrderDate >= 20120101 AND OrderDate < 20130101   
)
INSERT INTO Stepaniuk.FACT_SALES_2012
SELECT * FROM data;

WITH data AS (
    SELECT 
        Stepaniuk.FACT_SALES.ProductID,
        Stepaniuk.FACT_SALES.CustomerID,
        Stepaniuk.FACT_SALES.SalesPersonID,
        Stepaniuk.FACT_SALES.OrderDate,
        Stepaniuk.FACT_SALES.ShipDate,
        Stepaniuk.FACT_SALES.OrderQty,
        Stepaniuk.FACT_SALES.UnitPrice,
        Stepaniuk.FACT_SALES.UnitPriceDiscount,
        Stepaniuk.FACT_SALES.LineTotal
    FROM
        Stepaniuk.FACT_SALES
    WHERE 
        OrderDate >= 20130101 AND OrderDate < 20140101   
)
INSERT INTO Stepaniuk.FACT_SALES_2013
SELECT * FROM data;

WITH data AS (
    SELECT 
        Stepaniuk.FACT_SALES.ProductID,
        Stepaniuk.FACT_SALES.CustomerID,
        Stepaniuk.FACT_SALES.SalesPersonID,
        Stepaniuk.FACT_SALES.OrderDate,
        Stepaniuk.FACT_SALES.ShipDate,
        Stepaniuk.FACT_SALES.OrderQty,
        Stepaniuk.FACT_SALES.UnitPrice,
        Stepaniuk.FACT_SALES.UnitPriceDiscount,
        Stepaniuk.FACT_SALES.LineTotal
    FROM
        Stepaniuk.FACT_SALES
    WHERE 
        OrderDate >= 20140101 AND OrderDate < 20150101   
)
INSERT INTO Stepaniuk.FACT_SALES_2014
SELECT * FROM data;

--adventureworks2022
-- wybierz wszystkie rekordy zakupów gdzie były kupowane rowery (oraz ich ilość) z order detail
SELECT 
    sod.ProductID,
    sod.OrderQty AS OrderQty
FROM
    Sales.SalesOrderDetail sod
    JOIN Production.Product p ON sod.ProductID = p.ProductID
WHERE
    p.Name LIKE '%Bike%'