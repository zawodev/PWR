CREATE DATABASE Uslugi;
GO

USE Uslugi;

CREATE TABLE Klienci (
    IdKlienta INT IDENTITY(1, 1) PRIMARY KEY,
    Imie VARCHAR(50) NOT NULL,
    Nazwisko VARCHAR(50) NOT NULL,
    Telefon VARCHAR(15),
);

CREATE TABLE Sklepy (
    IdSklepu INT IDENTITY(1, 1) PRIMARY KEY,
    Nazwa VARCHAR(50) NOT NULL,
    Adres VARCHAR(100) NOT NULL,
);

CREATE TABLE Produkty (
    IdProduktu INT IDENTITY(1, 1) PRIMARY KEY,
    Nazwa VARCHAR(255) NOT NULL,
);

CREATE TABLE Oferty (
    IdOferty INT IDENTITY(1, 1) PRIMARY KEY,
    Cena DECIMAL(10, 2) NOT NULL,
    IdProduktu INT NOT NULL,
    IdSklepu INT NOT NULL,
    CONSTRAINT Cena_O CHECK (Cena > 0),
    CONSTRAINT FK_IdSklepu_O FOREIGN KEY (IdSklepu) REFERENCES Sklepy(IdSklepu),
    CONSTRAINT FK_IdProduktu_O FOREIGN KEY (IdProduktu) REFERENCES Produkty(IdProduktu),
);

