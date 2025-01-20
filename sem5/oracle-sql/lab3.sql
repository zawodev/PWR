-- DROP OLD TABLES

DROP TABLE Dodatki_extraa CASCADE CONSTRAINTS;
DROP TABLE Proby_wykroczeniaa CASCADE CONSTRAINTS;
DROP TABLE Bandyy CASCADE CONSTRAINTS;
DROP TABLE Funkcjee CASCADE CONSTRAINTS;
DROP TABLE Wrogowiee CASCADE CONSTRAINTS;
DROP TABLE Kocuryy CASCADE CONSTRAINTS;
DROP TABLE Wrogowie_kocuroww CASCADE CONSTRAINTS;

-- INITIALIZATION

CREATE TABLE Bandyy (
                        nr_bandy NUMBER(2) CONSTRAINT aban_nrbandy_pk PRIMARY KEY,
                        nazwa VARCHAR2(20) CONSTRAINT aban_nazwa_nn NOT NULL,
                        teren VARCHAR2(15) CONSTRAINT aban_teren_unq UNIQUE,
                        szef_bandy VARCHAR2(15) CONSTRAINT aban_szef_unq UNIQUE
);

CREATE TABLE Funkcjee (
                          funkcja VARCHAR2(10) CONSTRAINT afun_funkcja_pk PRIMARY KEY,
                          min_myszy NUMBER(3) CONSTRAINT afun_minmice_gt_5 CHECK (min_myszy > 5),
                          max_myszy NUMBER(3) CONSTRAINT afun_maxmice_lt_200 CHECK (200 > max_myszy),
                          CONSTRAINT afun_maxmice_ge_min CHECK (max_myszy >= min_myszy)
);

CREATE TABLE Wrogowiee (
                           imie_wroga VARCHAR2(15) CONSTRAINT awro_imie_pk PRIMARY KEY,
                           stopien_wrogosci NUMBER(2) CONSTRAINT awro_wrogosc_values CHECK (stopien_wrogosci BETWEEN 1 AND 10),
                           gatunek VARCHAR2(15),
                           lapowka VARCHAR2(20)
);

CREATE TABLE Kocuryy (
                         imie VARCHAR2(15) CONSTRAINT akoc_imie_nn NOT NULL,
                         plec VARCHAR2(1) CONSTRAINT akoc_plec_values CHECK (plec IN ('M', 'D')),
                         pseudo VARCHAR2(15) CONSTRAINT akoc_pseudo_pk PRIMARY KEY,
                         funkcja VARCHAR2(10) CONSTRAINT akoc_funkcja_fk REFERENCES Funkcjee(funkcja),
                         szef VARCHAR2(15) CONSTRAINT akoc_szef_fk REFERENCES Kocuryy(pseudo),
                         w_stadku_od DATE DEFAULT SYSDATE,
                         przydzial_myszy NUMBER(3),
                         myszy_extra NUMBER(3),
                         nr_bandy NUMBER(2) CONSTRAINT akoc_nr_bandy_fk REFERENCES Bandyy(nr_bandy)
);

CREATE TABLE Wrogowie_kocuroww (
                                   pseudo VARCHAR2(15) CONSTRAINT awrokoc_pseudo_fk REFERENCES Kocuryy(pseudo),
                                   imie_wroga VARCHAR2(15) CONSTRAINT awrokoc_imie_wroga_fk REFERENCES Wrogowiee(imie_wroga),
                                   data_incydentu DATE CONSTRAINT awrokoc_data_incydentu_nn NOT NULL,
                                   opis_incydentu VARCHAR2(50)
);

-- ALTER SESSION

ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

-- FILL DATA (FUNKCJE)

INSERT ALL
INTO Funkcjee VALUES ('SZEFUNIO',90,110)
INTO Funkcjee VALUES ('BANDZIOR',70,90)
INTO Funkcjee VALUES ('LOWCZY',60,70)
INTO Funkcjee VALUES ('LAPACZ',50,60)
INTO Funkcjee VALUES ('KOT',40,50)
INTO Funkcjee VALUES ('MILUSIA',20,30)
INTO Funkcjee VALUES ('DZIELCZY',45,55)
INTO Funkcjee VALUES ('HONOROWA',6,25)
SELECT * FROM dual;

-- FILL DATA (WROGOWIE)

INSERT ALL
INTO Wrogowiee VALUES ('KAZIO',10,'CZLOWIEK','FLASZKA')
INTO Wrogowiee VALUES ('GLUPIA ZOSKA',1,'CZLOWIEK','KORALIK')
INTO Wrogowiee VALUES ('SWAWOLNY DYZIO',7,'CZLOWIEK','GUMA DO ZUCIA')
INTO Wrogowiee VALUES ('BUREK',4,'PIES','KOSC')
INTO Wrogowiee VALUES ('DZIKI BILL',10,'PIES',NULL)
INTO Wrogowiee VALUES ('REKSIO',2,'PIES','KOSC')
INTO Wrogowiee VALUES ('BETHOVEN',1,'PIES','PEDIGRIPALL')
INTO Wrogowiee VALUES ('CHYTRUSEK',5,'LIS','KURCZAK')
INTO Wrogowiee VALUES ('SMUKLA',1,'SOSNA',NULL)
INTO Wrogowiee VALUES ('BAZYLI',3,'KOGUT','KURA DO STADA')
SELECT * FROM dual;

