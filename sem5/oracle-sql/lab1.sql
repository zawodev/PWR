-- DROP OLD TABLES

DROP TABLE Pierwsze CASCADE CONSTRAINTS;
DROP TABLE Bandy CASCADE CONSTRAINTS;
DROP TABLE Funkcje CASCADE CONSTRAINTS;
DROP TABLE Wrogowie CASCADE CONSTRAINTS;
DROP TABLE Kocury CASCADE CONSTRAINTS;
DROP TABLE Wrogowie_kocurow CASCADE CONSTRAINTS;

-- INITIALIZATION

CREATE TABLE Bandy (
nr_bandy NUMBER(2) CONSTRAINT ban_nrbandy_pk PRIMARY KEY,
nazwa VARCHAR2(20) CONSTRAINT ban_nazwa_nn NOT NULL,
teren VARCHAR2(15) CONSTRAINT ban_teren_unq UNIQUE,
szef_bandy VARCHAR2(15) CONSTRAINT ban_szef_unq UNIQUE 
);

CREATE TABLE Funkcje (
funkcja VARCHAR2(10) CONSTRAINT fun_funkcja_pk PRIMARY KEY,
min_myszy NUMBER(3) CONSTRAINT fun_minmice_gt_5 CHECK (min_myszy > 5),
max_myszy NUMBER(3) CONSTRAINT fun_maxmice_lt_200 CHECK (200 > max_myszy),
CONSTRAINT fun_maxmice_ge_min CHECK (max_myszy >= min_myszy)
);

CREATE TABLE Wrogowie (
imie_wroga VARCHAR2(15) CONSTRAINT wro_imie_pk PRIMARY KEY,
stopien_wrogosci NUMBER(2) CONSTRAINT wro_wrogosc_values CHECK (stopien_wrogosci BETWEEN 1 AND 10),
gatunek VARCHAR2(15),
lapowka VARCHAR2(20)
);

CREATE TABLE Kocury (
imie VARCHAR2(15) CONSTRAINT koc_imie_nn NOT NULL,
plec VARCHAR2(1) CONSTRAINT koc_plec_values CHECK (plec IN ('M', 'D')),
pseudo VARCHAR2(15) CONSTRAINT koc_pseudo_pk PRIMARY KEY,
funkcja VARCHAR2(10) CONSTRAINT koc_funkcja_fk REFERENCES Funkcje(funkcja),
szef VARCHAR2(15) CONSTRAINT koc_szef_fk REFERENCES Kocury(pseudo),
w_stadku_od DATE DEFAULT SYSDATE,
przydzial_myszy NUMBER(3),
myszy_extra NUMBER(3),
nr_bandy NUMBER(2) CONSTRAINT koc_nr_bandy_fk REFERENCES Bandy(nr_bandy)
);

CREATE TABLE Wrogowie_kocurow (
pseudo VARCHAR2(15) CONSTRAINT wrokoc_pseudo_fk REFERENCES Kocury(pseudo),
imie_wroga VARCHAR2(15) CONSTRAINT wrokoc_imie_wroga_fk REFERENCES Wrogowie(imie_wroga),
data_incydentu DATE CONSTRAINT wrokoc_data_incydentu_nn NOT NULL,
opis_incydentu VARCHAR2(50)
);

-- ALTER SESSION

ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

-- FILL DATA (FUNKCJE)

INSERT ALL
INTO Funkcje VALUES ('SZEFUNIO',90,110)
INTO Funkcje VALUES ('BANDZIOR',70,90)
INTO Funkcje VALUES ('LOWCZY',60,70)
INTO Funkcje VALUES ('LAPACZ',50,60)
INTO Funkcje VALUES ('KOT',40,50)
INTO Funkcje VALUES ('MILUSIA',20,30)
INTO Funkcje VALUES ('DZIELCZY',45,55)
INTO Funkcje VALUES ('HONOROWA',6,25)
SELECT * FROM dual;

-- FILL DATA (WROGOWIE)

