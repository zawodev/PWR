DROP TABLE KocuryT CASCADE CONSTRAINTS;
DROP TABLE PlebsT CASCADE CONSTRAINTS;
DROP TABLE ElitaT CASCADE CONSTRAINTS;
DROP TABLE KontoT CASCADE CONSTRAINTS;
DROP TABLE IncydentyT CASCADE CONSTRAINTS;
DROP TYPE BODY KocuryO;
DROP TYPE KocuryO FORCE;
DROP TYPE BODY ElitaO;
DROP TYPE ElitaO FORCE;
DROP TYPE BODY PlebsO;
DROP TYPE PlebsO FORCE;
DROP TYPE BODY KontoO;
DROP TYPE KontoO FORCE;
DROP TYPE BODY IncydentO;
DROP TYPE IncydentO FORCE;

ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';
SET SERVEROUTPUT ON;
SET VERIFY OFF;

--zad47 ----------------------------------------------------------------------------------
    
-- KocuryO
CREATE OR REPLACE TYPE KocuryO AS OBJECT
(
    imie            VARCHAR2(15),
    plec            VARCHAR2(1),
    pseudo          VARCHAR2(15),
    funkcja         VARCHAR2(10),
    w_stadku_od     DATE,
    przydzial_myszy NUMBER(3),
    myszy_extra     NUMBER(3),
    nr_bandy        NUMBER(2),
    szef            REF KocuryO,
    MEMBER FUNCTION caly_przydzial RETURN NUMBER,
    MAP MEMBER FUNCTION info RETURN VARCHAR2
);

DROP TYPE KocuryO;


ROLLBACK;

-- KocuryO Body
CREATE OR REPLACE TYPE BODY KocuryO
AS
    MEMBER FUNCTION caly_przydzial RETURN NUMBER IS
    BEGIN
        RETURN NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0);
    END;
    MAP MEMBER FUNCTION info RETURN VARCHAR2 IS
    BEGIN
        RETURN imie || ', ' || plec ||', pseudo:' || pseudo || ', funkcja: '|| funkcja ||', zjada:'|| SELF.CALY_PRZYDZIAL();
    END;
END;

-- KocuryT
CREATE TABLE KocuryT OF KocuryO (
  imie CONSTRAINT kocuryo_imie_nn NOT NULL,
  plec CONSTRAINT kocuryo_plec_ch CHECK(plec IN ('M', 'D')),
  pseudo CONSTRAINT kocuryo_pseudo_pk PRIMARY KEY,
  funkcja CONSTRAINT ko_f_fk REFERENCES Funkcje(funkcja),
  szef SCOPE IS KocuryT,
  w_stadku_od DEFAULT SYSDATE,
  nr_bandy CONSTRAINT kocuryo_nr_fk REFERENCES Bandy(nr_bandy)
);

DROP TABLE KocuryT;

-- PlebsO
CREATE OR REPLACE TYPE PlebsO AS OBJECT
(
    pseudo   VARCHAR2(15),
    kot       REF KocuryO,
    MEMBER FUNCTION get_details RETURN VARCHAR2
);

-- PlebsO Body
CREATE OR REPLACE TYPE BODY PlebsO
AS
    MEMBER FUNCTION get_details RETURN VARCHAR2
        IS
        details VARCHAR2(400);
    BEGIN
        SELECT 'IMIE: ' || DEREF(kot).imie || ' PSEUDO ' || DEREF(kot).pseudo INTO details FROM dual;
        RETURN details;
    END;
END;

-- PlebsT Table
CREATE TABLE PlebsT OF PlebsO(
    kot SCOPE IS KocuryT CONSTRAINT plebso_kot_nn NOT NULL,
    CONSTRAINT plebso_fk FOREIGN KEY (pseudo) REFERENCES KocuryT(pseudo),
    CONSTRAINT plebso_pk PRIMARY KEY (pseudo)
);


