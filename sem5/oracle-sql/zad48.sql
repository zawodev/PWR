--Zadanie 48

CREATE TABLE Plebs (
  pseudo VARCHAR2(15) CONSTRAINT plebs_pk PRIMARY KEY,
  kot VARCHAR2(10) CONSTRAINT plebks_fk REFERENCES Kocury(pseudo)
);
CREATE TABLE Elita (
  pseudo VARCHAR2(15) CONSTRAINT elita_pk PRIMARY KEY,
  kot VARCHAR2(10) CONSTRAINT elita_fk REFERENCES Kocury(pseudo),
  sluga VARCHAR2(15) CONSTRAINT elita_sluga_fk REFERENCES Plebs(pseudo)
);
CREATE TABLE Konto (
  nr_myszy NUMBER(5) CONSTRAINT konto_pk PRIMARY KEY,
  data_wprowadzenia DATE,
  data_usuniecia DATE,
  kot VARCHAR2(15) CONSTRAINT konto_kot_fk REFERENCES Elita(pseudo)
);

DROP Table Plebs CASCADE CONSTRAINTS;
Drop TABLE Elita CASCADE CONSTRAINTS;
DROP TABLE Konto Cascade Constraints;

CREATE OR REPLACE FORCE VIEW KocuryV OF KocuryO
WITH OBJECT IDENTIFIER (pseudo) AS
SELECT imie, plec, pseudo, funkcja, w_stadku_od, przydzial_myszy, myszy_extra, nr_bandy, MAKE_REF(KocuryV,szef)
FROM Kocury;

CREATE OR REPLACE VIEW PlebsV OF PlebsO
WITH OBJECT IDENTIFIER (pseudo) AS
SELECT pseudo, MAKE_REF(KocuryV,kot) AS kot
FROM Plebs;

CREATE OR REPLACE VIEW ElitaV OF ElitaO
WITH OBJECT IDENTIFIER (pseudo) AS
SELECT pseudo, MAKE_REF(KocuryV, kot), MAKE_REF(PlebsV, sluga)
FROM Elita;

SELECT  * from  konto;

CREATE OR REPLACE VIEW KontoV OF KontoO
WITH OBJECT IDENTIFIER (nr_myszy) AS
SELECT nr_myszy, data_wprowadzenia, data_usuniecia, MAKE_REF(ElitaV, kot)
FROM Konto;


INSERT INTO PlebsV
  SELECT PlebsO(ROWNUM, REF(K))
  FROM KocuryV K
  WHERE K.funkcja = 'KOT';
COMMIT;

INSERT INTO ElitaV
  SELECT ElitaO(ROWNUM, REF(K), NULL)
  FROM KocuryV K
  WHERE K.szef.PSEUDO = 'TYGRYS'
        OR K.szef IS NULL;

INSERT INTO KontoV
  SELECT KontoO(ROWNUM, ADD_MONTHS(CURRENT_DATE, -TRUNC(DBMS_RANDOM.VALUE(0, 12))), NULL, REF(K))
  FROM ElitaV K;




SELECT * FROM ELITAV;
SELECT * FROM PLEBSV;
SELECT * FROM KONTOV;


--METODY:
SELECT DEREF(kot).info() FROM PLEBSV;
SELECT DEREF(kot).info(), DEREF(slugus).get_details() FROM ELitaV;
SELECT data_usuniecia, data_wprowadzenia, DEREF(kot).pseudo, DEREF(kot).get_sluga().get_details() FROM KONTOV;
SELECT K.IMIE, K.PLEC, K.caly_przydzial() FROM KocuryV K WHERE K.caly_przydzial() > 90;


--PODZAPYTANIE
SELECT pseudo, plec FROM (SELECT K.pseudo pseudo, K.plec plec FROM KocuryV K WHERE K.PLEC = 'D');