INSERT ALL
INTO Wrogowie VALUES ('KAZIO',10,'CZLOWIEK','FLASZKA')
INTO Wrogowie VALUES ('GLUPIA ZOSKA',1,'CZLOWIEK','KORALIK')
INTO Wrogowie VALUES ('SWAWOLNY DYZIO',7,'CZLOWIEK','GUMA DO ZUCIA')
INTO Wrogowie VALUES ('BUREK',4,'PIES','KOSC')
INTO Wrogowie VALUES ('DZIKI BILL',10,'PIES',NULL)
INTO Wrogowie VALUES ('REKSIO',2,'PIES','KOSC')
INTO Wrogowie VALUES ('BETHOVEN',1,'PIES','PEDIGRIPALL')
INTO Wrogowie VALUES ('CHYTRUSEK',5,'LIS','KURCZAK')
INTO Wrogowie VALUES ('SMUKLA',1,'SOSNA',NULL)
INTO Wrogowie VALUES ('BAZYLI',3,'KOGUT','KURA DO STADA')
SELECT * FROM dual;

-- FILL DATA (BANDY)

INSERT ALL
INTO Bandy VALUES (1,'SZEFOSTWO','CALOSC','TYGRYS')
INTO Bandy VALUES (2,'CZARNI RYCERZE','POLE','LYSY')
INTO Bandy VALUES (3,'BIALI LOWCY','SAD','ZOMBI')
INTO Bandy VALUES (4,'LACIACI MYSLIWI','GORKA','RAFA')
INTO Bandy VALUES (5,'ROCKERSI','ZAGRODA',NULL)
SELECT * FROM dual;

-- FILL DATA (KOCURY) (enable/disable constraint, because of circular reference)

ALTER TABLE Kocury DISABLE CONSTRAINT koc_szef_fk;

INSERT ALL
INTO Kocury VALUES ('JACEK','M','PLACEK','LOWCZY','LYSY','2008-12-01',67,NULL,2)
INTO Kocury VALUES ('BARI','M','RURA','LAPACZ','LYSY','2009-09-01',56,NULL,2)
INTO Kocury VALUES ('MICKA','D','LOLA','MILUSIA','TYGRYS','2009-10-14',25,47,1)
INTO Kocury VALUES ('LUCEK','M','ZERO','KOT','KURKA','2010-03-01',43,NULL,3)
INTO Kocury VALUES ('SONIA','D','PUSZYSTA','MILUSIA','ZOMBI','2010-11-18',20,35,3)
INTO Kocury VALUES ('LATKA','D','UCHO','KOT','RAFA','2011-01-01',40,NULL,4)
INTO Kocury VALUES ('DUDEK','M','MALY','KOT','RAFA','2011-05-15',40,NULL,4)
INTO Kocury VALUES ('MRUCZEK','M','TYGRYS','SZEFUNIO',NULL,'2002-01-01',103,33,1)
INTO Kocury VALUES ('CHYTRY','M','BOLEK','DZIELCZY','TYGRYS','2002-05-05',50,NULL,1)
INTO Kocury VALUES ('KOREK','M','ZOMBI','BANDZIOR','TYGRYS','2004-03-16',75,13,3)
INTO Kocury VALUES ('BOLEK','M','LYSY','BANDZIOR','TYGRYS','2006-08-15',72,21,2)
INTO Kocury VALUES ('ZUZIA','D','SZYBKA','LOWCZY','LYSY','2006-07-21',65,NULL,2)
INTO Kocury VALUES ('RUDA','D','MALA','MILUSIA','TYGRYS','2006-09-17',22,42,1)
INTO Kocury VALUES ('PUCEK','M','RAFA','LOWCZY','TYGRYS','2006-10-15',65,NULL,4)
INTO Kocury VALUES ('PUNIA','D','KURKA','LOWCZY','ZOMBI','2008-01-01',61,NULL,3)
INTO Kocury VALUES ('BELA','D','LASKA','MILUSIA','LYSY','2008-02-01',24,28,2)
INTO Kocury VALUES ('KSAWERY','M','MAN','LAPACZ','RAFA','2008-07-12',51,NULL,4)
INTO Kocury VALUES ('MELA','D','DAMA','LAPACZ','RAFA','2008-11-01',51,NULL,4)
SELECT * FROM dual;