-- FILL DATA (BANDY)

INSERT ALL
INTO Bandyy VALUES (1,'SZEFOSTWO','CALOSC','TYGRYS')
INTO Bandyy VALUES (2,'CZARNI RYCERZE','POLE','LYSY')
INTO Bandyy VALUES (3,'BIALI LOWCY','SAD','ZOMBI')
INTO Bandyy VALUES (4,'LACIACI MYSLIWI','GORKA','RAFA')
INTO Bandyy VALUES (5,'ROCKERSI','ZAGRODA',NULL)
SELECT * FROM dual;

-- FILL DATA (KOCURY) (enable/disable constraint, because of circular reference)

ALTER TABLE Kocuryy DISABLE CONSTRAINT akoc_szef_fk;

INSERT ALL
INTO Kocuryy VALUES ('JACEK','M','PLACEK','LOWCZY','LYSY','2008-12-01',67,NULL,2)
INTO Kocuryy VALUES ('BARI','M','RURA','LAPACZ','LYSY','2009-09-01',56,NULL,2)
INTO Kocuryy VALUES ('MICKA','D','LOLA','MILUSIA','TYGRYS','2009-10-14',25,47,1)
INTO Kocuryy VALUES ('LUCEK','M','ZERO','KOT','KURKA','2010-03-01',43,NULL,3)
INTO Kocuryy VALUES ('SONIA','D','PUSZYSTA','MILUSIA','ZOMBI','2010-11-18',20,35,3)
INTO Kocuryy VALUES ('LATKA','D','UCHO','KOT','RAFA','2011-01-01',40,NULL,4)
INTO Kocuryy VALUES ('DUDEK','M','MALY','KOT','RAFA','2011-05-15',40,NULL,4)
INTO Kocuryy VALUES ('MRUCZEK','M','TYGRYS','SZEFUNIO',NULL,'2002-01-01',103,33,1)
INTO Kocuryy VALUES ('CHYTRY','M','BOLEK','DZIELCZY','TYGRYS','2002-05-05',50,NULL,1)
INTO Kocuryy VALUES ('KOREK','M','ZOMBI','BANDZIOR','TYGRYS','2004-03-16',75,13,3)
INTO Kocuryy VALUES ('BOLEK','M','LYSY','BANDZIOR','TYGRYS','2006-08-15',72,21,2)
INTO Kocuryy VALUES ('ZUZIA','D','SZYBKA','LOWCZY','LYSY','2006-07-21',65,NULL,2)
INTO Kocuryy VALUES ('RUDA','D','MALA','MILUSIA','TYGRYS','2006-09-17',22,42,1)
INTO Kocuryy VALUES ('PUCEK','M','RAFA','LOWCZY','TYGRYS','2006-10-15',65,NULL,4)
INTO Kocuryy VALUES ('PUNIA','D','KURKA','LOWCZY','ZOMBI','2008-01-01',61,NULL,3)
INTO Kocuryy VALUES ('BELA','D','LASKA','MILUSIA','LYSY','2008-02-01',24,28,2)
INTO Kocuryy VALUES ('KSAWERY','M','MAN','LAPACZ','RAFA','2008-07-12',51,NULL,4)
INTO Kocuryy VALUES ('MELA','D','DAMA','LAPACZ','RAFA','2008-11-01',51,NULL,4)
SELECT * FROM dual;

ALTER TABLE Kocuryy ENABLE CONSTRAINT akoc_szef_fk;

-- FILL DATA (WROGOWIE KOCUROW)

INSERT ALL
INTO Wrogowie_Kocuroww VALUES ('TYGRYS','KAZIO','2004-10-13','USILOWAL NABIC NA WIDLY')
INTO Wrogowie_Kocuroww VALUES ('ZOMBI','SWAWOLNY DYZIO','2005-03-07','WYBIL OKO Z PROCY')
INTO Wrogowie_Kocuroww VALUES ('BOLEK','KAZIO','2005-03-29','POSZCZUL BURKIEM')
INTO Wrogowie_Kocuroww VALUES ('SZYBKA','GLUPIA ZOSKA','2006-09-12','UZYLA KOTA JAKO SCIERKI')
INTO Wrogowie_Kocuroww VALUES ('MALA','CHYTRUSEK','2007-03-07','ZALECAL SIE')
INTO Wrogowie_Kocuroww VALUES ('TYGRYS','DZIKI BILL','2007-06-12','USILOWAL POZBAWIC ZYCIA')
INTO Wrogowie_Kocuroww VALUES ('BOLEK','DZIKI BILL','2007-11-10','ODGRYZL UCHO')
INTO Wrogowie_Kocuroww VALUES ('LASKA','DZIKI BILL','2008-12-12','POGRYZL ZE LEDWO SIE WYLIZALA')
INTO Wrogowie_Kocuroww VALUES ('LASKA','KAZIO','2009-01-07','ZLAPAL ZA OGON I ZROBIL WIATRAK')
INTO Wrogowie_Kocuroww VALUES ('DAMA','KAZIO','2009-02-07','CHCIAL OBEDRZEC ZE SKORY')
INTO Wrogowie_Kocuroww VALUES ('MAN','REKSIO','2009-04-14','WYJATKOWO NIEGRZECZNIE OBSZCZEKAL')
INTO Wrogowie_Kocuroww VALUES ('LYSY','BETHOVEN','2009-05-11','NIE PODZIELIL SIE SWOJA KASZA')
INTO Wrogowie_Kocuroww VALUES ('RURA','DZIKI BILL','2009-09-03','ODGRYZL OGON')
INTO Wrogowie_Kocuroww VALUES ('PLACEK','BAZYLI','2010-07-12','DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA')
INTO Wrogowie_Kocuroww VALUES ('PUSZYSTA','SMUKLA','2010-11-19','OBRZUCILA SZYSZKAMI')
INTO Wrogowie_Kocuroww VALUES ('KURKA','BUREK','2010-12-14','POGONIL')
INTO Wrogowie_Kocuroww VALUES ('MALY','CHYTRUSEK','2011-07-13','PODEBRAL PODEBRANE JAJKA')
INTO Wrogowie_Kocuroww VALUES ('UCHO','SWAWOLNY DYZIO','2011-07-14','OBRZUCIL KAMIENIAMI')
SELECT * FROM dual;

