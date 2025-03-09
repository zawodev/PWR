CREATE DATABASE Uslugi;

-- TWORZYMY TABELE

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

CREATE TABLE Zakupy (
    IdZakupu INT IDENTITY(1, 1) PRIMARY KEY, 
    DataZ date NOT NULL,
    CzasZ time NOT NULL,
    IdKlienta INT NOT NULL,
    IdSklepu INT NOT NULL,
    CONSTRAINT FK_IdKlienta_Z FOREIGN KEY (IdKlienta) REFERENCES Klienci(IdKlienta),
    CONSTRAINT FK_IdSklepu_Z FOREIGN KEY (IdSklepu) REFERENCES Sklepy(IdSklepu),
);

CREATE TABLE Nabytki (
    IdNabytku INT IDENTITY(1, 1) PRIMARY KEY,
    Ilosc INT NOT NULL,
    IdOferty INT NOT NULL,
    IdZakupu INT NOT NULL,
    CONSTRAINT Ilosc_N CHECK (Ilosc > 0),
    CONSTRAINT FK_IdOferty_N FOREIGN KEY (IdOferty) REFERENCES Oferty(IdOferty),
    CONSTRAINT FK_IdZakupu_N FOREIGN KEY (IdZakupu) REFERENCES Zakupy(IdZakupu),
);

-- DODAJEMY DANE DO BAZY

INSERT INTO Klienci (Imie, Nazwisko, Telefon) 
VALUES ('Jan', 'Kowalski', '123456789'), 
       ('Anna', 'Nowak', '987654321'), 
       ('Piotr', 'Kowalczyk', '456123789');

INSERT INTO Sklepy (Nazwa, Adres)
VALUES ('Biedronka', 'ul. Kolejowa 1, 00-001 Warszawa'),
       ('Lidl', 'ul. Dworcowa 2, 00-002 Warszawa'),
       ('Auchan', 'ul. Szkolna 3, 00-003 Warszawa');

INSERT INTO Produkty (Nazwa)
VALUES ('Mleko'), 
       ('Chleb'), 
       ('Jogurt'), 
       ('Ser');

INSERT INTO Oferty (Cena, IdProduktu, IdSklepu)
VALUES (2.50, 1, 1),
       (3.00, 2, 1),
       (1.50, 3, 1),
       (4.00, 4, 1),
       (2.00, 1, 2),
       (2.50, 2, 2),
       (1.00, 3, 2),
       (3.50, 4, 2),
       (2.00, 1, 3),
       (2.50, 2, 3),
       (1.00, 3, 3),
       (3.50, 4, 3);

INSERT INTO Zakupy (DataZ, CzasZ, IdKlienta, IdSklepu)
VALUES ('2021-01-01', '12:00:00', 1, 1),
       ('2021-01-02', '13:00:00', 2, 2),
       ('2021-01-03', '14:00:00', 3, 3);

INSERT INTO Nabytki (Ilosc, IdOferty, IdZakupu)
VALUES (2, 1, 1),
       (1, 2, 1),
       (3, 3, 2),
       (1, 4, 2),
       (2, 5, 3),
       (1, 6, 3),
       (3, 7, 3),
       (1, 8, 3),
       (2, 9, 3),
       (1, 10, 3),
       (3, 11, 3),
       (1, 12, 3);

-- PRÓBA DODANIA NIEPOPRAWNYCH DANYCH

-- a) naruszenie ograniczenia NOT NULL
INSERT INTO Klienci (Imie, Nazwisko, Telefon)
VALUES (NULL, 'Kowalski', NULL);

-- poprawnie byłoby tak:
INSERT INTO Klienci (Imie, Nazwisko, Telefon)
VALUES ('Jan', 'Kowalski', NULL);

-- b) naruszenie ograniczenia CHECK
INSERT INTO Oferty (Cena, IdProduktu, IdSklepu)
VALUES (-1, 1, 1);

-- poprawnie byłoby tak:
INSERT INTO Oferty (Cena, IdProduktu, IdSklepu)
VALUES (2.50, 1, 1);

-- c) naruszenie ograniczenia FOREIGN KEY
INSERT INTO Oferty (Cena, IdProduktu, IdSklepu)
VALUES (2.50, 1, 4);

-- poprawnie byłoby tak:
INSERT INTO Oferty (Cena, IdProduktu, IdSklepu)
VALUES (2.50, 1, 1);