ALTER TABLE Kocury ENABLE CONSTRAINT koc_szef_fk;

-- FILL DATA (WROGOWIE KOCUROW)

INSERT ALL
INTO Wrogowie_Kocurow VALUES ('TYGRYS','KAZIO','2004-10-13','USILOWAL NABIC NA WIDLY')
INTO Wrogowie_Kocurow VALUES ('ZOMBI','SWAWOLNY DYZIO','2005-03-07','WYBIL OKO Z PROCY')
INTO Wrogowie_Kocurow VALUES ('BOLEK','KAZIO','2005-03-29','POSZCZUL BURKIEM')
INTO Wrogowie_Kocurow VALUES ('SZYBKA','GLUPIA ZOSKA','2006-09-12','UZYLA KOTA JAKO SCIERKI')
INTO Wrogowie_Kocurow VALUES ('MALA','CHYTRUSEK','2007-03-07','ZALECAL SIE')
INTO Wrogowie_Kocurow VALUES ('TYGRYS','DZIKI BILL','2007-06-12','USILOWAL POZBAWIC ZYCIA')
INTO Wrogowie_Kocurow VALUES ('BOLEK','DZIKI BILL','2007-11-10','ODGRYZL UCHO')
INTO Wrogowie_Kocurow VALUES ('LASKA','DZIKI BILL','2008-12-12','POGRYZL ZE LEDWO SIE WYLIZALA')
INTO Wrogowie_Kocurow VALUES ('LASKA','KAZIO','2009-01-07','ZLAPAL ZA OGON I ZROBIL WIATRAK')
INTO Wrogowie_Kocurow VALUES ('DAMA','KAZIO','2009-02-07','CHCIAL OBEDRZEC ZE SKORY')
INTO Wrogowie_Kocurow VALUES ('MAN','REKSIO','2009-04-14','WYJATKOWO NIEGRZECZNIE OBSZCZEKAL')
INTO Wrogowie_Kocurow VALUES ('LYSY','BETHOVEN','2009-05-11','NIE PODZIELIL SIE SWOJA KASZA')
INTO Wrogowie_Kocurow VALUES ('RURA','DZIKI BILL','2009-09-03','ODGRYZL OGON')
INTO Wrogowie_Kocurow VALUES ('PLACEK','BAZYLI','2010-07-12','DZIOBIAC UNIEMOZLIWIL PODEBRANIE KURCZAKA')
INTO Wrogowie_Kocurow VALUES ('PUSZYSTA','SMUKLA','2010-11-19','OBRZUCILA SZYSZKAMI')
INTO Wrogowie_Kocurow VALUES ('KURKA','BUREK','2010-12-14','POGONIL')
INTO Wrogowie_Kocurow VALUES ('MALY','CHYTRUSEK','2011-07-13','PODEBRAL PODEBRANE JAJKA')
INTO Wrogowie_Kocurow VALUES ('UCHO','SWAWOLNY DYZIO','2011-07-14','OBRZUCIL KAMIENIAMI')
SELECT * FROM dual;

-- Bandy: ban_szef_fk
ALTER TABLE Bandy ADD CONSTRAINT ban_szef_fk FOREIGN KEY(szef_bandy) REFERENCES Kocury(pseudo);

COMMIT;


-- ==================================================================================             
-- =========================   INITIALIZATION FINISH HERE   =========================
-- ==================================================================================

-- Zad 1

SELECT 
    imie_wroga AS "WROG",
    opis_incydentu AS "PRZEWINA"
FROM 
    Wrogowie_Kocurow
WHERE 
    data_incydentu >= '2009.01.01' 
    AND data_incydentu <= '2009.12.31';

-- Zad 2

SELECT 
    imie AS "IMIE", 
    funkcja AS "FUNKCJA", 
    w_stadku_od AS "Z NAMI OD"
FROM 
    Kocury
WHERE 
    plec = 'D'
    AND w_stadku_od >= '2005.09.01'
    AND w_stadku_od <= '2007.07.31';

-- Zad 3

SELECT 
    imie_wroga AS "WROG", 
    gatunek, 
    stopien_wrogosci AS "STOPIEN WROGOSCI"