-- Bandy: ban_szef_fk
ALTER TABLE Bandyy ADD CONSTRAINT aban_szef_fk FOREIGN KEY(szef_bandy) REFERENCES Kocuryy(pseudo);

COMMIT;





-------------------------- ZADANIA ---------------------------
-- =================                        ==================
--------------------------------------------------------------

SET SERVEROUTPUT ON
SET VERIFY OFF


--zad34 (DZIELCZY jeden, LOWCZY kilka)
DECLARE
funkcja_kocura KOCURY.funkcja%TYPE;
BEGIN
SELECT FUNKCJA INTO funkcja_kocura
FROM KOCURY
WHERE FUNKCJA = UPPER('&nazwa_funkcji');
DBMS_OUTPUT.PUT_LINE('znaleziono kota o funkcji: ' || funkcja_kocura);
EXCEPTION
    WHEN TOO_MANY_ROWS 
        THEN DBMS_OUTPUT.PUT_LINE('TAK znaleziono');
WHEN NO_DATA_FOUND 
        THEN DBMS_OUTPUT.PUT_LINE('NIE znaleziono');
END;


--zad35 (LYSY, RURA, BOLEK, ZERO)
DECLARE
    imie_kocura KocuryT.imie%TYPE;
    przydzial_kocura NUMBER;
    miesiac_kocura NUMBER;
    znaleziony BOOLEAN DEFAULT FALSE;
BEGIN
SELECT 
    imie, 
    (NVL(przydzial_myszy, 0) + NVL(myszy_extra,0)) * 12, EXTRACT(MONTH FROM w_stadku_od)
INTO imie_kocura, przydzial_kocura, miesiac_kocura
FROM KOCURY
WHERE PSEUDO = UPPER('&pseudonim');
IF przydzial_kocura > 700 
    THEN DBMS_OUTPUT.PUT_LINE('calkowity roczny przydzial myszy >700');
ELSIF imie_kocura LIKE '%A%'
    THEN DBMS_OUTPUT.PUT_LINE('imię zawiera litere A');
ELSIF miesiac_kocura = 5 
    THEN DBMS_OUTPUT.PUT_LINE('maj jest miesiacem przystapienia do stada');
ELSE DBMS_OUTPUT.PUT_LINE('nie odpowiada kryteriom');
END IF;
EXCEPTION 
    WHEN NO_DATA_FOUND
        THEN DBMS_OUTPUT.PUT_LINE('brak kota o takim pseudonimie');
WHEN OTHERS 
        THEN DBMS_OUTPUT.PUT_LINE(sqlerrm);
END;


-- zad36 test
DECLARE
CURSOR kCursor IS
SELECT PSEUDO, PRZYDZIAL_MYSZY, FUNKCJEE.MAX_MYSZY
FROM KOCURYY JOIN FUNKCJEE ON KOCURYY.FUNKCJA = FUNKCJEE.FUNKCJA FOR UPDATE OF PRZYDZIAL_MYSZY;

kocur kCursor%ROWTYPE;
suma NUMBER := 0;
zmiany NUMBER := 0;
nowy_przydzial NUMBER;

BEGIN
SELECT SUM(PRZYDZIAL_MYSZY) INTO suma FROM KOCURYY;
LOOP EXIT WHEN suma > 1050;

OPEN kCursor;
LOOP
FETCH kCursor INTO kocur;
    EXIT WHEN kCursor%NOTFOUND;
    nowy_przydzial := ROUND(kocur.PRZYDZIAL_MYSZY * 1.1);
    IF nowy_przydzial > kocur.MAX_MYSZY THEN nowy_przydzial := kocur.MAX_MYSZY;
END IF;
    IF nowy_przydzial > kocur.PRZYDZIAL_MYSZY THEN
UPDATE KOCURYY
SET PRZYDZIAL_MYSZY = nowy_przydzial
WHERE CURRENT OF kCursor;

suma := suma + (nowy_przydzial - kocur.PRZYDZIAL_MYSZY);
zmiany := zmiany + 1;

END IF;
END LOOP;