-- ElitaO
CREATE OR REPLACE TYPE ElitaO AS OBJECT
(
    pseudo VARCHAR2(15),
    kot      REF KocuryO,
    slugus   REF PlebsO,
    MEMBER FUNCTION get_slugus RETURN REF PlebsO
);
-- ElitaO Body
CREATE OR REPLACE TYPE BODY ElitaO AS
  MEMBER FUNCTION get_slugus RETURN REF PlebsO IS
    BEGIN
      RETURN slugus;
    END;
END;

-- ElitaT Table
CREATE TABLE ElitaT OF ElitaO(
    pseudo CONSTRAINT elitao_pseudo_pk PRIMARY KEY,
    kot SCOPE IS KocuryT CONSTRAINT elitao_kot_nn NOT NULL,
    slugus SCOPE IS PlebsT
);

-- KontoO Object
CREATE OR REPLACE TYPE KontoO AS OBJECT
(
    nr_myszy NUMBER(5),
    data_wprowadzenia DATE,
    data_usuniecia DATE,
    kot REF ElitaO,
    MEMBER PROCEDURE usun_mysz(del_date DATE),
    MAP MEMBER FUNCTION get_info RETURN VARCHAR2
);

-- KontoO Body
CREATE OR REPLACE TYPE BODY KontoO AS
MAP 
    MEMBER FUNCTION get_info RETURN VARCHAR2 IS
    wl ElitaO;
    kocur KocuryO;
    BEGIN
        SELECT DEREF(kot) INTO wl FROM DUAL;
        SELECT DEREF(wl.kot) INTO kocur FROM DUAL;
        RETURN TO_CHAR(data_wprowadzenia) || ' ' || kocur.PSEUDO || TO_CHAR(data_usuniecia);
    END;
    
    MEMBER PROCEDURE usun_mysz(del_date DATE) IS
    BEGIN
        data_usuniecia := del_date;
    END;
END;

-- KontoT Table
CREATE TABLE KontoT OF KontoO (
    nr_myszy CONSTRAINT kontao_n_pk PRIMARY KEY,
    kot SCOPE IS ElitaT CONSTRAINT kontao_w_nn NOT NULL,
    data_wprowadzenia CONSTRAINT kontao_dw_nn NOT NULL,
    CONSTRAINT kontao_dw_du_ch CHECK(data_wprowadzenia <= data_usuniecia)
);

-- IncydentyO Object
CREATE OR REPLACE TYPE IncydentO AS OBJECT
(
    pseudo VARCHAR2(15),
    kot REF KocuryO,
    imie_wroga VARCHAR2(15),
    data_incydentu DATE,
    opis_incydentu VARCHAR2(100),
    MEMBER FUNCTION czy_jest_opis RETURN BOOLEAN,
    MEMBER FUNCTION czy_tegoroczny RETURN BOOLEAN
);

-- IncydentyO Body
CREATE OR REPLACE TYPE BODY IncydentO
AS
    MEMBER FUNCTION czy_jest_opis RETURN BOOLEAN
    IS
    BEGIN
        RETURN opis_incydentu IS NOT NULL;
    END;

    MEMBER FUNCTION czy_tegoroczny RETURN BOOLEAN
    IS
    BEGIN
        RETURN EXTRACT(YEAR FROM data_incydentu) = EXTRACT(YEAR FROM SYSDATE);
    END;
END;

-- IncydentyT Table
CREATE TABLE IncydentyT OF IncydentO (
    CONSTRAINT incydento_pk PRIMARY KEY(pseudo, imie_wroga),
    kot SCOPE IS KocuryT CONSTRAINT incydentyo_kot_nn NOT NULL,
    pseudo CONSTRAINT incydentyo_pseudo_fk REFERENCES KocuryT(pseudo),
    imie_wroga CONSTRAINT incydento_imie_wroga_fk REFERENCES Wrogowie(imie_wroga),
    data_incydentu CONSTRAINT incydentyo_data_nn NOT NULL
);

-- TRIGGERS
CREATE OR REPLACE TRIGGER elita_trg
    BEFORE INSERT OR UPDATE
    ON ElitaT
    FOR EACH ROW