FROM 
    Wrogowie
WHERE 
    lapowka IS NULL
ORDER BY 
    stopien_wrogosci;

-- Zad 4
-- TO_CHAR(w_stadku_od, 'YYYY-MM-DD')

SELECT 
    imie || ' zwany ' || pseudo  || ' (fun. ' || funkcja || ') lowi myszki w bandzie ' || nr_bandy || ' od ' || w_stadku_od AS "WSZYSTKO O KOCURACH"
FROM 
    Kocury
WHERE 
    plec = 'M'
ORDER BY 
    w_stadku_od DESC, 
    pseudo ASC;

-- Zad 5


SELECT 
    pseudo,
    --REGEXP_REPLACE(REGEXP_REPLACE(pseudo, SUBSTR(pseudo, INSTR(pseudo, 'A'), 1), '#', 1), SUBSTR(pseudo, INSTR(pseudo, 'L'), 1), '%', 1) AS zmieniony_pseudo
    REGEXP_REPLACE(REGEXP_REPLACE(pseudo, '(.*?)L(.*)', '\1%\2', 1, 1), '(.*?)A(.*)', '\1#\2', 1, 1) AS "Po wymianie A an # oraz L na %"
FROM 
    Kocury
WHERE 
    --INSTR(pseudo, 'A') > 0 AND INSTR(pseudo, 'L') > 0;
    pseudo LIKE '%A%' 
    AND pseudo LIKE '%L%';

-- Zad 6


SELECT 
    imie,
    w_stadku_od AS "W stadku",
    przydzial_myszy AS "Zjadal",
    ADD_MONTHS(w_stadku_od, 6) AS "Podwyzka",
    ROUND(przydzial_myszy * 1.1) AS "Zjada"
FROM 
    Kocury
WHERE 
    -- w_stadku_od <= ADD_MONTHS(SYSDATE, -180) 
    w_stadku_od <= ADD_MONTHS(TO_DATE('2024-07-17', 'YYYY-MM-DD'), -180)
    AND TO_CHAR(w_stadku_od, 'MM-DD') BETWEEN '03-01' AND '09-30';

-- Zad 7


SELECT 
    imie, 
    3 * przydzial_myszy "MYSZY KWARTALNIE", 
    3 * NVL(myszy_extra, 0) "KWARTALNE DODATKI"
FROM 
    Kocury
WHERE 
    przydzial_myszy > 2 * NVL(myszy_extra, 0) 
    AND przydzial_myszy > 55;

-- Zad 8


SELECT
    imie,
    CASE
        WHEN 12 * (przydzial_myszy + NVL(myszy_extra, 0)) > 660 THEN TO_CHAR(12 * (przydzial_myszy + NVL(myszy_extra, 0)))
        WHEN 12 * (przydzial_myszy + NVL(myszy_extra, 0)) = 660 THEN 'Limit'
        ELSE 'Ponizej 660'
    END AS "Zjada rocznie"
FROM
    Kocury;

-- Zad 9
--a)
SELECT 
    pseudo,
    w_stadku_od,
    CASE 
        -- koty, które przystąpiły w pierwszej połowie miesiąca (do 15 włącznie) otrzymują wypłatę w ostatnią środę października
        WHEN TO_CHAR(w_stadku_od, 'DD') <= 15 THEN 
            NEXT_DAY(LAST_DAY(TO_DATE('29-10-2024', 'DD-MM-YYYY')) - 7, 'ŚRODA') 
        -- koty, które przystąpiły po 15-ym otrzymują wypłatę w ostatnią środę następnego miesiąca
        ELSE 
            NEXT_DAY(LAST_DAY(TO_DATE('29-10-2024', 'DD-MM-YYYY') + INTERVAL '1' MONTH) - 7, 'ŚRODA') 
    END AS "WYPLATA"
FROM 
    Kocury
ORDER BY 
    w_stadku_od;