CLOSE kCursor;
END LOOP;
    DBMS_OUTPUT.PUT_LINE('Calkowity przydzial w stadku: ' || TO_CHAR(suma));
    DBMS_OUTPUT.PUT_LINE('Liczba zmian: ' || TO_CHAR(zmiany));
END;

SELECT IMIE, PRZYDZIAL_MYSZY "Myszki po podwyzce"
FROM KOCURYY
ORDER BY PRZYDZIAL_MYSZY DESC;

ROLLBACK;



--zad37 ()
DECLARE
CURSOR tCursor IS
SELECT pseudo, przydzial_myszy + NVL(myszy_extra, 0) "zjada"
FROM Kocuryy
ORDER BY 2 DESC;
top tCursor%ROWTYPE;
BEGIN
OPEN tCursor;
DBMS_OUTPUT.PUT_LINE('Nr   Pseudonim   Zjada');
DBMS_OUTPUT.PUT_LINE('----------------------');
FOR i IN 1..5
    LOOP
        FETCH tCursor INTO top;
        EXIT WHEN tCursor%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(i) ||'    '|| RPAD(top.pseudo, 8) || '    ' || LPAD(TO_CHAR(top."zjada"), 5));
END LOOP;
END;



--zad38
DECLARE
liczba_szefow           NUMBER := :liczba_szefow;
max_liczba_szefow       NUMBER;
szerokosc               NUMBER := 15;
pseudo_aktualny         KOCURYY.PSEUDO%TYPE;
imie_aktualny           KOCURYY.IMIE%TYPE;
pseudo_nastepny         KOCURYY.SZEF%TYPE;
CURSOR podwladni IS
SELECT PSEUDO, IMIE
FROM KOCURYY
WHERE FUNKCJA IN ('MILUSIA', 'KOT');
BEGIN
SELECT MAX(LEVEL) - 1
INTO max_liczba_szefow
FROM KOCURYY
    CONNECT BY PRIOR SZEF = PSEUDO
START WITH FUNKCJA IN ('KOT', 'MILUSIA');

DBMS_OUTPUT.PUT_LINE('Przykładowy wynik dla liczby przełożonych = ' || liczba_szefow);
liczba_szefow := LEAST(max_liczba_szefow, liczba_szefow);
DBMS_OUTPUT.PUT(RPAD('IMIE ', szerokosc));

FOR licznik IN 1..liczba_szefow LOOP
    DBMS_OUTPUT.PUT(RPAD('|  SZEF ' || licznik, szerokosc));
END LOOP;

DBMS_OUTPUT.PUT_LINE('');
DBMS_OUTPUT.PUT_LINE(RPAD('-', szerokosc * (liczba_szefow + 1), '-'));

FOR kot IN podwladni LOOP
    DBMS_OUTPUT.PUT(RPAD(kot.IMIE, szerokosc));
SELECT SZEF INTO pseudo_nastepny FROM KOCURYY WHERE PSEUDO = kot.PSEUDO;

FOR counter IN 1..liczba_szefow LOOP
    IF pseudo_nastepny IS NULL THEN
        DBMS_OUTPUT.PUT(RPAD('|  ', szerokosc));
ELSE
SELECT IMIE, PSEUDO, SZEF
INTO imie_aktualny, pseudo_aktualny, pseudo_nastepny
FROM KOCURYY
WHERE PSEUDO = pseudo_nastepny;

DBMS_OUTPUT.PUT(RPAD('|  ' || imie_aktualny, szerokosc));
END IF;
END LOOP;
DBMS_OUTPUT.PUT_LINE('');
END LOOP;
END;



--zad39 (2, CZARNI RYCERZE, POLE)
DECLARE
nr_ban              NUMBER:= '&nr_bandy';
naz_ban             BANDYY.NAZWA%TYPE := '&nazwa_bandy';
ter                 BANDYY.TEREN%TYPE := '&terytorium';
liczba_znalezionych NUMBER;
exist_exception     EXCEPTION;
wrong_num_exception EXCEPTION;
wiadomosc_exc       VARCHAR2(30) := '';
BEGIN
    IF nr_ban < 0 THEN RAISE wrong_num_exception;
END IF;

SELECT COUNT(*) INTO liczba_znalezionych
FROM Bandyy
WHERE nr_bandy = nr_ban;
IF liczba_znalezionych <> 0 
    THEN wiadomosc_exc := wiadomosc_exc || ' ' || nr_ban || ',';
END IF;

SELECT COUNT(*) INTO liczba_znalezionych
FROM Bandyy
WHERE nazwa = naz_ban;
IF liczba_znalezionych <> 0 
    THEN wiadomosc_exc := wiadomosc_exc || ' ' || naz_ban || ',';
END IF;

SELECT COUNT(*) INTO liczba_znalezionych
FROM Bandyy
WHERE teren = ter;
IF liczba_znalezionych <> 0 
    THEN wiadomosc_exc := wiadomosc_exc || ' ' || ter || ',';
END IF;
    IF LENGTH(wiadomosc_exc) > 0 THEN
        RAISE exist_exception;
END IF;

INSERT INTO BANDYY(NR_BANDY, NAZWA, TEREN) VALUES (nr_ban, naz_ban, ter);