SELECT K.info() FROM KocuryV K WHERE K.caly_przydzial() <= (
    SELECT AVG(K1.caly_przydzial())
    FROM KocuryV K1
    );
--GRUPOWANIE
SELECT K.funkcja, COUNT(K.pseudo) as koty_w_funkcji FROM KocuryV K GROUP BY K.funkcja;

SELECT E.kot.pseudo, E.kot.caly_przydzial()
FROM KocuryT K JOIN ElitaT E  ON E.kot = REF(K);

SELECT E.kot.pseudo, E.kot.caly_przydzial()
FROM  ElitaV E;

SELECT K.kot.PSEUDO, data_wprowadzenia, data_usuniecia
FROM KontoV K;

--lista2 zad 18
SELECT K2.imie, K2.w_stadku_od "POLUJE OD"
FROM KocuryV K1
         JOIN KocuryV K2
              ON K1.imie = 'JACEK'
WHERE K1.w_stadku_od > K2.w_stadku_od
ORDER BY K2.w_stadku_od DESC;


SELECT K.pseudo, data_wprowadzenia, data_usuniecia
FROM KocuryV K JOIN ElitaV E ON REF(K) = E.kot LEFT JOIN KontoV ON REF(E) = KontoV.kot;
--lista2 zad 19a
SELECT K.imie "Imie",
       K.funkcja "Funkcja",
       K.szef.imie "Szef 1",
       K.szef.szef.imie "Szef 2",
       K.szef.szef.szef.imie "Szef 3"
FROM KocuryV K
WHERE K.funkcja IN ('KOT', 'MILUSIA');

--lista 2 zad 23
SELECT imie, 12 * K.caly_przydzial() "DAWKA ROCZNA", 'powyzej 864' "DAWKA"
FROM KocuryV K
WHERE 12 * K.caly_przydzial() > 864
  AND myszy_extra IS NOT NULL
UNION
SELECT imie, 12 * K.caly_przydzial() "DAWKA ROCZNA", '864' "DAWKA"
FROM KocuryV K
WHERE 12 * K.caly_przydzial() = 864
  AND myszy_extra IS NOT NULL
UNION
SELECT imie, 12 * K.caly_przydzial() "DAWKA ROCZNA", 'ponizej 864' "DAWKA"
FROM KocuryV K
WHERE 12 * K.caly_przydzial() < 864
  AND myszy_extra IS NOT NULL
ORDER BY 2 DESC;

--lista 3 zad 34
DECLARE
    funkcja_kocura KocuryT.funkcja%TYPE;
BEGIN
    SELECT FUNKCJA INTO funkcja_kocura
    FROM KocuryV
    WHERE FUNKCJA = UPPER('MILUSIA');
    DBMS_OUTPUT.PUT_LINE('Znaleziono kota o funkcji: ' || funkcja_kocura);
EXCEPTION
    WHEN TOO_MANY_ROWS
        THEN DBMS_OUTPUT.PUT_LINE('znaleziono '|| funkcja_kocura);
    WHEN NO_DATA_FOUND
        THEN DBMS_OUTPUT.PUT_LINE('NIE znaleziono' || funkcja_kocura);
END;

--lista 3 zad37
DECLARE
    CURSOR topC IS
        SELECT K.pseudo, K.caly_przydzial() "zjada"
        FROM KocuryV K
        ORDER BY "zjada" DESC;
    top topC%ROWTYPE;
BEGIN
    OPEN topC;
    DBMS_OUTPUT.PUT_LINE('Nr   Pseudonim   Zjada');
    DBMS_OUTPUT.PUT_LINE('----------------------');
    FOR i IN 1..5
    LOOP
        FETCH topC INTO top;
        EXIT WHEN topC%NOTFOUND;
        DBMS_OUTPUT.PUT_LINE(TO_CHAR(i) ||'    '|| RPAD(top.pseudo, 8) || '    ' || LPAD(TO_CHAR(top."zjada"), 5));
    END LOOP;
END;