--b)
SELECT 
    pseudo,
    w_stadku_od,
    CASE 
        -- koty, które przystąpiły w pierwszej połowie miesiąca (do 15 włącznie) otrzymują wypłatę w ostatnią środę listopada
        WHEN TO_CHAR(w_stadku_od, 'DD') <= 15 THEN 
            NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('31-10-2024', 'DD-MM-YYYY'), 1)) - 7, 'ŚRODA') 
        -- koty, które przystąpiły po 15-ym również otrzymują wypłatę w listopadzie
        ELSE 
            NEXT_DAY(LAST_DAY(ADD_MONTHS(TO_DATE('31-10-2024', 'DD-MM-YYYY'), 1)) - 7, 'ŚRODA') 
    END AS "WYPLATA"
FROM 
    Kocury
ORDER BY 
    w_stadku_od;

-- Zad 10
--a)
SELECT 
    pseudo || ' - ' || 
    CASE 
        WHEN COUNT(*) > 1 THEN 'nieunikalny'
        ELSE 'Unikalny'
    END AS "Unikalnosc atr. PSEUDO"
FROM 
    Kocury
GROUP BY 
    pseudo;

--b)
SELECT 
    szef || ' - ' || 
    CASE 
        WHEN COUNT(*) > 1 THEN 'nieunikalny'
        ELSE 'Unikalny'
    END AS "Unikalnosc atr. SZEF"
FROM 
    Kocury
WHERE 
    szef IS NOT NULL
GROUP BY 
    szef;



-- Zad 11

SELECT 
    k.pseudo AS "Pseudonim", 
    COUNT(w.imie_wroga) AS "Liczba wrogow"
FROM 
    Kocury k
JOIN 
    Wrogowie_kocurow w ON k.pseudo = w.pseudo
GROUP BY
    k.pseudo
HAVING 
    COUNT(w.imie_wroga) >= 2;


-- Zad 12
      
SELECT 
    'Liczba kotow= ' AS "Kol1",
    COUNT(*) AS "Kol2",
    'lowi jako ' AS "Kol3",
    f.funkcja AS "Kol4",
    'i zjada max. '  AS "Kol5",
    TO_CHAR(MAX(k.przydzial_myszy + NVL(k.myszy_extra, 0)), 'FM999.00') AS "Kol6",
    'myszy miesiecznie' AS "Kol7"
FROM 
    Kocury k
JOIN 
    Funkcje f ON k.funkcja = f.funkcja
WHERE 
    k.plec <> 'M' 
    AND k.pseudo <> 'SZEFUNIA'
GROUP BY 
    f.funkcja
HAVING 
    AVG(k.przydzial_myszy + NVL(k.myszy_extra, 0)) > 50;


-- Zad 13


SELECT 
    nr_bandy AS "Nr bandy", 
    plec AS "Plec", 
    MIN(przydzial_myszy) AS "Minimalny przydzial"
FROM 
    Kocury
GROUP BY 
    nr_bandy, 
    plec;

-- Zad 14


SELECT 
    LEVEL "Poziom", 
    pseudo "Pseudonim", 
    funkcja "Funkcja", 
    nr_bandy "Nr bandy"
FROM 
    Kocury
WHERE 
    plec  = 'M'
CONNECT BY PRIOR 
    pseudo = szef
START WITH 
    funkcja = 'BANDZIOR';

-- Zad 15

SELECT
    LPAD(TO_CHAR(LEVEL - 1), (LEVEL - 1) * 4 + LENGTH(TO_CHAR(LEVEL - 1)), '===>') || '        ' || imie AS "Hierarchia",
    NVL(szef, 'Sam sobie panem') AS "Pseudo szefa",
    funkcja AS "Funkcja"
FROM 
    Kocury
WHERE 
    myszy_extra > 0
CONNECT BY 
    PRIOR pseudo = szef
START WITH 
    szef IS NULL;

-- Zad 16         
    
SELECT 
	RPAD(' ', 4 * (LEVEL - 1), ' ') || pseudo AS "Droga sluzbowa"
FROM 
	Kocury
CONNECT BY 
	PRIOR szef = pseudo
START WITH 
	EXTRACT(YEAR FROM TO_DATE('2024-07-17', 'YYYY-MM-DD')) - EXTRACT(YEAR FROM w_stadku_od) > 15
	AND plec = 'M'
	AND myszy_extra IS NULL;


           