EXCEPTION
    WHEN wrong_num_exception THEN
        DBMS_OUTPUT.PUT_LINE('Nr bandy musi byc liczba dodatnia');
WHEN exist_exception THEN
        DBMS_OUTPUT.PUT_LINE(TRIM(TRAILING ',' FROM wiadomosc_exc) || ': juz istnieje');
END;
ROLLBACK;



--zad40 i zad44
CREATE OR REPLACE PACKAGE PACK IS
    FUNCTION ObliczPodatek(pseudonim KOCURYY.PSEUDO%TYPE) RETURN NUMBER;
    PROCEDURE AddBanda(nr_ban BANDYY.NR_BANDY%TYPE, naz_ban BANDYY.NAZWA%TYPE, ter BANDYY.TEREN%TYPE);
END PACK;

CREATE OR REPLACE PACKAGE BODY PACK IS
    FUNCTION ObliczPodatek(pseudonim KOCURYY.PSEUDO%TYPE) RETURN NUMBER
        IS
        wysokosc_podatku NUMBER := 0;
        ile_podwladnych  NUMBER := 0;
        ile_wrogow       NUMBER := 0;
        ile_myszy        NUMBER := 0;
BEGIN
SELECT CEIL(0.05 * (NVL(przydzial_myszy,0) + NVL(myszy_extra,0)))
INTO wysokosc_podatku
FROM KOCURYY
WHERE pseudo = pseudonim;

SELECT COUNT(pseudo)
INTO ile_podwladnych
FROM KOCURYY
WHERE szef = pseudonim;

IF ile_podwladnych = 0 THEN
    wysokosc_podatku := wysokosc_podatku + 2;
END IF;

SELECT COUNT(pseudo)
INTO ile_wrogow
FROM WROGOWIE_KOCUROWW
WHERE pseudo = pseudonim;

if ile_wrogow = 0 THEN
    wysokosc_podatku := wysokosc_podatku + 1;
END IF;

SELECT NVL(przydzial_myszy, 0)
INTO ile_myszy
FROM KOCURY
WHERE pseudo = pseudonim;

IF ile_myszy > 60 THEN
    wysokosc_podatku := wysokosc_podatku + 3;
END IF;

RETURN wysokosc_podatku;
END;

PROCEDURE AddBanda(nr_ban BANDYY.NR_BANDY%TYPE, naz_ban BANDYY.NAZWA%TYPE, ter BANDYY.TEREN%TYPE)
IS
liczba_znalezionych NUMBER;
exist_exception EXCEPTION;
wrong_num_exception EXCEPTION;
wiadomosc_exc VARCHAR2(30) := '';
BEGIN
IF nr_ban < 0 THEN 
    RAISE wrong_num_exception;
END IF;

SELECT COUNT(*)
INTO liczba_znalezionych
FROM Bandyy
WHERE nr_bandy = nr_ban;

IF liczba_znalezionych <> 0 
    THEN wiadomosc_exc := wiadomosc_exc || ' ' || nr_ban || ',';
END IF;

SELECT COUNT(*)
INTO liczba_znalezionych
FROM Bandyy
WHERE nazwa = naz_ban;

IF liczba_znalezionych <> 0 
    THEN wiadomosc_exc := wiadomosc_exc || ' ' || naz_ban || ',';
END IF;

SELECT COUNT(*)
INTO liczba_znalezionych
FROM Bandyy
WHERE teren = ter;

IF liczba_znalezionych <> 0 
    THEN wiadomosc_exc := wiadomosc_exc || ' ' || ter || ',';
END IF;

IF LENGTH(wiadomosc_exc) > 0 THEN
    RAISE exist_exception;
END IF;

INSERT INTO BANDYY(NR_BANDY, NAZWA, TEREN) VALUES (nr_ban, naz_ban, ter);
EXCEPTION
WHEN wrong_num_exception THEN
    DBMS_OUTPUT.PUT_LINE('Nr bandy musi byc liczba dodatnia');
WHEN exist_exception THEN
    DBMS_OUTPUT.PUT_LINE(TRIM(TRAILING ',' FROM wiadomosc_exc) || ': juz istnieje');
END;
END PACK;

--zad40
EXECUTE PACK.AddBanda(2, 'CZARNI RYCERZE', 'POLE');
EXECUTE PACK.AddBanda(1, 'SZEFOSTWO', 'COS');
EXECUTE PACK.AddBanda(10, 'NEWNAME', 'SAD');
EXECUTE PACK.AddBanda(11, 'JAJKO', 'KURA');
SELECT * FROM bandy;

ROLLBACK;

--zad44
BEGIN
FOR kot IN (SELECT pseudo FROM Kocuryy)
    LOOP
        DBMS_OUTPUT.PUT_LINE(RPAD(kot.pseudo, 8) || ' podatek wynosi: ' || PACK.ObliczPodatek(kot.pseudo));
END LOOP;
END;



--zad41
CREATE OR REPLACE TRIGGER trg_bandy_increment
BEFORE INSERT ON BANDYY
FOR EACH ROW
DECLARE
max_nr_bandy NUMBER;
BEGIN
SELECT NVL(MAX(nr_bandy), 0) INTO max_nr_bandy FROM BANDYY;
:NEW.nr_bandy := max_nr_bandy + 1;
END;