DECLARE
    count_elita INTEGER;
BEGIN
    SELECT COUNT(PSEUDO) INTO count_elita FROM PlebsT P WHERE P.kot = :NEW.kot;
    IF count_elita > 0 THEN
        RAISE_APPLICATION_ERROR(-20000, 'ten kot należy już do plebsu.');
    END IF;

    SELECT COUNT(PSEUDO) INTO count_elita FROM ElitaT E WHERE E.kot = :NEW.kot;
    IF count_elita > 0 THEN
        RAISE_APPLICATION_ERROR(-20001, 'ten kot należy już do elity.');
    END IF;
END;


CREATE OR REPLACE TRIGGER plebs_trg
    BEFORE INSERT OR UPDATE
    ON PlebsT
    FOR EACH ROW
DECLARE
    count_plebs NUMBER;
BEGIN
    SELECT COUNT(PSEUDO) INTO count_plebs FROM ElitaT E WHERE E.kot = :NEW.kot;
    IF count_plebs > 0 THEN
        RAISE_APPLICATION_ERROR(-20002, 'ten kot należy już do elity.');
    END IF;

    SELECT COUNT(PSEUDO) INTO count_plebs FROM PlebsT P WHERE P.kot = :NEW.kot;
    IF count_plebs > 0 THEN
        RAISE_APPLICATION_ERROR(-20003, 'ten kot należy już do plebsu.');
    END IF;
END;


DROP TRIGGER elita_trg;
DROP TRIGGER plebs_trg;


-- przerzucamy dane z Kocury do KocuryT
DECLARE
    CURSOR koty IS SELECT * FROM KOCURY
        CONNECT BY PRIOR PSEUDO=SZEF
        START WITH SZEF IS NULL;
    command_str VARCHAR2(1000);
BEGIN
    FOR kot in koty
    LOOP
        command_str:='DECLARE
            szef REF KocuryO;
            counter NUMBER(2);
        BEGIN
            szef:=NULL;
            SELECT COUNT(*) INTO counter FROM KocuryT T WHERE T.pseudo='''|| kot.szef||''';
            IF (counter>0) THEN
                SELECT REF(T) INTO szef FROM KocuryT T WHERE T.pseudo='''|| kot.szef||''';
            END IF;
            INSERT INTO KocuryT VALUES
                    (KocuryO(''' || kot.imie || ''', ''' || kot.plec || ''', ''' || kot.pseudo || ''', ''' || kot.funkcja
                    || ''','''||kot.w_stadku_od || ''', ''' || kot.przydzial_myszy ||''', ''' || kot.myszy_extra ||
                        ''',''' || kot.nr_bandy ||''',' || 'szef' || '));
            END;';
        DBMS_OUTPUT.PUT_LINE(command_str);
        EXECUTE IMMEDIATE command_str;
        END LOOP;
END;

SELECT * FROM KocuryT;
COMMIT;

-- tworzymy dane do tabeli incydenty
DECLARE
    CURSOR zdarzenia IS SELECT * FROM Wrogowie_kocurow;
    command_str VARCHAR2(1000);
BEGIN
    FOR zdarzenie IN zdarzenia
    LOOP
      command_str:='DECLARE
            kot REF KocuryO;
        BEGIN
            SELECT REF(K) INTO kot FROM KocuryT K WHERE K.pseudo='''|| zdarzenie.pseudo||''';
            INSERT INTO IncydentyT VALUES
                    (IncydentO(''' || zdarzenie.pseudo || ''',  kot , ''' || zdarzenie.imie_wroga || ''', ''' || zdarzenie.data_incydentu
                    || ''',''' || zdarzenie.opis_incydentu|| '''));
            END;';
       DBMS_OUTPUT.PUT_LINE(command_str);
       EXECUTE IMMEDIATE command_str;
    END LOOP;
END;

SELECT * FROM IncydentyT;

