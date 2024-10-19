DROP TABLE Pierwsze CASCADE CONSTRAINTS;
DROP TABLE Bandy CASCADE CONSTRAINTS;
DROP TABLE Funkcje CASCADE CONSTRAINTS;
DROP TABLE Wrogowie CASCADE CONSTRAINTS;
DROP TABLE Kocury CASCADE CONSTRAINTS;
DROP TABLE Wrogowie_kocurow CASCADE CONSTRAINTS;

CREATE TABLE Bandy
(
nr_bandy NUMBER(2) CONSTRAINT ban_nrb_pk PRIMARY KEY,
nazwa VARCHAR2(20) CONSTRAINT ban_naz_nn NOT NULL,
teren VARCHAR2(15) CONSTRAINT ban_ter_unq UNIQUE,
szef_bandy VARCHAR2(15) CONSTRAINT ban_sze_unq UNIQUE 
);

CREATE TABLE Funkcje
(
funkcja VARCHAR2(10) CONSTRAINT fun_fun_pk PRIMARY KEY,
min_myszy NUMBER(3) CONSTRAINT fun_min_ch CHECK (min_myszy>5),
max_myszy NUMBER(3) CONSTRAINT fun_max_ch1 CHECK (200>max_myszy),
CONSTRAINT fun_max_ch2 CHECK (max_myszy>=min_myszy)
);

CREATE TABLE Wrogowie
(
imie_wroga VARCHAR2(15) CONSTRAINT wro_imi_pk PRIMARY KEY,
stopien_wrogosci NUMBER(2) CONSTRAINT wro_sto_zak CHECK (stopien_wrogosci BETWEEN 1 AND 10),
gatunek VARCHAR2(15),
lapowka VARCHAR2(20)
);

CREATE TABLE Kocury
(
imie VARCHAR2(15) CONSTRAINT koc_imi_nn NOT NULL,
plec VARCHAR2(1) CONSTRAINT koc_ple_mk CHECK (plec IN ('M', 'D')),
pseudo VARCHAR2(15) CONSTRAINT koc_pse_pk PRIMARY KEY,
funkcja VARCHAR2(10) CONSTRAINT koc_fun_fk REFERENCES Funkcje(funkcja),
szef VARCHAR2(15) CONSTRAINT koc_sze_fk REFERENCES Kocury(pseudo),
w_stadku_od DATE DEFAULT SYSDATE,
przydzial_myszy NUMBER(3),
myszy_extra NUMBER(3),
nr_bandy NUMBER(2) CONSTRAINT koc_nrb_fk REFERENCES Bandy(nr_bandy)
);

CREATE TABLE Wrogowie_kocurow
(
pseudo VARCHAR2(15) REFERENCES Kocury(pseudo),
imie_wroga VARCHAR2(15) REFERENCES Wrogowie(imie_wroga),
data_incydentu DATE CONSTRAINT wro_dat_nn NOT NULL,
opis_incydentu VARCHAR2(50)
);

ALTER TABLE Bandy ADD CONSTRAINT ban_sze_fk FOREIGN KEY(szef_bandy) REFERENCES Kocury(pseudo);


ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';


INSERT ALL
INTO Kocury(imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_ekstra, nr_bandy) VALUES ('JACEK','M','PLACEK','LOWCZY','LYSY','2008-12-01',67,NULL,2)
INTO Kocury(imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_ekstra, nr_bandy) VALUES ('JACEK','M','PLACEK','LOWCZY','LYSY','2008-12-01',67,NULL,2)
INTO Kocury(imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_ekstra, nr_bandy) VALUES ('JACEK','M','PLACEK','LOWCZY','LYSY','2008-12-01',67,NULL,2)

INSERT ALL INTO Kocury(imie, plec, pseudo, funkcja, szef, w_stadku_od, przydzial_myszy, myszy_ekstra, nr_bandy)
VALUES ('JACEK','M','PLACEK','LOWCZY','LYSY','2008-12-01',67,NULL,2)
VALUES ('JACEK','M','PLACEK','LOWCZY','LYSY','2008-12-01',67,NULL,2)
VALUES ('JACEK','M','PLACEK','LOWCZY','LYSY','2008-12-01',67,NULL,2)