EXECUTE PACK.AddBanda(NULL, 'NOWA BANDA 1', 'jakies nowe');
EXECUTE PACK.AddBanda(NULL, 'NOWA BANDA 2', 'lyse pole');
EXECUTE PACK.AddBanda(99, 'NOWA BANDA 3', 'inne nowe pole');

SELECT * FROM BANDYY;

ROLLBACK;



--zad42a
CREATE OR REPLACE PACKAGE wirus IS
    kara NUMBER := 0;
    nagroda NUMBER := 0;
    przydzial_tygrysa KOCURYY.PRZYDZIAL_MYSZY%TYPE;
END;

CREATE OR REPLACE TRIGGER trg_wirus_bef_update
    BEFORE UPDATE OF PRZYDZIAL_MYSZY
           ON KOCURYY
DECLARE
BEGIN
SELECT PRZYDZIAL_MYSZY INTO wirus.przydzial_tygrysa FROM KOCURYY WHERE pseudo = 'TYGRYS';
END;

CREATE OR REPLACE TRIGGER trg_wirus_bef_update_row
    BEFORE UPDATE OF PRZYDZIAL_MYSZY
           ON KOCURYY
               FOR EACH ROW
DECLARE
BEGIN
    IF :NEW.funkcja = 'MILUSIA' THEN
        IF :NEW.przydzial_myszy <= :OLD.przydzial_myszy THEN
            DBMS_OUTPUT.PUT_LINE('brak zmiany');
            :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
        ELSIF :NEW.przydzial_myszy - :OLD.przydzial_myszy < 0.1 * wirus.przydzial_tygrysa THEN
            DBMS_OUTPUT.PUT_LINE('podwyzka mniejsza niz 10% tygrysa');
            :NEW.przydzial_myszy := :NEW.przydzial_myszy + ROUND(0.1 * wirus.przydzial_tygrysa);
            :NEW.myszy_extra := NVL(:NEW.myszy_extra, 0) + 5;
            wirus.kara := wirus.kara + ROUND(0.1 * wirus.przydzial_tygrysa);
ELSE
            wirus.nagroda := wirus.nagroda + 5;
END IF;
END IF;
END;

CREATE OR REPLACE TRIGGER trg_wirus_aft_update
    AFTER UPDATE OF PRZYDZIAL_MYSZY
          ON KOCURYY
DECLARE
przydzial KOCURYY.PRZYDZIAL_MYSZY%TYPE;
ekstra KOCURYY.MYSZY_EXTRA%TYPE;
BEGIN
SELECT PRZYDZIAL_MYSZY, MYSZY_EXTRA
INTO przydzial, ekstra
FROM KOCURYY
WHERE pseudo = 'TYGRYS';

przydzial := przydzial - wirus.kara;
ekstra := ekstra + wirus.nagroda;
    
IF wirus.kara <> 0 OR wirus.nagroda <> 0 THEN
    wirus.kara := 0;
    wirus.nagroda := 0;
UPDATE KOCURYY
SET
    PRZYDZIAL_MYSZY = przydzial,
    MYSZY_EXTRA = ekstra
WHERE pseudo = 'TYGRYS';
END IF;
END;

SELECT *
FROM KOCURYY
WHERE PSEUDO IN ('TYGRYS') OR FUNKCJA IN ('MILUSIA');

UPDATE kocuryy
SET przydzial_myszy = przydzial_myszy - 10
WHERE funkcja = 'MILUSIA';

SELECT *
FROM KOCURYY
WHERE PSEUDO IN ('TYGRYS') OR FUNKCJA IN ('MILUSIA');

UPDATE Kocuryy
SET przydzial_myszy = przydzial_myszy + 2
WHERE funkcja = 'MILUSIA';

SELECT *
FROM KOCURYY
WHERE PSEUDO IN ('TYGRYS') OR FUNKCJA IN ('MILUSIA');

UPDATE Kocuryy
SET przydzial_myszy = przydzial_myszy + 50
WHERE funkcja = 'MILUSIA';

SELECT *
FROM KOCURYY
WHERE PSEUDO IN ('TYGRYS') OR FUNKCJA IN ('MILUSIA');

ROLLBACK;

DROP TRIGGER TRG_WIRUS_AFT_UPDATE;
DROP TRIGGER TRG_WIRUS_BEF_UPDATE;
DROP TRIGGER TRG_WIRUS_BEF_UPDATE_ROW;
DROP PACKAGE WIRUS;


--zad42b
CREATE OR REPLACE TRIGGER trg_wirus_comp
    FOR UPDATE OF PRZYDZIAL_MYSZY
        ON KOCURYY
            COMPOUND TRIGGER
            przydzial_tygrysa KOCURYY.PRZYDZIAL_MYSZY%TYPE;
ekstra KOCURYY.MYSZY_EXTRA%TYPE;
    kara NUMBER := 0;
    nagroda NUMBER := 0;
    
BEFORE STATEMENT IS
BEGIN
SELECT przydzial_myszy INTO przydzial_tygrysa
FROM KOCURYY
WHERE pseudo = 'TYGRYS';
END BEFORE STATEMENT;