-- tworzymy dane plebs
DECLARE
CURSOR koty IS SELECT pseudo
    FROM (SELECT K.pseudo pseudo FROM KocuryT K ORDER BY K.caly_przydzial() ASC)
    WHERE ROWNUM<= (SELECT COUNT(*) FROM KocuryT)/2;
command_str VARCHAR2(1000);
BEGIN
    FOR plebs IN koty
    LOOP
      command_str:='DECLARE
            kot REF KocuryO;
            BEGIN
            SELECT REF(K) INTO kot FROM KocuryT K WHERE K.pseudo='''|| plebs.pseudo||''';
            INSERT INTO PlebsT VALUES
                    (PlebsO('''|| plebs.pseudo ||''',' || 'kot' || '));
            END;';
       EXECUTE IMMEDIATE command_str;
    END LOOP;
END;

SELECT P.pseudo, P.kot.info() FROM PlebsT P;

-- tworzymy dane elita
DECLARE
CURSOR koty IS SELECT PSEUDO FROM (SELECT K.pseudo pseudo FROM KocuryT K ORDER BY K.caly_przydzial() DESC)
    WHERE ROWNUM <= (SELECT COUNT(*) FROM KocuryT)/2;
command_str VARCHAR2(1000);
num NUMBER:=1;
BEGIN
    FOR elita in koty
    LOOP
        command_str:='DECLARE
                        kot REF KocuryO;
                        sluga REF PlebsO;
                    BEGIN
                        SELECT REF(K) INTO kot FROM KocuryT K WHERE K.pseudo=''' || elita.pseudo || ''';' ||
                       'SELECT plebs INTO sluga FROM (SELECT REF(P) plebs, rownum num FROM PlebsT P) WHERE NUM=' || num ||';'||
                    'INSERT INTO ElitaT VALUES (ElitaO(''' || elita.pseudo ||''', kot, sluga)); END;';
        EXECUTE IMMEDIATE command_str;
        num:=num+1;
        END LOOP;
END;

SELECT E.kot.pseudo, E.slugus.pseudo, E.kot.caly_przydzial() FROM ElitaT E;

--tworzynmy dane konto
CREATE SEQUENCE nr_myszy;

DECLARE
CURSOR koty IS SELECT pseudo FROM ElitaT;
command_str VARCHAR2(1000);
BEGIN
    FOR elita IN koty
    LOOP
      command_str:='DECLARE
            kot REF ElitaO;
            dataw DATE:=SYSDATE;
        BEGIN
            SELECT REF(E) INTO kot FROM ElitaT E WHERE E.pseudo='''|| elita.pseudo||''';
            INSERT INTO KontoT VALUES
                    (KontoO(nr_myszy.NEXTVAL, dataw, NULL, kot));
        END;';
       DBMS_OUTPUT.PUT_LINE(command_str);
       EXECUTE IMMEDIATE command_str;
    END LOOP;
END;

SELECT * FROM KontoT;



--metody:

-- z elity do plebsu
DECLARE
    kot REF KocuryO;
BEGIN
    SELECT kot INTO kot FROM ElitaT WHERE pseudo = 'TYGRYS';
    DELETE FROM ElitaT WHERE pseudo = 'TYGRYS';
    INSERT INTO PlebsT VALUES (PlebsO('TYGRYS', kot));
END;

SELECT E.kot.pseudo, E.kot.info() FROM ElitaT E;
SELECT P.pseudo, P.kot.info() FROM PlebsT P;

ROLLBACK;

SELECT DEREF(kot).info() FROM PlebsT;
SELECT DEREF(kot).info(), DEREF(slugus).get_details() FROM ELitaT;
SELECT data_usuniecia, data_wprowadzenia, DEREF(kot).pseudo, DEREF(kot).get_slugus().get_details() FROM KontoT;
SELECT K.imie, K.plec, K.caly_przydzial() FROM KocuryT K WHERE K.caly_przydzial() > 65;

--podzapytania
SELECT pseudo, plec FROM (SELECT K.pseudo pseudo, K.plec plec FROM KocuryT K WHERE K.PLEC = 'D');

SELECT K1.info() FROM KocuryT K1 WHERE K1.caly_przydzial() <= (
    SELECT AVG(K2.caly_przydzial())
    FROM KocuryT K2
);

--grupowanie
SELECT 
    K.funkcja, 
    COUNT(K.pseudo) as koty_w_funkcji
FROM 
    KocuryT K 
GROUP BY 
    K.funkcja;


SELECT 
    DEREF(kot).pseudo "Kot", 
    count(slugus) "Sługa"
FROM 
    ElitaT E
GROUP BY 
    DEREF(kot).pseudo;


SELECT 
    E.kot.pseudo, 
    E.kot.caly_przydzial()
FROM 
    KocuryT K JOIN ElitaT E ON E.kot = REF(K);


SELECT 
    K.kot.PSEUDO,
    data_wprowadzenia, 
    data_usuniecia
FROM 
    KontoT K;


--lista2 zad 18
SELECT
    K1.imie,
    TO_CHAR(K1.w_stadku_od, 'yyyy-mm-dd') "POLUJE OD"
FROM
    KocuryT K1 JOIN KocuryT K2 ON K2.imie = 'JACEK'
WHERE
    K1.w_stadku_od < K2.w_stadku_od
ORDER BY
    K1.w_stadku_od DESC;

--lista2 zad 19a
SELECT 
    K.imie "Imie",
    K.funkcja "Funkcja",
    K.szef.imie "Szef 1",
    K.szef.szef.imie "Szef 2",
    K.szef.szef.szef.imie "Szef 3"
FROM 
    KocuryT K
WHERE 
    K.funkcja IN ('KOT', 'MILUSIA');

--lista 3 zad34 (DZIELCZY jeden, LOWCZY kilka)
DECLARE
    funkcja_kocura KocuryT.funkcja%TYPE;
BEGIN
    SELECT FUNKCJA INTO funkcja_kocura
    FROM KocuryT
    WHERE FUNKCJA = UPPER('&nazwa_funkcji');
    DBMS_OUTPUT.PUT_LINE('znaleziono kota o funkcji: ' || funkcja_kocura);
EXCEPTION
    WHEN TOO_MANY_ROWS
        THEN DBMS_OUTPUT.PUT_LINE('TAK znaleziono '|| funkcja_kocura);
    WHEN NO_DATA_FOUND
        THEN DBMS_OUTPUT.PUT_LINE('NIE znaleziono' || funkcja_kocura);
END;

--lista 3 zad35 (LYSY, RURA, BOLEK, ZERO)
DECLARE
    imie_kocura KocuryT.imie%TYPE;
    przydzial_kocura NUMBER;
    miesiac_kocura NUMBER;
    znaleziony BOOLEAN DEFAULT FALSE;
BEGIN
SELECT
    imie,
    (koc.caly_przydzial()) * 12,
    EXTRACT(MONTH FROM w_stadku_od)
INTO
    imie_kocura,
    przydzial_kocura,
    miesiac_kocura
FROM
    KocuryT koc
WHERE
    PSEUDO = UPPER('&pseudonim');
IF przydzial_kocura > 700 
    THEN DBMS_OUTPUT.PUT_LINE('calkowity roczny przydzial myszy >700');
ELSIF imie_kocura LIKE '%A%'
    THEN DBMS_OUTPUT.PUT_LINE('imię zawiera litere A');
ELSIF miesiac_kocura = 5 
    THEN DBMS_OUTPUT.PUT_LINE('maj jest miesiacem przystapienia do stada');
ELSE 
    DBMS_OUTPUT.PUT_LINE('nie odpowiada kryteriom');
END IF;
EXCEPTION 
    WHEN NO_DATA_FOUND
        THEN DBMS_OUTPUT.PUT_LINE('brak kota o takim pseudonimie');
WHEN OTHERS 
        THEN DBMS_OUTPUT.PUT_LINE(sqlerrm);
END;