BEFORE EACH ROW IS
BEGIN
    IF :NEW.funkcja = 'MILUSIA' THEN
        IF :NEW.przydzial_myszy <= :OLD.przydzial_myszy THEN
            DBMS_OUTPUT.PUT_LINE('brak zmiany');
            :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
        ELSIF :NEW.przydzial_myszy - :OLD.przydzial_myszy < 0.1 * przydzial_tygrysa THEN
            DBMS_OUTPUT.PUT_LINE('podwyzka mniejsza niz 10% tygrysa');
            :NEW.przydzial_myszy := :NEW.przydzial_myszy + ROUND(0.1 * przydzial_tygrysa);
            :NEW.myszy_extra := NVL(:NEW.myszy_extra, 0) + 5;
            kara := kara + ROUND(0.1 * przydzial_tygrysa);
ELSE
            nagroda := nagroda + 5;
END IF;
END IF;
END BEFORE EACH ROW;

AFTER STATEMENT IS
BEGIN
SELECT myszy_extra INTO ekstra
FROM KOCURYY
WHERE pseudo = 'TYGRYS';
przydzial_tygrysa := przydzial_tygrysa - kara;
    ekstra := ekstra + nagroda;
    IF kara <> 0 OR nagroda <> 0 THEN
        kara := 0;
        nagroda := 0;
UPDATE KOCURYY
SET przydzial_myszy = przydzial_tygrysa,
    myszy_extra = ekstra
WHERE pseudo = 'TYGRYS';
END IF;
END AFTER STATEMENT;
END;

SELECT *
FROM KOCURYY
WHERE PSEUDO IN ('TYGRYS') OR FUNKCJA IN ('MILUSIA');

UPDATE Kocuryy
SET przydzial_myszy = przydzial_myszy - 10
WHERE funkcja = 'MILUSIA';

SELECT *
FROM KOCURYY
WHERE PSEUDO IN ('TYGRYS') OR FUNKCJA IN ('MILUSIA');

UPDATE Kocuryy
SET przydzial_myszy = przydzial_myszy + 2
WHERE funkcja = 'MILUSIA';

SELECT *
FROM KOCURYY
WHERE PSEUDO IN ('TYGRYS') OR FUNKCJA IN ('MILUSIA');

UPDATE Kocuryy
SET przydzial_myszy = przydzial_myszy + 50
WHERE funkcja = 'MILUSIA';

SELECT *
FROM KOCURYY
WHERE PSEUDO IN ('TYGRYS') OR FUNKCJA IN ('MILUSIA');

ROLLBACK;

DROP TRIGGER trg_wirus_comp;


--zad43 
DECLARE
CURSOR funkcje IS
SELECT
    funkcja,
    SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) suma_fun
FROM KOCURYY
GROUP BY funkcja
ORDER BY funkcja;

CURSOR ilosc_kocurow_cursor IS
SELECT
    COUNT(*) ilosc,
    SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) sumaMyszy
FROM Kocuryy, Bandyy WHERE Kocuryy.nr_bandy = Bandyy.nr_bandy
GROUP BY Bandyy.nazwa, Kocuryy.plec
ORDER BY Bandyy.nazwa, plec;

CURSOR band_func_cursor IS
SELECT
    SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) sumaMyszy,
    Kocuryy.Funkcja funkcja,
    Bandyy.nazwa naz,
    Kocuryy.plec pl
FROM Kocuryy, Bandyy WHERE Kocuryy.nr_bandy = Bandyy.nr_bandy
GROUP BY Bandyy.nazwa, Kocuryy.plec, Kocuryy.funkcja
ORDER BY Bandyy.nazwa, Kocuryy.plec, Kocuryy.funkcja;

ilosc NUMBER;
suma NUMBER;
il ilosc_kocurow_cursor%ROWTYPE;
poszegolny_kot band_func_cursor%ROWTYPE;
BEGIN
    DBMS_OUTPUT.put('NAZWA BANDY       PLEC  ILE   ');
FOR fun IN funkcje
    LOOP
        DBMS_OUTPUT.put(RPAD(fun.funkcja, 10));
END LOOP;
    DBMS_OUTPUT.put_line('   SUMA');
    DBMS_OUTPUT.put('---------------- ------ ----');
FOR fun IN funkcje
        LOOP
            DBMS_OUTPUT.put(' ---------');
END LOOP;
    
    DBMS_OUTPUT.put_line(' --------');

OPEN band_func_cursor;
OPEN ilosc_kocurow_cursor;
FETCH band_func_cursor INTO poszegolny_kot;
FOR banda IN (SELECT nazwa, NR_BANDY FROM BANDYY WHERE nazwa <> 'ROCKERSI' ORDER BY nazwa) LOOP
    FOR ple IN (SELECT PLEC FROM KOCURYY GROUP BY PLEC ORDER BY PLEC ) LOOP 
        DBMS_OUTPUT.put(CASE WHEN ple.plec = 'M' THEN RPAD(' ', 18) ELSE RPAD(banda.nazwa, 18) END);
        DBMS_OUTPUT.put(CASE WHEN ple.plec = 'M' THEN 'Kocor' ELSE 'Kotka' END);

FETCH ilosc_kocurow_cursor INTO il;
DBMS_OUTPUT.put(LPAD(il.ilosc, 4));
FOR fun IN funkcje LOOP
    IF fun.funkcja = poszegolny_kot.funkcja AND banda.nazwa = poszegolny_kot.naz AND ple.plec = poszegolny_kot.pl
    THEN DBMS_OUTPUT.put(LPAD(NVL(poszegolny_kot.sumaMyszy, 0), 10));
FETCH band_func_cursor INTO poszegolny_kot;
ELSE
    DBMS_OUTPUT.put(LPAD(NVL(0, 0), 10));
END IF;
END LOOP;
DBMS_OUTPUT.put(LPAD(NVL(il.sumaMyszy, 0), 10));
DBMS_OUTPUT.new_line();
END LOOP;
END LOOP;
CLOSE ilosc_kocurow_cursor;
CLOSE band_func_cursor;
DBMS_OUTPUT.put('Z---------------- ------ ----');
FOR fun IN funkcje LOOP
    DBMS_OUTPUT.put(' ---------');
END LOOP;
DBMS_OUTPUT.put_line(' --------');
DBMS_OUTPUT.put('Zjada razem                ');
FOR fun IN funkcje LOOP            
    DBMS_OUTPUT.put(LPAD(NVL(fun.suma_fun, 0), 10));
END LOOP;
SELECT SUM(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)) INTO suma FROM Kocuryy;
DBMS_OUTPUT.put(LPAD(suma, 10));
    DBMS_OUTPUT.new_line();
END;


--zad45
CREATE TABLE Dodatki_extra(
                              pseudo VARCHAR2(15) CONSTRAINT dodatki_pseudo_fk REFERENCES Kocuryy(pseudo),
                              dod_extra NUMBER(3) DEFAULT 0
);

CREATE OR REPLACE TRIGGER trg_kara_tygrysa
    AFTER UPDATE OF PRZYDZIAL_MYSZY ON KOCURYY
DECLARE
CURSOR milusie_cursor IS
SELECT pseudo
FROM KOCURYY
WHERE funkcja = 'MILUSIA';
BEGIN
    IF LOGIN_USER <> 'TYGRYS' THEN
        FOR milus IN milusie_cursor LOOP
            MERGE INTO DODATKI_EXTRA dodatki
            USING (SELECT milus.pseudo AS pseudo FROM DUAL) src
            ON (dodatki.pseudo = src.pseudo)
            WHEN MATCHED THEN
UPDATE SET dodatki.dod_extra = dodatki.dod_extra - 10
    WHEN NOT MATCHED THEN
INSERT (pseudo, dod_extra) VALUES (src.pseudo, -10);
END LOOP;
END IF;
END;

UPDATE KOCURYY
SET PRZYDZIAL_MYSZY = 30
WHERE pseudo = 'MALA';

UPDATE KOCURYY
SET przydzial_myszy = 200
WHERE pseudo = 'MALA';

SELECT *
FROM KOCURYY
WHERE FUNKCJA = 'MILUSIA';

SELECT * FROM Dodatki_extra;

ROLLBACK;

DROP TABLE Dodatki_extra;
DROP TRIGGER trg_kara_tygrysa;

--zad 46
CREATE TABLE Proby_wykroczeniaa
(
    kto VARCHAR2(15) NOT NULL,
    kiedy DATE NOT NULL,
    jakiemu VARCHAR2(15) NOT NULL,
    operacja VARCHAR2(15) NOT NULL
);

CREATE OR REPLACE TRIGGER trg_monitor_wykroczenia
BEFORE INSERT OR UPDATE OF PRZYDZIAL_MYSZY ON KOCURYY
    FOR EACH ROW
DECLARE
min_mysz FUNKCJE.MIN_MYSZY%TYPE;
max_mysz FUNKCJE.MAX_MYSZY%TYPE;
curr_data DATE DEFAULT SYSDATE;
zdarzenie VARCHAR2(15);
BEGIN
SELECT MIN_MYSZY, MAX_MYSZY
INTO min_mysz, max_mysz
FROM FUNKCJEE
WHERE FUNKCJA = :NEW.FUNKCJA;

IF :NEW.PRZYDZIAL_MYSZY > max_mysz OR :NEW.PRZYDZIAL_MYSZY < min_mysz THEN
        IF INSERTING THEN 
            zdarzenie := 'INSERT';
        ELSIF UPDATING THEN
            zdarzenie := 'UPDATE';
END IF;

INSERT INTO Proby_wykroczeniaa (kto, kiedy, jakiemu, operacja)
VALUES (ORA_LOGIN_USER, curr_data, :NEW.PSEUDO, zdarzenie);

DBMS_OUTPUT.PUT_LINE('Przydział myszy jest poza zakresem dopuszczalnym. Zmiana odrzucona.');
        :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
END IF;
END;

--tests
UPDATE KOCURYY
SET PRZYDZIAL_MYSZY = 990
WHERE IMIE = 'JACEK';

INSERT INTO Kocuryy VALUES ('JAJEK','M','MAJEK','KOT','RAFA','2011-05-15',110,NULL,4);


SELECT * FROM Kocuryy;
SELECT * FROM Proby_wykroczeniaa;


ROLLBACK;

DROP TABLE Proby_wykroczeniaa;
DROP TRIGGER trg_monitor_wykroczenia;


