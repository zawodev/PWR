SET SERVEROUTPUT ON


--zad34 (DZIELCZY jeden, LOWCZY kilka)
DECLARE
funkcja_kocura KOCURY.funkcja%TYPE;
BEGIN
SELECT FUNKCJA INTO funkcja_kocura
FROM KOCURY
WHERE FUNKCJA = UPPER('&nazwa_funkcji');
DBMS_OUTPUT.PUT_LINE('Znaleziono kota o funkcji: ' || funkcja_kocura);
EXCEPTION
    WHEN TOO_MANY_ROWS 
        THEN DBMS_OUTPUT.PUT_LINE('TAK znaleziono');
WHEN NO_DATA_FOUND 
        THEN DBMS_OUTPUT.PUT_LINE('NIE znaleziono');
END;


--zad35 (LYSY)
DECLARE
imie_kocura KOCURY.imie%TYPE;
    pzydzial_kocura NUMBER;
    miesiac_kocura NUMBER;
    znaleziony BOOLEAN DEFAULT FALSE;
BEGIN
SELECT imie, (NVL(przydzial_myszy, 0) + NVL(myszy_extra,0))*12, EXTRACT(MONTH FROM w_stadku_od)
INTO imie_kocura, pzydzial_kocura, miesiac_kocura
FROM KOCURY
WHERE PSEUDO = UPPER('&pseudonim');
IF pzydzial_kocura > 700 
        THEN DBMS_OUTPUT.PUT_LINE('calkowity roczny przydzial myszy >700');
    ELSIF imie_kocura LIKE '%A%'
        THEN DBMS_OUTPUT.PUT_LINE('imię zawiera litere A');
    ELSIF miesiac_kocura = 5 
        THEN DBMS_OUTPUT.PUT_LINE('maj jest miesiacem przystapienia do stada');
ELSE DBMS_OUTPUT.PUT_LINE('nie odpowiada kryteriom');
END IF;
EXCEPTION 
    WHEN NO_DATA_FOUND
        THEN DBMS_OUTPUT.PUT_LINE('BRAK TAKIEGO KOTA');
WHEN OTHERS 
        THEN DBMS_OUTPUT.PUT_LINE(sqlerrm);
END;


--zad36 ()
DECLARE
CURSOR kolejka IS
SELECT PSEUDO, NVL(PRZYDZIAL_MYSZY,0) zjada, Funkcje.MAX_MYSZY maks
FROM KOCURY JOIN FUNKCJE ON KOCURY.FUNKCJA = FUNKCJE.FUNKCJA
ORDER BY 2
    FOR UPDATE OF PRZYDZIAL_MYSZY;
zmiany NUMBER:=0;
    suma NUMBER:=0;
    kot kolejka%ROWTYPE;
BEGIN
SELECT SUM(NVL(PRZYDZIAL_MYSZY,0)) INTO suma
FROM KOCURY;
OPEN kolejka;
WHILE suma <= 1050
        LOOP
            FETCH kolejka INTO kot;
            EXIT WHEN kolejka%NOTFOUND;
            IF ROUND(kot.zjada * 1.1) <= kot.maks THEN
UPDATE KOCURY
SET PRZYDZIAL_MYSZY = ROUND(PRZYDZIAL_MYSZY * 1.1)
WHERE CURRENT OF kolejka;
suma := suma + ROUND(kot.zjada * 0.1);
                zmiany := zmiany + 1;
            ELSIF kot.zjada <> kot.maks THEN
UPDATE KOCURY
SET PRZYDZIAL_MYSZY = kot.maks
WHERE CURRENT OF kolejka;
suma := suma + kot.maks - kot.zjada;
                zmiany := zmiany + 1;
END IF;
END LOOP;
    DBMS_OUTPUT.PUT_LINE('Calk. przydzial w stadku - ' || TO_CHAR(suma) || ' L zmian - ' || TO_CHAR(zmiany));
CLOSE kolejka;
END;

SELECT IMIE, PRZYDZIAL_MYSZY "Myszki po podwyzce"
FROM KOCURY
ORDER BY 2 DESC;

ROLLBACK;

--zad36 ale bez wypisywania (za to bez klikania dwa razy)
DECLARE
CURSOR kocuryC IS SELECT * FROM Kocury;
kocur kocuryC%ROWTYPE;
  suma NUMBER;
  maxf NUMBER;
  pp NUMBER;
BEGIN


  LOOP
SELECT SUM(przydzial_myszy) INTO suma FROM Kocury;
EXIT WHEN suma > 1050;

OPEN kocuryC;

LOOP
FETCH kocuryC INTO kocur;
      EXIT WHEN kocuryC%NOTFOUND;
SELECT max_myszy INTO maxf FROM Funkcje WHERE funkcja = kocur.funkcja;
pp := kocur.przydzial_myszy * 1.1;

      IF pp > maxf THEN
        pp := maxf;
END IF;

UPDATE Kocury
SET przydzial_myszy = pp
WHERE pseudo = kocur.pseudo;
END LOOP;

CLOSE kocuryC;
END LOOP;
END;

SELECT imie, przydzial_myszy FROM kocury ORDER BY przydzial_myszy DESC;
ROLLBACK;


--zad37 ()
DECLARE
CURSOR topC IS
SELECT pseudo, przydzial_myszy + NVL(myszy_extra, 0) "zjada"
FROM Kocury
ORDER BY 2 DESC;
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




























































--Lab 38
DECLARE
CURSOR kotyC IS SELECT * FROM Kocury WHERE funkcja = 'KOT' OR funkcja = 'MILUSIA';
kot kotyC%ROWTYPE;
  pseudoSzefa Kocury.pseudo%TYPE;
  singleRow VARCHAR2(500);
  deep NUMBER:= ?;
  i NUMBER:=0;
BEGIN
OPEN kotyC;

singlerow := RPAD('IMIE', 8);
FOR k IN 1..deep
  LOOP
    singlerow := singlerow || ' | ' || RPAD('SZEF ' || TO_CHAR(k), 8);
END LOOP;
  DBMS_OUTPUT.PUT_LINE(singlerow || '|');
  singlerow := '';

  singlerow := RPAD('-', 8, '-');
FOR k IN 1..deep
  LOOP
    singlerow := singlerow || '-|-' || RPAD('-', 8, '-');
END LOOP;
  DBMS_OUTPUT.PUT_LINE(singlerow || '|');
  singlerow := '';

  LOOP
FETCH kotyC INTO kot;
    EXIT WHEN kotyC%NOTFOUND;

    singlerow := singlerow || RPAD(kot.imie, 8);

    LOOP
EXIT WHEN NOT i < deep;
BEGIN
SELECT * INTO kot FROM Kocury WHERE pseudo = kot.szef;
singlerow := singlerow || ' | ' || RPAD(kot.imie, 8);
EXCEPTION
        WHEN OTHERS THEN
        singlerow := singlerow || ' | ' || RPAD(' ', 8);
END;
      i := i + 1;

END LOOP;
    DBMS_OUTPUT.PUT_LINE(singlerow || '|');
    i := 0;
    singlerow := '';
END LOOP;
END;























--Lab 39
DECLARE
CURSOR bandyC IS SELECT * FROM Bandy;
banda bandy%ROWTYPE;

  nr bandy.nr_bandy%TYPE;
  nazwa_bandy bandy.nazwa%TYPE;
  teren_bandy bandy.teren%TYPE;

    banda_nr_exc EXCEPTION;
    banda_exists EXCEPTION;
    nazwa_exists EXCEPTION;
    teren_exists EXCEPTION;
BEGIN
  nr := ?;
  nazwa_bandy := ?;
  teren_bandy := ?;

  IF nr <= 0 THEN
    RAISE banda_nr_exc;
END IF;

OPEN bandyC;

LOOP
FETCH bandyC INTO banda;
    EXIT WHEN bandyC%NOTFOUND;

    IF nr = banda.nr_bandy THEN
      RAISE banda_exists;
END IF;
    IF nazwa_bandy = banda.nazwa THEN
      RAISE nazwa_exists;
END IF;
    IF teren_bandy = banda.teren THEN
      RAISE teren_exists;
END IF;
END LOOP;

INSERT INTO Bandy VALUES (nr, nazwa_bandy, teren_bandy, NULL);

EXCEPTION
  WHEN banda_exists THEN
  DBMS_OUTPUT.PUT_LINE(TO_CHAR(nr) || ' już istnieje');
WHEN nazwa_exists THEN
  DBMS_OUTPUT.PUT_LINE(TO_CHAR(nazwa_bandy) || ' już istnieje');
WHEN teren_exists THEN
  DBMS_OUTPUT.PUT_LINE(TO_CHAR(teren_bandy) || ' już istnieje');
WHEN banda_nr_exc THEN
  DBMS_OUTPUT.PUT_LINE('Numer bandy nie może być <= 0');
WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;
ROLLBACK;


























-- Lab 40
CREATE OR REPLACE PROCEDURE UtworzBande(nr NUMBER, nazwa_bandy VARCHAR2, teren_bandy VARCHAR2) AS
  CURSOR bandyC IS SELECT * FROM Bandy;
banda bandy%ROWTYPE;

    banda_nr_exc EXCEPTION;
    banda_exists EXCEPTION;
    nazwa_exists EXCEPTION;
    teren_exists EXCEPTION;
BEGIN
    IF nr <= 0 THEN
      RAISE banda_nr_exc;
END IF;

OPEN bandyC;

LOOP
FETCH bandyC INTO banda;
      EXIT WHEN bandyC%NOTFOUND;

      IF nr = banda.nr_bandy THEN
        RAISE banda_exists;
END IF;
      IF nazwa_bandy = banda.nazwa THEN
        RAISE nazwa_exists;
END IF;
      IF teren_bandy = banda.teren THEN
        RAISE teren_exists;
END IF;
END LOOP;

INSERT INTO Bandy VALUES (nr, nazwa_bandy, teren_bandy, NULL);

EXCEPTION
    WHEN banda_exists THEN
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(nr) || ' już istnieje');
WHEN nazwa_exists THEN
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(nazwa_bandy) || ' już istnieje');
WHEN teren_exists THEN
    DBMS_OUTPUT.PUT_LINE(TO_CHAR(teren_bandy) || ' już istnieje');
WHEN banda_nr_exc THEN
    DBMS_OUTPUT.PUT_LINE('Numer bandy nie może być <= 0');
WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE(SQLERRM);
END;































-- Lab 41
CREATE OR REPLACE TRIGGER one_more_number
BEFORE INSERT ON Bandy
FOR EACH ROW
BEGIN
SELECT MAX(nr_bandy) + 1 INTO :NEW.nr_bandy FROM Bandy;
END;

-- TEST
BEGIN
  UtworzBande(9, 'KOT', 'AAA');
END;
SELECT * FROM bandy;
ROLLBACK;



























--Lab 42a
CREATE OR REPLACE PACKAGE wirus AS
  active BOOLEAN := FALSE;
  down BOOLEAN := FALSE;
  mutex BOOLEAN := FALSE;
  min_przydzial NUMBER;
END;

CREATE OR REPLACE PACKAGE BODY wirus AS
BEGIN
  mutex := FALSE;
END;

CREATE OR REPLACE TRIGGER wirus_set
BEFORE UPDATE ON Kocury
BEGIN
SELECT przydzial_myszy INTO wirus.min_przydzial FROM Kocury WHERE pseudo = 'TYGRYS';

END;

CREATE OR REPLACE TRIGGER wirus_przed
BEFORE UPDATE ON Kocury
                  FOR EACH ROW
BEGIN
    IF :NEW.funkcja = 'MILUSIA' AND NOT wirus.mutex THEN
      wirus.active := TRUE;

      IF :NEW.przydzial_myszy < :OLD.przydzial_myszy THEN
        :NEW.przydzial_myszy := :OLD.przydzial_myszy;
END IF;
      IF :NEW.przydzial_myszy - :OLD.przydzial_myszy <  0.1 * wirus.min_przydzial THEN
        :NEW.przydzial_myszy := :NEW.przydzial_myszy + 0.1 * wirus.min_przydzial ;
        :NEW.myszy_extra := :NEW.myszy_extra + 5;
        wirus.down := TRUE;
END IF;
END IF;
END;

CREATE OR REPLACE TRIGGER wirus_po
AFTER UPDATE ON Kocury
BEGIN
      IF wirus.active THEN
        wirus.mutex := TRUE;
        wirus.active := FALSE;
        IF wirus.down THEN
          wirus.down := FALSE;
UPDATE kocury SET przydzial_myszy = przydzial_myszy - 0.1 * wirus.min_przydzial WHERE pseudo = 'TYGRYS';
ELSE
UPDATE kocury SET myszy_extra = myszy_extra + 5 WHERE pseudo = 'TYGRYS';
END IF;
        wirus.mutex := FALSE;
END IF;
END;

ALTER TRIGGER wirus_set ENABLE;
ALTER TRIGGER wirus_przed ENABLE;
ALTER TRIGGER wirus_po ENABLE;

ALTER TRIGGER wirus_set DISABLE;
ALTER TRIGGER wirus_przed DISABLE;
ALTER TRIGGER wirus_po DISABLE;

SELECT * FROM kocury WHERE funkcja = 'MILUSIA';
UPDATE kocury
SET przydzial_myszy = 20
WHERE funkcja = 'MILUSIA';
ROLLBACK;

--Lab 42b

CREATE OR REPLACE TRIGGER wirus_compound
FOR UPDATE ON Kocury
               COMPOUND TRIGGER
               active BOOLEAN:=FALSE;
down BOOLEAN:=FALSE;
  min_przydzial NUMBER;

  BEFORE STATEMENT IS
BEGIN
SELECT 0.1 * przydzial_myszy INTO min_przydzial FROM Kocury WHERE pseudo = 'TYGRYS';
END BEFORE STATEMENT;

  BEFORE EACH ROW IS
BEGIN
    IF :NEW.funkcja = 'MILUSIA' THEN
      active := TRUE;

      IF (:NEW.przydzial_myszy < :OLD.przydzial_myszy) THEN
        :NEW.przydzial_myszy := :OLD.przydzial_myszy;
END IF;
      IF :NEW.przydzial_myszy - :OLD.przydzial_myszy <  min_przydzial THEN
        :NEW.przydzial_myszy := :NEW.przydzial_myszy + 0.1 * wirus.min_przydzial ;
        :NEW.myszy_extra := :NEW.myszy_extra + 5;
        down := TRUE;
END IF;
END IF;
END BEFORE EACH ROW;

  AFTER EACH ROW IS
BEGIN
NULL;
END AFTER EACH ROW;

  AFTER STATEMENT IS
BEGIN
    IF active THEN
      IF down THEN
UPDATE kocury SET przydzial_myszy = przydzial_myszy - min_przydzial WHERE pseudo = 'TYGRYS';
ELSE
UPDATE kocury SET myszy_extra = myszy_extra + 5 WHERE pseudo = 'TYGRYS';
END IF;
END IF;
    active := FALSE;
    down := FALSE;
END AFTER STATEMENT;
END;

ALTER TRIGGER wirus_compound DISABLE;

SELECT * FROM kocury WHERE funkcja = 'MILUSIA';
UPDATE kocury
SET przydzial_myszy = przydzial_myszy + 1
WHERE funkcja = 'MILUSIA';
ROLLBACK;























--Lab 43
DECLARE
CURSOR bandyC IS SELECT * FROM Bandy ORDER BY nazwa;
banda bandy%ROWTYPE;
CURSOR funkcjeC IS SELECT * FROM Funkcje ORDER BY funkcja;
funkcja funkcjeC%ROWTYPE;
  suma NUMBER;
  singlerow VARCHAR2(500);
BEGIN

  singlerow := RPAD('NAZWA BANDY', 15);
  singlerow := singlerow || ' | ' || RPAD('PLEC', 5);
OPEN funkcjeC;
LOOP
FETCH funkcjeC INTO funkcja;
    EXIT WHEN funkcjeC%NOTFOUND;
    singlerow := singlerow || ' | ' || RPAD(funkcja.funkcja, 10);
END LOOP;
CLOSE funkcjeC;
singlerow := singlerow || ' | ' || RPAD('SUMA', 10);
  DBMS_OUTPUT.PUT_LINE(singlerow);
  singlerow:='';

  singlerow := RPAD('-', 15, '-');
  singlerow := singlerow || '-|-' || RPAD('-', 5, '-');
OPEN funkcjeC;
LOOP
FETCH funkcjeC INTO funkcja;
    EXIT WHEN funkcjeC%NOTFOUND;
    singlerow := singlerow || '-|-' || RPAD('-', 10, '-');
END LOOP;
CLOSE funkcjeC;
singlerow := singlerow || '-|-' || RPAD('-', 10, '-');
  DBMS_OUTPUT.PUT_LINE(singlerow);
  singlerow:='';

OPEN bandyc;
LOOP
FETCH bandyC INTO banda;
    EXIT WHEN bandyC%NOTFOUND;

    singlerow := RPAD(banda.nazwa, 15);
    singlerow := singlerow || ' | ' || RPAD('KOTKA', 5);

OPEN funkcjeC;
LOOP
FETCH funkcjeC INTO funkcja;
      EXIT WHEN funkcjeC%NOTFOUND;
SELECT NVL(SUM(przydzial_myszy + NVL(myszy_extra, 0)), 0) INTO suma
FROM Kocury
WHERE nr_bandy = banda.nr_bandy
  AND funkcja = funkcja.funkcja
  AND plec = 'D';
singlerow := singlerow || ' | ' || RPAD(TO_CHAR(suma), 10);
END LOOP;
CLOSE funkcjeC;

SELECT NVL(SUM(przydzial_myszy + NVL(myszy_extra, 0)), 0) INTO suma
FROM Kocury
WHERE nr_bandy = banda.nr_bandy
  AND plec = 'D';
singlerow := singlerow || ' | ' || RPAD(TO_CHAR(suma), 10);
    DBMS_OUTPUT.PUT_LINE(singlerow);
    singlerow:='';

    singlerow := RPAD(banda.nazwa, 15);
    singlerow := singlerow || ' | ' || RPAD('KOCUR', 5);

OPEN funkcjeC;
LOOP
FETCH funkcjeC INTO funkcja;
      EXIT WHEN funkcjeC%NOTFOUND;
SELECT NVL(SUM(przydzial_myszy + NVL(myszy_extra, 0)), 0) INTO suma
FROM Kocury
WHERE nr_bandy = banda.nr_bandy
  AND funkcja = funkcja.funkcja
  AND plec = 'M';
singlerow := singlerow || ' | ' || RPAD(TO_CHAR(suma), 10);
END LOOP;
CLOSE funkcjeC;
SELECT NVL(SUM(przydzial_myszy + NVL(myszy_extra, 0)), 0) INTO suma
FROM Kocury
WHERE nr_bandy = banda.nr_bandy
  AND plec = 'M';
singlerow := singlerow || ' | ' || RPAD(TO_CHAR(suma), 10);
    DBMS_OUTPUT.PUT_LINE(singlerow);
    singlerow:='';
END LOOP;
CLOSE bandyC;

singlerow := RPAD('Z', 15, '-');
  singlerow := singlerow || '-|-' || RPAD('-', 5, '-');
OPEN funkcjeC;
LOOP
FETCH funkcjeC INTO funkcja;
    EXIT WHEN funkcjeC%NOTFOUND;
    singlerow := singlerow || '-|-' || RPAD('-', 10, '-');
END LOOP;
CLOSE funkcjeC;
singlerow := singlerow || '-|-' || RPAD('-', 10, '-');
  DBMS_OUTPUT.PUT_LINE(singlerow);
  singlerow:='';

  singlerow := RPAD('ZJADA RAZEM', 15);
  singlerow := singlerow || ' | ' || RPAD(' ', 5);

OPEN funkcjeC;
LOOP
FETCH funkcjeC INTO funkcja;
    EXIT WHEN funkcjeC%NOTFOUND;
SELECT NVL(SUM(przydzial_myszy + NVL(myszy_extra, 0)), 0) INTO suma
FROM Kocury
WHERE funkcja = funkcja.funkcja;
singlerow := singlerow || ' | ' || RPAD(TO_CHAR(suma), 10);
END LOOP;
CLOSE funkcjeC;
SELECT NVL(SUM(przydzial_myszy + NVL(myszy_extra, 0)), 0) INTO suma
FROM Kocury;
singlerow := singlerow || ' | ' || RPAD(TO_CHAR(suma), 10);
  DBMS_OUTPUT.PUT_LINE(singlerow);
  singlerow:='';
END;


























--Lab 44
CREATE OR REPLACE FUNCTION podatek(pseudonim VARCHAR2, inny NUMBER := 0)
  RETURN NUMBER AS
  podstawowy NUMBER;
  podwladni NUMBER;
  wrogowie NUMBER;
BEGIN
SELECT 0.05 * przydzial_myszy INTO podstawowy FROM Kocury WHERE pseudo = pseudonim;
SELECT COUNT(*) INTO podwladni FROM Kocury WHERE szef = pseudonim;
SELECT COUNT(*) INTO wrogowie FROM Wrogowie_kocurow WHERE pseudo = pseudonim;

IF podwladni > 0 THEN
      podwladni := 0;
ELSE
      podwladni := 2;
END IF;

    IF wrogowie > 0 THEN
      wrogowie := 0;
ELSE
      wrogowie := 1;
END IF;

RETURN podstawowy + podwladni + wrogowie + inny;
END;

SELECT podatek('PUSZYSTA') FROM dual;

























--Lab 45

CREATE TABLE Dodatki_extra(pseudo VARCHAR2(15), dodatek NUMBER);

CREATE OR REPLACE TRIGGER zemsta_tygrysa
FOR UPDATE ON Kocury
               COMPOUND TRIGGER
               active BOOLEAN:=FALSE;
sqlQuery VARCHAR2(50);
  exist NUMBER;
CURSOR milusieC IS SELECT * FROM Kocury WHERE funkcja = 'MILUSIE';
milusie milusieC%ROWTYPE;

  BEFORE STATEMENT IS
BEGIN
NULL;
END BEFORE STATEMENT;

  BEFORE EACH ROW IS
BEGIN
    IF :NEW.funkcja = 'MILUSIA' AND NOT SYS.LOGIN_USER = 'TYGRYS' THEN
      active := TRUE;
END IF;
END BEFORE EACH ROW;

  AFTER EACH ROW IS
BEGIN
NULL;
END AFTER EACH ROW;

  AFTER STATEMENT IS

BEGIN
    IF active THEN
      OPEN milusieC;

      LOOP
FETCH milusieC INTO milusie;
        EXIT WHEN milusieC%NOTFOUND;

SELECT COUNT(*) INTO exist FROM dodatki_extra WHERE pseudo = milusie.pseudo;
IF exist > 0 THEN
          sqlquery := 'UPDATE Dodatki_extra SET dodatek = dodatek - 10 WHERE funkcja = ''MILUSIA'';';
ELSE
          sqlquery := 'INSERT INTO Dodatki_extra VALUES (' || TO_CHAR(milusie.pseudo) ||', -10);';
END IF;

EXECUTE IMMEDIATE sqlquery;
END LOOP;

      active := FALSE;
END IF;
END AFTER STATEMENT;
END;



















--Lab 46
CREATE TABLE Log(kto VARCHAR2(20), kiedy DATE, kotu VARCHAR2(10), operacja VARCHAR2(2000));
DROP TABLE Log;

CREATE OR REPLACE TRIGGER constrain
BEFORE INSERT OR UPDATE ON Kocury
                            FOR EACH ROW
DECLARE
min_num NUMBER;
    max_num NUMBER;
    operation VARCHAR2;
BEGIN
SELECT min_myszy INTO min_num FROM Funkcje WHERE funkcja = :NEW.funkcja;
SELECT max_myszy INTO max_num FROM Funkcje WHERE funkcja = :NEW.funkcja;

operation := 'INSERTING';
    IF UPDATING THEN
      operation := 'UPDATING';
END IF;

    IF :NEW.przydzial_myszy < min_num OR :NEW.przydzial_myszy > max_num THEN
      INSERT INTO Log VALUES (SYS.LOGIN_USER, CURRENT_DATE, :NEW.pseudo, operation);
      :NEW.przydzial_myszy := :OLD.przydzial_myszy;
END IF;
END;


UPDATE kocury
SET przydzial_myszy = 31
WHERE pseudo = 'PUSZYSTA';
SELECT * FROM Log;
SELECT * FROM kocury WHERE pseudo = 'PUSZYSTA';
DELETE FROM LOG;





































































-- Zad. 35. Napisać blok PL/SQL, który wyprowadza na ekran następujące informacje o kocie o pseudonimie wprowadzonym
-- z klawiatury (w zależności od rzeczywistych danych):
-- -	'calkowity roczny przydzial myszy >700'
-- -	'imię zawiera litere A'
-- -	'styczeń jest miesiacem przystapienia do stada'
-- -	'nie odpowiada kryteriom'.
-- Powyższe informacje wymienione są zgodnie z hierarchią ważności. Każdą wprowadzaną informację poprzedzić imieniem kota.
DECLARE
imie Kocury.imie%TYPE;
    przydzial Number;
    miesiac number;
found BOOLEAN default false;
BEGIN
Select  imie, (nvl(przydzial_myszy,0)+nvl(myszy_ekstra,0))*12, EXtract(month from w_stadku_od)
INTO imie, przydzial, miesiac
From Kocury
Where pseudo = UPPER($(pseudonim));

If przydzial > 700 then dbms_output.put_line(imie || ' calkowity przydzial myszy > 700');
found := true;
eND IF;
    if miesiac = 1 then dbms_output.put_line(imie || ' styczen jest miesiacem przystapienia do stada');
found := true;
eND IF;
    if imie LIKE '%A%' THEN DBMS_OUTPUT.PUT_LINE(imie || ' imie zawiera litere A');
found := true;
END IF;
    IF not found then dbms_output.put_line(imie || ' nie odpowiada kryteriom');
END IF;
Exception
    when no_data_found then dbms_output.put_line('Nie znaleziono takiego kota');
when others then dbms_output.put_line(sqlerrm);
END;
-- Zad. 36. W związku z dużą wydajnością w łowieniu myszy SZEFUNIO postanowił wynagrodzić swoich podwładnych. Ogłosił więc,
-- że podwyższa indywidualny przydział myszy każdego kota o 10% poczynając od kotów o najniższym przydziale. Jeśli w którymś
-- momencie suma wszystkich przydziałów przekroczy 1050, żaden inny kot nie dostanie podwyżki. Jeśli przydział myszy po podwyżce
-- przekroczy maksymalną wartość należną dla pełnionej funkcji (relacja Funkcje), przydział myszy po podwyżce ma być równy tej wartości.
-- Napisać blok PL/SQL z kursorem, który wyznacza sumę przydziałów przed podwyżką a realizuje to zadanie. Blok ma działać tak długo,
-- aż suma wszystkich przydziałów rzeczywiście przekroczy 1050 (liczba „obiegów podwyżkowych” może być większa od 1 a więc i podwyżka
-- może być większa niż 10%). Wyświetlić na ekranie sumę przydziałów myszy po wykonaniu zadania wraz z liczbą podwyżek (liczbą zmian w
-- relacji Kocury). Na końcu wycofać wszystkie zmiany.
DECLARE
suma_przydzialow number default 0;
  liczba_zmian number default 0;
  max_przydzial number default 0;

cursor kursor is
SELECT pseudo, PRZYDZIAL_MYSZY, FUNKCJA FROM KOCURY order by PRZYDZIAL_MYSZY for update of PRZYDZIAL_MYSZY;

wiersz kursor%ROWTYPE;
BEGIN
SELECT SUM(PRZYDZIAL_MYSZY) into suma_przydzialow from KOCURY; --dotychczasowe przydziały

<<loop1>>LOOP
    open kursor;
    LOOP
fetch kursor into wiersz;     --aktualny wiersz kursora
        exit when kursor%notfound;

SELECT MAX_MYSZY into max_przydzial from FUNKCJE where FUNKCJA=wiersz.FUNKCJA; --max przydzial dla funkcji z kursora

IF (1.1*wiersz.PRZYDZIAL_MYSZY <= max_przydzial) then
UPDATE KOCURY
SET PRZYDZIAL_MYSZY = round(1.1*wiersz.PRZYDZIAL_MYSZY)
where wiersz.PSEUDO=PSEUDO;

liczba_zmian:=liczba_zmian+1;
              suma_przydzialow:=suma_przydzialow + round(0.1*wiersz.PRZYDZIAL_MYSZY);
        elsif (wiersz.PRZYDZIAL_MYSZY != max_przydzial) then
UPDATE KOCURY
SET PRZYDZIAL_MYSZY=max_przydzial
where wiersz.PSEUDO=PSEUDO;
liczba_zmian:=liczba_zmian+1;
              suma_przydzialow:=suma_przydzialow + (max_przydzial-wiersz.PRZYDZIAL_MYSZY);
end if;
      exit loop1 when suma_przydzialow>1050;
end loop ;
close kursor;
end loop loop1;
  dbms_output.put_line('Calk. przydzial w stadku ' || suma_przydzialow);
  dbms_output.put_line('Zmian - ' || liczba_zmian);
end;
select imie, NVL(przydzial_myszy,0) "Myszki po podwyzce" from Kocury order by PRZYDZIAL_MYSZY desc ;

rollback;


-- Zad. 37. Napisać blok, który powoduje wybranie w pętli kursorowej FOR pięciu kotów o najwyższym całkowitym przydziale myszy.
-- Wynik wyświetlić na ekranie.
Declare
nr number default 1;
    empty exception;
    sa_koty boolean default false;

Begin
  DBMS_OUTPUT.PUT_LINE('Nr    Pseudonim    Zjada'); --naglowek
  DBMS_OUTPUT.PUT_LINE('~~~~~~~~~~~~~~~~~~~~~~~~~~');

For kot in ( SELECT pseudo, nvl(przydzial_myszy,0)+nvl(myszy_ekstra,0) zjada From Kocury order by zjada desc) Loop
    sa_koty := true;
    dbms_output.put_line(LPAD(nr,2) || ' ' || LPAD(kot.pseudo,12 )|| ' ' || LPAD(kot.zjada,10));
    nr := nr+1;
    exit when nr > 5;
end loop;
    if sa_koty = false then raise empty;
end if;
EXCEPTION
  WHEN empty THEN DBMS_OUTPUT.PUT_LINE('Nie ma kotow');
WHEN OTHERS THEN DBMS_OUTPUT.PUT_LINE(sqlerrm);
end;

-- Zad. 38. Napisać blok, który zrealizuje wersję a. lub wersję b. zad. 19 w sposób uniwersalny (bez konieczności uwzględniania
-- wiedzy o głębokości drzewa). Daną wejściową ma być maksymalna liczba wyświetlanych przełożonych.
--19b
DECLARE
max_poziom number default 0;
  poziom number default 1;
  liczba_poziomow number default $(liczba_szefow);
kot Kocury%ROWTYPE;
BEGIN
SELECT MAX(level)-1 into max_poziom FROM KOCURY connect by prior PSEUDO = SZEF start with szef is null ;
liczba_poziomow := least(max_poziom, liczba_poziomow);  --czy ten podany czy max (bo moze max mniejszy)
  --naglowek--
  dbms_output.put('Imie        ');
for i in 1..liczba_poziomow loop
        dbms_output.put('  |  ' || rpad('Szef ' || i, 10));
end loop;
  dbms_output.new_line();

  dbms_output.put('--------------');
for i in 1..liczba_poziomow loop
      dbms_output.put(' --------------');
end loop;
  dbms_output.new_line();
  ------

for wiersz in (SELECT * from Kocury where funkcja in ('MILUSIA', 'KOT')) loop
      poziom :=1;
      dbms_output.put(RPAD(wiersz.imie,10));
      kot :=wiersz;

      while poziom <= liczba_poziomow loop
        IF kot.SZEF is null then
          dbms_output.put(RPAD(' ',15));
ELSE
SELECT * into kot from KOCURY where KOt.SZEF=pseudo;
dbms_output.put(LPAD(kot.imie,15));
end if;
        poziom :=poziom+1;
end loop;
    dbms_output.new_line();
end loop;
end;
-- Zad. 39. Napisać blok PL/SQL wczytujący trzy parametry reprezentujące nr bandy, nazwę bandy oraz teren polowań. Skrypt ma
-- uniemożliwiać wprowadzenie istniejących już wartości parametrów poprzez obsługę odpowiednich wyjątków. Sytuacją wyjątkową
-- jest także wprowadzenie numeru bandy <=0. W przypadku zaistnienia sytuacji wyjątkowej należy wyprowadzić na ekran odpowiedni
-- komunikat. W przypadku prawidłowych parametrów należy stworzyć nową bandę w relacji Bandy. Zmianę należy na końcu wycofać.
DECLARE
nrB number := $(numer);
nazwaB varchar2(20) := UPPER($(nazwa));
terenB varchar2(15) := UPPER($(teren));
blad varchar2(256) := '';
    ilosc number :=0;
    zlaliczba exception;
    istnieje exception;
BEGIN

    IF nrB <=0 then raise zlaliczba;
end if;

Select count(nr_bandy) into ilosc from Bandy where nr_bandy = nrB;   --ile jest takich band co podany numer
IF ilosc > 0 then blad := TO_char(nrB); end if;

Select count(nazwa) into ilosc from Bandy where nazwaB=nazwa;
IF ilosc > 0 then
        if length(blad)>0 then blad:= blad || ', ' || nazwaB;
else blad := nazwaB ;
end if;
end if;
Select count(teren) into ilosc from Bandy where terenB=teren ;
IF ilosc > 0 then
        IF length(blad) >0 then blad := blad || ', ' || terenB;
else blad := terenB;
end if;
end if;

    If length(blad)>0 then raise istnieje; end if;

INSERT INTO Bandy (nr_bandy, nazwa, teren) values (nrB, nazwaB, terenB) ;

EXCEPTION
        WHEN zlaliczba then DBMS_OUTPUT.PUT_LINE('Liczba musi byc >0! ');
WHEN istnieje then DBMS_OUTPUT.PUT_LINE(blad || ' :wartosc juz istnieje');
END;
rollback;
Select * from bandy;

--Zad. 40. Przerobić blok z zadania 39 na procedurę umieszczoną w bazie danych.
CREATE OR REPLACE PROCEDURE nowa_banda(nrB Bandy.nr_bandy%TYPE, nazwaB bandy.nazwa%TYPE, terenB bandy.teren%TYPE)
  IS
    blad STRING(256) := '';
    jest number :=0;
    zlaliczba exception;
    istnieje exception;
BEGIN

    IF nrB <=0 then raise zlaliczba;
end if;

Select count(nr_bandy) into jest from Bandy where nr_bandy = nrB;   --ile jest takich band co podany numer
IF jest > 0 then blad := TO_char(nrB); end if;

Select count(nazwa) into jest from Bandy where nazwaB=nazwa;
IF jest > 0 then
        if length(blad)>0 then blad:= blad || ', ' || nazwaB;
else blad := nazwaB ;
end if;
end if;
Select count(teren) into jest from Bandy where terenB=teren ;
IF jest > 0 then
        IF length(blad) >0 then blad := blad || ', ' || terenB;
else blad := terenB;
end if;
end if;

    If length(blad)>0 then raise istnieje; end if;

INSERT INTO Bandy (nr_bandy, nazwa, teren) values (nrB, nazwaB, terenB) ;

EXCEPTION
        WHEN zlaliczba then DBMS_OUTPUT.PUT_LINE('Liczba musi byc >0! ');
WHEN istnieje then DBMS_OUTPUT.PUT_LINE(blad || ' :wartosc juz istnieje');
END;

rollback;
begin
    nowa_banda(1, 'SZEFOSTWO', 'SAD');
end;
Select * from bandy;
SELECT * from USER_OBJECTS;
DROP procedure nowa_banda;
-- Zad. 41. Zdefiniować wyzwalacz, który zapewni, że numer nowej bandy będzie zawsze większy o 1 od najwyższego numeru
-- istniejącej już bandy. Sprawdzić działanie wyzwalacza wykorzystując procedurę z zadania 40.

create or replace trigger aut_nr_bandy
  BEFORE insert on BANDY                  --ogolnie to nie wykona sie jesli numer juz istnieje w tabeli - bo nie dojdzie do inserta
  for each row                            --nie ma dostepu do new i old bez tego,  wywolany kilka razy, zmienic kilka wierszy, dane dla kazdego wiersza
  DECLARE ost_numer number default 0;
BEGIN
SELECT MAX(NR_BANDY)+1 into ost_numer from BANDY;
--dbms_output.put_line(ost_numer);
:NEW.NR_BANDY:=ost_numer;
end;

begin
    nowa_banda(10, 'nazwa2', 'teren2');
end;
Select * from bandy;
rollback;
drop trigger aut_nr_bandy;
-- Zad. 42. Milusie postanowiły zadbać o swoje interesy. Wynajęły więc informatyka, aby zapuścił wirusa w system Tygrysa.
-- Teraz przy każdej próbie zmiany przydziału myszy na plus (o minusie w ogóle nie może być mowy) o wartość mniejszą niż 10%
-- przydziału myszy Tygrysa żal Miluś ma być utulony podwyżką ich przydziału o tą wartość oraz podwyżką myszy extra o 5. Tygrys
-- ma być ukarany stratą wspomnianych 10%. Jeśli jednak podwyżka będzie satysfakcjonująca, przydział myszy extra Tygrysa ma wzrosnąć o 5.

-- Zaproponować dwa rozwiązania zadania, które ominą podstawowe ograniczenie dla wyzwalacza wierszowego aktywowanego poleceniem
-- DML tzn. brak możliwości odczytu lub zmiany relacji, na której operacja (polecenie DML) „wyzwala” ten wyzwalacz. W pierwszym
-- rozwiązaniu (klasycznym) wykorzystać kilku wyzwalaczy i pamięć w postaci specyfikacji dedykowanego zadaniu pakietu, w drugim
-- wykorzystać wyzwalacz COMPOUND.

-- Podać przykład funkcjonowania wyzwalaczy a następnie zlikwidować wprowadzone przez nie zmiany.

create or replace package pamiec as
  przydzial_tygr number default 0;
  nagroda number default 0;
  strata number default 0;
end;

  create or replace trigger przydzial_tygrysa
    before update on KOCURY
begin
SELECT PRZYDZIAL_MYSZY into pamiec.przydzial_tygr from KOCURY where PSEUDO = 'TYGRYS';
end;

  create or replace trigger zmiany
    before update on KOCURY
                        for each row
declare
roznica number default 0;
begin
      if :new.FUNKCJA = 'MILUSIA' then                          --dla modyfikacji milus
          IF :new.PRZYDZIAL_MYSZY <= :old.PRZYDZIAL_MYSZY then  --przydzial w dol - nie ma mowy
              dbms_output.put_line('Nie mozna zmienić przydziału '|| :old.PSEUDO||' z '|| :old.PRZYDZIAL_MYSZY||' na '|| :new.PRZYDZIAL_MYSZY);
              :new.PRZYDZIAL_MYSZY := :old.PRZYDZIAL_MYSZY;     --zostaje ten sam przydzial
else
              roznica := :new.PRZYDZIAL_MYSZY - :old.PRZYDZIAL_MYSZY;
              IF roznica < 0.1*pamiec.przydzial_tygr  then            --mniej niz 10proc tygrysa
--                 dbms_output.put_line(roznica || '  prz tygr: '|| pamiec.przydzial_tygr);
                dbms_output.put_line('Kara za zmiane '|| :old.PSEUDO||' z '|| :old.PRZYDZIAL_MYSZY||' na '|| :new.PRZYDZIAL_MYSZY);
                  pamiec.strata := pamiec.strata+1;                   --+ kara dla tygrysa
                  :new.PRZYDZIAL_MYSZY := :new.PRZYDZIAL_MYSZY + 0.1*pamiec.przydzial_tygr; --+10proc tygrysa dla milus
                  :new.MYSZY_EKSTRA := :new.MYSZY_EKSTRA + 5;                               --+5myszy ekstra
              elsif roznica > 0.1*pamiec.przydzial_tygr then           --wiecej niz 10proc tygrysa
                  pamiec.nagroda := pamiec.nagroda+1;                  --+ nagroda dla tygrysa
                  dbms_output.put_line('Nagroda za zmiane '|| :old.PSEUDO||' z '|| :old.PRZYDZIAL_MYSZY||' na '|| :new.PRZYDZIAL_MYSZY);
end if;
end if;
end if;
end;

  create or replace trigger zmiany_tygrysa
    after update on KOCURY
declare
pom number default 0;
begin
        IF pamiec.strata >0 then
            pom:= pamiec.strata;
            pamiec.strata :=0;        --zeby sie ten trigger nie odpalal za kazdym razem jak wywolamy dolna linijke - zapetlenie
update KOCURY set PRZYDZIAL_MYSZY = FLOOR(PRZYDZIAL_MYSZY - PRZYDZIAL_MYSZY*0.1*pom) where PSEUDO='TYGRYS';  --odejmujemy 10proc tyle razy ile kar
dbms_output.put_line('Zabrano '|| FLOOR(pamiec.przydzial_tygr*0.1*pom)||' przydzialu myszy tygrysowi.');
end if;
        IF pamiec.nagroda >0 then
            pom := pamiec.nagroda;
            pamiec.nagroda:=0;
update KOCURY set MYSZY_EKSTRA  = MYSZY_EKSTRA+(5*pom) where PSEUDO='TYGRYS';
dbms_output.put_line('Dodano '|| 5*pom ||' myszy ekstra tygrysowi');
end if;
end;

select * from KOCURY;
update KOCURY set PRZYDZIAL_MYSZY = (PRZYDZIAL_MYSZY +19) where FUNKCJA='MILUSIA';
rollback ;

drop trigger przydzial_tygrysa;
drop trigger zmiany;
drop trigger zmiany_tygrysa;
drop package pamiec;
-- update KOCURY set PRZYDZIAL_MYSZY = 103 where PSEUDO='TYGRYS';

--42b-------------------------------------------------------------
drop trigger wirus;
create or replace trigger wirus
  for update on KOCURY
                 compound trigger
                 przydzial_tygr number default 0;
nagroda number default 0;
    strata number default 0;
    roznica number default 0;
    pom number default 0;

  before statement is begin --pierwszy trigger
SELECT PRZYDZIAL_MYSZY into  przydzial_tygr from KOCURY where PSEUDO='TYGRYS';
end before statement ;

  before each row is begin  --drugi trigger
      if :new.FUNKCJA = 'MILUSIA' then                          --dla modyfikacji milus
          IF :new.PRZYDZIAL_MYSZY <= :old.PRZYDZIAL_MYSZY then  --przydzial w dol - nie ma mowy
              dbms_output.put_line('Nie mozna zmienić przydziału '|| :old.PSEUDO||' z '|| :old.PRZYDZIAL_MYSZY||' na '|| :new.PRZYDZIAL_MYSZY);
              :new.PRZYDZIAL_MYSZY := :old.PRZYDZIAL_MYSZY;     --zostaje ten sam przydzial
else
              roznica := :new.PRZYDZIAL_MYSZY - :old.PRZYDZIAL_MYSZY;
              IF roznica < 0.1*przydzial_tygr  then            --mniej niz 10proc tygrysa
                dbms_output.put_line(roznica || '  prz tygr: '|| przydzial_tygr);
                dbms_output.put_line('Kara za zmiane '|| :old.PSEUDO||' z '|| :old.PRZYDZIAL_MYSZY||' na '|| :new.PRZYDZIAL_MYSZY);
                  strata := strata+1;                   --+ kara dla tygrysa
                  :new.PRZYDZIAL_MYSZY := :new.PRZYDZIAL_MYSZY + 0.1*przydzial_tygr; --+10proc tygrysa dla milus
                  :new.MYSZY_EKSTRA := :new.MYSZY_EKSTRA + 5;                               --+5myszy ekstra
              elsif roznica > 0.1*przydzial_tygr then           --wiecej niz 10proc tygrysa
                  nagroda := nagroda+1;                  --+ nagroda dla tygrysa
                  dbms_output.put_line('Nagroda za zmiane '|| :old.PSEUDO||' z '|| :old.PRZYDZIAL_MYSZY||' na '|| :new.PRZYDZIAL_MYSZY);
end if;
end if;
end if;
end before each row ;

  after statement is begin
      IF strata >0 then
            pom:= strata;
            strata :=0;        --zeby sie ten trigger nie odpalal za kazdym razem jak wywolamy dolna linijke
update KOCURY set PRZYDZIAL_MYSZY = FLOOR(PRZYDZIAL_MYSZY - PRZYDZIAL_MYSZY*0.1*pom) where PSEUDO='TYGRYS';  --odejmujemy 10proc tyl razy ile kar
dbms_output.put_line('Zabrano '|| FLOOR(przydzial_tygr*0.1*pom)||' przydzialu myszy tygrysowi.');
end if;
        IF nagroda >0 then
            pom := nagroda;
            nagroda:=0;
update KOCURY set MYSZY_EKSTRA  = MYSZY_EKSTRA+(5*pom) where PSEUDO='TYGRYS';
dbms_output.put_line('Dodano '|| 5*pom ||' myszy ekstra tygrysowi');
end if;
end after statement ;
end;

-- Zad. 43. Napisać blok, który zrealizuje zad. 33 w sposób uniwersalny (bez konieczności uwzględniania wiedzy o
-- funkcjach pełnionych przez koty).
--      |||Zad. 33. Napisać zapytanie, w ramach którego obliczone zostaną sumy całkowitego spożycia myszy przez koty sprawujące każdą z
--       funkcji z podziałem na bandy i płcie kotów.|||

DECLARE
cursor funkcje is (SELECT funkcja from FUNKCJE);
    ilosc number;
BEGIN

   -- naglowek
    dbms_output.put('NAZWA BANDY       PLEC    ILE ');
for fun in funkcje loop
      dbms_output.put(RPAD(fun.funkcja,10));
end loop;

    dbms_output.put_line('    SUMA');
    dbms_output.put('----------------- ------ ----');

for fun in funkcje loop
          dbms_output.put(' ---------');
end loop;
    dbms_output.put_line(' --------');
            ------------
for banda in (SELECT nazwa, NR_BANDY from BANDY) loop
        for ple in (SELECT PLEC from KOCURY group by PLEC) loop
            dbms_output.put(case when ple.plec = 'M' then RPAD(banda.nazwa,18) else  RPAD(' ',18) end);
            dbms_output.put(case when ple.plec = 'M' then 'Kocor' else 'Kotka' end);

SELECT count(*) into ilosc FROM KOCURY where KOCURY.NR_BANDY = banda.NR_BANDY AND KOCURY.PLEC=ple.plec;  --ile kotow z dana banda i plcia
dbms_output.put(LPAD(ilosc,4));

for fun in funkcje loop
SELECT sum(NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EKSTRA,0)) into ilosc from KOCURY K
WHERE K.PLEC=ple.plec AND K.FUNKCJA=fun.FUNKCJA AND K.NR_BANDY=banda.NR_BANDY;    --ile kotow z dana banda, plcia i funkcja
dbms_output.put(LPAD(NVL(ilosc,0),10));
end loop;

SELECT SUM(NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EKSTRA,0)) into ilosc FROM KOCURY K where K.NR_BANDY=banda.NR_BANDY AND ple.PLEC=K.PLEC;
dbms_output.put(LPAD(NVL(ilosc,0),10));
            dbms_output.new_line();
end loop;
end loop;
    dbms_output.put('----------------- ------ ----');
for fun in funkcje loop dbms_output.put(' ---------'); end loop;
    dbms_output.put_line(' --------');


    dbms_output.put('Zjada razem                ');
for fun in funkcje loop
SELECT SUM(NVL(PRZYDZIAL_MYSZY,0)+NVL(MYSZY_EKSTRA,0)) into ilosc from Kocury K where K.FUNKCJA=fun.FUNKCJA;
dbms_output.put(LPAD(NVL(ilosc,0),10));
end loop;

SELECT sum(nvl(PRZYDZIAL_MYSZY,0)+nvl(MYSZY_EKSTRA,0)) into ilosc FROM Kocury;
dbms_output.put(LPAD(ilosc,10));
    dbms_output.new_line();
end;

-- Zad. 44. Tygrysa zaniepokoiło niewytłumaczalne obniżenie zapasów "myszowych". Postanowił więc wprowadzić podatek pogłówny, który zasiliłby spiżarnię.
-- Zarządził więc, że każdy kot ma obowiązek oddawać 5% (zaokrąglonych w górę) swoich całkowitych "myszowych" przychodów. Dodatkowo od tego co pozostanie:
-- -  koty nie posiadające podwładnych oddają po dwie myszy za nieudolność w umizgach o awans,
-- -  koty nie posiadające wrogów oddają po jednej myszy za zbytnią  ugodowość,
-- -  koty płacą dodatkowy podatek, którego formę określa wykonawca zadania.
-- Napisać funkcję, której parametrem jest pseudonim kota, wyznaczającą należny podatek pogłówny kota. Funkcję tą razem z procedurą z zad. 40
-- należy umieścić w pakiecie, a następnie wykorzystać ją do określenia podatku dla wszystkich kotów.


create or replace function podatek (pseudonim Kocury.pseudo%TYPE) return number is
    podatek number default 0;
    ile number default 0;
    data date ;
begin
select ceil(0.05*(nvl(PRZYDZIAL_MYSZY,0)+nvl(MYSZY_EKSTRA,0))) into podatek from KOCURY where pseudonim=KOCURY.PSEUDO; --5%

SELECT count(pseudo) into ile from KOCURY where SZEF = pseudonim;             --2 myszy jak nie ma podwladnych (nie jest szefem ani raz)
if ile <= 0 then podatek:=podatek+2; end if ;

SELECT count(pseudo) into ile from WROGOWIE_KOCUROW  where pseudo=pseudonim;  --1 mysz za brak wrogow
if ile <= 0 then podatek:=podatek+1; end if;

SELECT W_STADKU_OD into data from KOCURY WHERE pseudonim=pseudo;
if extract(year from data)= '2011' then podatek:=podatek+3; end if; --3 myszki od swiezakow (od 2011 w stadzie)

return podatek;
end;

  create or replace package podatek_package as
    function podatek(pseudonim Kocury.pseudo%TYPE) return number;
    procedure nowa_banda(nrB Bandy.nr_bandy%TYPE, nazwaB bandy.nazwa%TYPE, terenB bandy.teren%TYPE);
end podatek_package;

  create or replace package body podatek_package as
    function podatek (pseudonim Kocury.pseudo%TYPE) return number is
    podatek number default 0;
    ile number default 0;
    data date ;
begin
select ceil(0.05*(nvl(PRZYDZIAL_MYSZY,0)+nvl(MYSZY_EKSTRA,0))) into podatek from KOCURY where pseudonim=KOCURY.PSEUDO; --5%

SELECT count(pseudo) into ile from KOCURY where SZEF = pseudonim;             --2 myszy jak nie ma podwladnych (nie jest szefem ani raz)
if ile <= 0 then podatek:=podatek+2; end if ;

SELECT count(pseudo) into ile from WROGOWIE_KOCUROW  where pseudo=pseudonim;  --1 mysz za brak wrogow
if ile <= 0 then podatek:=podatek+1; end if;

SELECT W_STADKU_OD into data from KOCURY WHERE pseudonim=pseudo;
if extract(year from data)= '2011' then podatek:=podatek+3; end if; --3 myszki od swiezakow (od 2011 w stadzie)

return podatek;
end;

    PROCEDURE nowa_banda(nrB Bandy.nr_bandy%TYPE, nazwaB bandy.nazwa%TYPE, terenB bandy.teren%TYPE)
IS
      blad STRING(256) := '';
      jest number :=0;
      zlaliczba exception;
      istnieje exception;
BEGIN

    IF nrB <=0 then raise zlaliczba;
end if;

Select count(nr_bandy) into jest from Bandy where nr_bandy = nrB;   --ile jest takich band co podany numer
IF jest > 0 then blad := TO_char(nrB); end if;

Select count(nazwa) into jest from Bandy where nazwaB=nazwa;
IF jest > 0 then
        if length(blad)>0 then blad:= blad || ', ' || nazwaB;
else blad := nazwaB ;
end if;
end if;
Select count(teren) into jest from Bandy where terenB=teren ;
IF jest > 0 then
        IF length(blad) >0 then blad := blad || ', ' || terenB;
else blad := terenB;
end if;
end if;

    If length(blad)>0 then raise istnieje; end if;

INSERT INTO Bandy (nr_bandy, nazwa, teren) values (nrB, nazwaB, terenB) ;

EXCEPTION
        WHEN zlaliczba then DBMS_OUTPUT.PUT_LINE('Liczba musi byc >0! ');
WHEN istnieje then DBMS_OUTPUT.PUT_LINE(blad || ' :wartosc juz istnieje');
END;
end;

begin
  dbms_output.put(RPAD('PSEUDONIM',10));
  dbms_output.put(LPAD('PODATKEK PODGLOWNY',20));
  dbms_output.new_line();
for kocur in (SELECT PSEUDO from Kocury) loop
    dbms_output.put_line(RPAD(kocur.pseudo,10) || LPAD(podatek_package.podatek(kocur.pseudo),20));
end loop;
end;

drop function podatek;
drop package podatek_package;

-- Zad. 45. Tygrys zauważył dziwne zmiany wartości swojego prywatnego przydziału myszy (patrz zadanie 42). Nie niepokoiły go zmiany na plus ale te na minus
-- były, jego zdaniem, niedopuszczalne. Zmotywował więc jednego ze swoich szpiegów do działania i dzięki temu odkrył niecne praktyki Miluś (zadanie 42).
-- Polecił więc swojemu informatykowi skonstruowanie mechanizmu zapisującego w relacji Dodatki_extra (patrz Wykłady - cz. 2) dla każdej z Miluś -10
-- (minus dziesięć) myszy dodatku extra przy zmianie na plus któregokolwiek z przydziałów myszy Miluś, wykonanej przez innego operatora niż on sam. Zaproponować
-- taki mechanizm, w zastępstwie za informatyka Tygrysa. W rozwiązaniu wykorzystać funkcję LOGIN_USER zwracającą nazwę użytkownika aktywującego wyzwalacz oraz
-- elementy dynamicznego SQL'a

drop table DODATKI_EXTRA;
create table DODATKI_EXTRA (
                               ID_DODATKU number(2) generated by default on null as identity constraint dod_pk_id primary key,
                               PSEUDO varchar2(15) constraint dod_fg_pseudo references KOCURY(PSEUDO),
                               DODATEK_EXTRA number(3) not null
);

create or replace trigger check_extra
  before update of PRZYDZIAL_MYSZY on KOCURY
    for each row
declare
pragma autonomous_transaction ;
begin
    IF :new.FUNKCJA='MILUSIA' and :new.PRZYDZIAL_MYSZY> :old.PRZYDZIAL_MYSZY then
        IF LOGIN_USER != 'TYGRYS' then
          dbms_output.put('Zmian dokonal: ' || LOGIN_USER);
execute immediate '
declare
cursor milusie is select PSEUDO from KOCURY where FUNKCJA=''MILUSIA'';
begin
for milusia in milusie loop
                  insert into DODATKI_EXTRA(PSEUDO,DODATEK_EXTRA) values (milusia.PSEUDO, -10);
end loop;
end;';
commit ;
end if;
end if;
end;

UPDATE KOCURY
set PRZYDZIAL_MYSZY = PRZYDZIAL_MYSZY+10
where FUNKCJA='MILUSIA';
rollback ;
drop trigger check_extra;


-- Zad. 46. Napisać wyzwalacz, który uniemożliwi wpisanie kotu przydziału myszy spoza przedziału (min_myszy, max_myszy) określonego dla każdej funkcji w
-- relacji Funkcje. Każda próba wykroczenia poza obowiązujący przedział ma być dodatkowo monitorowana w osobnej relacji (kto, kiedy, jakiemu kotu, jaką operacją).

create table ZMIANA (
                        ID_ZMINAY number(2) generated by default on null as identity constraint pk_id primary key,
                        EDYTUJACY varchar2(15) not null,
                        DATA date not null,
                        EDYTOWANY varchar2(15) constraint fg_pseudo references KOCURY(PSEUDO),
                        OPERACJA varchar2(15) not null
);
-- Select * from KOCURY;
CREATE OR REPLACE TRIGGER check_ration
  before update on KOCURY
                    for each row
DECLARE
pragma AUTONOMOUS_TRANSACTION ;   --logi zostana na miejscu - w tabeli zmiana (albo pragma + commit albo łapiemy wyjątek w 'exception'
    maxm number default 0;
    minm number default 0;
--     zla_liczba exception ;
    edytujacy varchar2(15) default  ' ';
    edytowany varchar2(15) default  ' ';
    operacja varchar2(15) default  'INSERT';
BEGIN
select MAX_MYSZY, MIN_MYSZY into maxm, minm from FUNKCJe where funkcja=:new.FUNKCJA;

IF :new.PRZYDZIAL_MYSZY > maxm OR :new.PRZYDZIAL_MYSZY < minm then
      IF updating then operacja := 'UPDATE'; end if;
      edytowany := :new.pseudo;
      edytujacy := LOGIN_USER;
insert into ZMIANA(edytujacy,DATA,edytowany,operacja) values (edytujacy, sysdate, edytowany, operacja);
commit ;
raise_application_error(-20001,'Dana wartosc jest za duza lub za mala. Nie wykonano zmian.');
end if;
--     exception when zla_liczba then dbms_output.put_line('Dana wartosc jest za duza lub za mala. Nie wykonano zmian.');
end;

update KOCURY
set PRZYDZIAL_MYSZY = 60 --za duzo - kot ma max 60
where PSEUDO='UCHO';
select * from zmiana;
rollback;
drop trigger check_ration;
DROP table ZMIANA;











-- Zad. 35
DECLARE
CURSOR c_kocury (p_pseudonim VARCHAR2) IS
SELECT
    imie,
    (nvl(przydzial_myszy, 0) + nvl(myszy_extra, 0)) * 12,
    EXTRACT(MONTH FROM w_stadku_od)
FROM
    kocury
WHERE
    pseudo = upper(p_pseudonim);

k_imie      kocury.imie%TYPE;
    k_przydzial NUMBER;
    k_miesiac   NUMBER;

BEGIN
OPEN c_kocury(?);
FETCH c_kocury INTO k_imie, k_przydzial, k_miesiac;

IF c_kocury%FOUND THEN
        IF k_przydzial > 700 THEN
            dbms_output.put_line('calkowity roczny przydzial myszy >700');
        ELSIF k_imie LIKE '%A%' THEN
            dbms_output.put_line('imię zawiera literę A');
        ELSIF k_miesiac = 5 THEN
            dbms_output.put_line('maj jest miesiącem przystąpienia do stada');
ELSE
            dbms_output.put_line('nie odpowiada kryteriom');
END IF;
ELSE
        dbms_output.put_line('BRAK TAKIEGO KOTA');
END IF;

CLOSE c_kocury;

EXCEPTION
    WHEN OTHERS THEN
        dbms_output.put_line('Inny błąd');
END;



-- Zad. 36
DECLARE
suma_przydzialow NUMBER := 0;
  liczba_zmian NUMBER := 0;
  max_przydzial NUMBER := 0;

CURSOR kursor IS
SELECT pseudo, PRZYDZIAL_MYSZY, FUNKCJA FROM KOCURY ORDER BY PRZYDZIAL_MYSZY FOR UPDATE OF PRZYDZIAL_MYSZY;

wiersz kursor%ROWTYPE;
BEGIN
SELECT SUM(PRZYDZIAL_MYSZY) INTO suma_przydzialow FROM KOCURY;

<<loop1>> LOOP
    OPEN kursor;
    LOOP
FETCH kursor INTO wiersz;
      EXIT WHEN kursor%NOTFOUND;

SELECT MAX_MYSZY INTO max_przydzial FROM FUNKCJE WHERE FUNKCJA = wiersz.FUNKCJA;

IF (1.1 * wiersz.PRZYDZIAL_MYSZY <= max_przydzial) THEN
UPDATE KOCURY
SET PRZYDZIAL_MYSZY = ROUND(1.1 * wiersz.PRZYDZIAL_MYSZY)
WHERE wiersz.PSEUDO = PSEUDO;

liczba_zmian := liczba_zmian + 1;
        suma_przydzialow := suma_przydzialow + ROUND(0.1 * wiersz.PRZYDZIAL_MYSZY);
      ELSIF (wiersz.PRZYDZIAL_MYSZY != max_przydzial) THEN
UPDATE KOCURY
SET PRZYDZIAL_MYSZY = max_przydzial
WHERE wiersz.PSEUDO = PSEUDO;

liczba_zmian := liczba_zmian + 1;
        suma_przydzialow := suma_przydzialow + (max_przydzial - wiersz.PRZYDZIAL_MYSZY);
END IF;

      EXIT LOOP1 WHEN suma_przydzialow > 1050;
END LOOP;

CLOSE kursor;
END LOOP loop1;

  DBMS_OUTPUT.PUT_LINE('Calk. przydzial w stadku ' || suma_przydzialow);
  DBMS_OUTPUT.PUT_LINE('Zmian - ' || liczba_zmian);
END;


SELECT
    imie,
    przydzial_myszy "Myszki po podwyzce"
FROM
    kocury
ORDER BY
    2 DESC;

ROLLBACK;


-- Zad. 37
DECLARE
CURSOR topC IS
SELECT pseudo, NVL(przydzial_myszy,0) +  NVL(myszy_extra, 0) "zjada"
FROM KOCURY
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


-- Zad. 38
DECLARE
liczba_przelozonych     NUMBER := $(liczba_szefow);
max_liczba_przelozonych NUMBER;
    szerokosc_kol           NUMBER := 15;
    pseudo_aktualny         KOCURY.PSEUDO%TYPE;
    imie_aktualny           KOCURY.IMIE%TYPE;
    pseudo_nastepny         KOCURY.SZEF%TYPE;
CURSOR podwladni IS SELECT PSEUDO, IMIE
                    FROM KOCURY
                    WHERE FUNKCJA IN ('MILUSIA', 'KOT');
BEGIN
SELECT MAX(LEVEL) - 1
INTO max_liczba_przelozonych
FROM Kocury
    CONNECT BY PRIOR szef = pseudo
START WITH funkcja IN ('KOT', 'MILUSIA');
liczba_przelozonych := LEAST(max_liczba_przelozonych, liczba_przelozonych);

    DBMS_OUTPUT.PUT(RPAD('IMIE ', szerokosc_kol));
FOR licznik IN 1..liczba_przelozonych
        LOOP
            DBMS_OUTPUT.PUT(RPAD('|  SZEF ' || licznik, szerokosc_kol));
END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', szerokosc_kol * (liczba_przelozonych + 1), '-'));

FOR kot IN podwladni
        LOOP
            DBMS_OUTPUT.PUT(RPAD(KOT.IMIE, szerokosc_kol));
SELECT SZEF INTO pseudo_nastepny FROM KOCURY WHERE PSEUDO = kot.PSEUDO;
FOR COUNTER IN 1..liczba_przelozonych
                LOOP
                    IF pseudo_nastepny IS NULL THEN
                        DBMS_OUTPUT.PUT(RPAD('|  ', szerokosc_kol));

ELSE
SELECT K.IMIE, K.PSEUDO, K.SZEF
INTO imie_aktualny, pseudo_aktualny, pseudo_nastepny
FROM KOCURY K
WHERE K.PSEUDO = pseudo_nastepny;
DBMS_OUTPUT.PUT(RPAD('|  ' || imie_aktualny, szerokosc_kol));
END IF;
END LOOP;
            DBMS_OUTPUT.PUT_LINE('');
END LOOP;
END;

-- Zad. 39
DECLARE
nrB number := $(numer);
nazwaB varchar2(20) := UPPER($(nazwa));
terenB varchar2(15) := UPPER($(teren));
blad varchar2(256) := '';
    ilosc number :=0;
    zlaliczba exception;
    istnieje exception;
BEGIN

    IF nrB <=0 then raise zlaliczba;
end if;

Select count(nr_bandy) into ilosc from Bandy where nr_bandy = nrB;
IF ilosc > 0 then blad := TO_char(nrB); end if;

Select count(nazwa) into ilosc from Bandy where nazwaB=nazwa;
IF ilosc > 0 then
        if length(blad)>0 then blad:= blad || ', ' || nazwaB;
else blad := nazwaB ;
end if;
end if;
Select count(teren) into ilosc from Bandy where terenB=teren ;
IF ilosc > 0 then
        IF length(blad) >0 then blad := blad || ', ' || terenB;
else blad := terenB;
end if;
end if;

    If length(blad)>0 then raise istnieje; end if;

INSERT INTO Bandy (nr_bandy, nazwa, teren) values (nrB, nazwaB, terenB) ;

EXCEPTION
        WHEN zlaliczba then DBMS_OUTPUT.PUT_LINE('Liczba musi byc >0! ');
WHEN istnieje then DBMS_OUTPUT.PUT_LINE(blad || ' :wartosc juz istnieje');
END;
rollback;
Select * from bandy;

--Zad. 40
CREATE OR REPLACE PROCEDURE nowa_banda(nrB Bandy.nr_bandy%TYPE, nazwaB bandy.nazwa%TYPE, terenB bandy.teren%TYPE)
  IS
    blad STRING(256) := '';
    jest number :=0;
    zlaliczba exception;
    istnieje exception;
BEGIN

    IF nrB <=0 then raise zlaliczba;
end if;

Select count(nr_bandy) into jest from Bandy where nr_bandy = nrB;
IF jest > 0 then blad := TO_char(nrB); end if;

Select count(nazwa) into jest from Bandy where nazwaB=nazwa;
IF jest > 0 then
        if length(blad)>0 then blad:= blad || ', ' || nazwaB;
else blad := nazwaB ;
end if;
end if;
Select count(teren) into jest from Bandy where terenB=teren ;
IF jest > 0 then
        IF length(blad) >0 then blad := blad || ', ' || terenB;
else blad := terenB;
end if;
end if;

    If length(blad)>0 then raise istnieje; end if;

INSERT INTO Bandy (nr_bandy, nazwa, teren) values (nrB, nazwaB, terenB) ;

EXCEPTION
        WHEN zlaliczba then DBMS_OUTPUT.PUT_LINE('Liczba musi byc >0! ');
WHEN istnieje then DBMS_OUTPUT.PUT_LINE(blad || ' :wartosc juz istnieje');
END;

rollback;
begin
    nowa_banda(1, 'SZEFOSTWO', 'SAD');
end;
Select * from bandy;
SELECT * from USER_OBJECTS;
DROP procedure nowa_banda;
-- Zad. 41

CREATE OR REPLACE TRIGGER one_more_number
BEFORE INSERT ON Bandy
FOR EACH ROW
BEGIN
SELECT MAX(nr_bandy) + 1 INTO :NEW.nr_bandy FROM Bandy;
END;

-- TEST
BEGIN
  nowa_banda(9, 'KOT', 'AAA');
END;
SELECT * FROM bandy;
ROLLBACK;
drop trigger one_more_number;

--Lab 42
CREATE OR REPLACE PACKAGE wirus AS
  active BOOLEAN := FALSE;
  down BOOLEAN := FALSE;
  mutex BOOLEAN := FALSE;
  min_przydzial NUMBER;
END;

CREATE OR REPLACE PACKAGE BODY wirus AS
BEGIN
  mutex := FALSE;
END;

CREATE OR REPLACE TRIGGER wirus_set
BEFORE UPDATE ON Kocury
BEGIN
SELECT przydzial_myszy INTO wirus.min_przydzial FROM Kocury WHERE pseudo = 'TYGRYS';
END;

CREATE OR REPLACE TRIGGER wirus_przed
BEFORE UPDATE ON Kocury
                  FOR EACH ROW
BEGIN
    IF :NEW.funkcja = 'MILUSIA' AND NOT wirus.mutex THEN
      wirus.active := TRUE;

      IF :NEW.przydzial_myszy < :OLD.przydzial_myszy THEN
        :NEW.przydzial_myszy := :OLD.przydzial_myszy;
END IF;
      IF :NEW.przydzial_myszy - :OLD.przydzial_myszy <  0.1 * wirus.min_przydzial THEN
        :NEW.przydzial_myszy := :NEW.przydzial_myszy + 0.1 * wirus.min_przydzial ;
        :NEW.myszy_extra := :NEW.myszy_extra + 5;
        wirus.down := TRUE;
END IF;
END IF;
END;

CREATE OR REPLACE TRIGGER wirus_po
AFTER UPDATE ON Kocury
BEGIN
      IF wirus.active THEN
        wirus.mutex := TRUE;
        wirus.active := FALSE;
        IF wirus.down THEN
          wirus.down := FALSE;
UPDATE kocury SET przydzial_myszy = przydzial_myszy - 0.1 * wirus.min_przydzial WHERE pseudo = 'TYGRYS';
ELSE
UPDATE kocury SET myszy_extra = myszy_extra + 5 WHERE pseudo = 'TYGRYS';
END IF;
        wirus.mutex := FALSE;
END IF;
END;

ALTER TRIGGER wirus_set ENABLE;
ALTER TRIGGER wirus_przed ENABLE;
ALTER TRIGGER wirus_po ENABLE;

ALTER TRIGGER wirus_set DISABLE;
ALTER TRIGGER wirus_przed DISABLE;
ALTER TRIGGER wirus_po DISABLE;

SELECT * FROM kocury WHERE funkcja = 'MILUSIA';
UPDATE kocury
SET przydzial_myszy = 20
WHERE funkcja = 'MILUSIA';
ROLLBACK;

--Lab 42b

CREATE OR REPLACE TRIGGER wirus_compound
FOR UPDATE ON Kocury
               COMPOUND TRIGGER
               active BOOLEAN:=FALSE;
down BOOLEAN:=FALSE;
  min_przydzial NUMBER;

  BEFORE STATEMENT IS
BEGIN
SELECT 0.1 * przydzial_myszy INTO min_przydzial FROM Kocury WHERE pseudo = 'TYGRYS';
END BEFORE STATEMENT;

  BEFORE EACH ROW IS
BEGIN
    IF :NEW.funkcja = 'MILUSIA' THEN
      active := TRUE;

      IF (:NEW.przydzial_myszy < :OLD.przydzial_myszy) THEN
        :NEW.przydzial_myszy := :OLD.przydzial_myszy;
END IF;
      IF :NEW.przydzial_myszy - :OLD.przydzial_myszy <  min_przydzial THEN
        :NEW.przydzial_myszy := :NEW.przydzial_myszy + 0.1 * wirus.min_przydzial ;
        :NEW.myszy_extra := :NEW.myszy_extra + 5;
        down := TRUE;
END IF;
END IF;
END BEFORE EACH ROW;

  AFTER STATEMENT IS
BEGIN
    IF active THEN
      IF down THEN
UPDATE kocury SET przydzial_myszy = przydzial_myszy - min_przydzial WHERE pseudo = 'TYGRYS';
ELSE
UPDATE kocury SET myszy_extra = myszy_extra + 5 WHERE pseudo = 'TYGRYS';
END IF;
END IF;
    active := FALSE;
    down := FALSE;
END AFTER STATEMENT;
END;

ALTER TRIGGER wirus_compound DISABLE;

SELECT * FROM kocury WHERE funkcja = 'MILUSIA';
UPDATE kocury
SET przydzial_myszy = przydzial_myszy + 1
WHERE funkcja = 'MILUSIA';
ROLLBACK;


--Lab 43
DECLARE
CURSOR funkcje IS SELECT funkcja, SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) suma_dla_funkcji
                  FROM KOCURY
                  GROUP BY funkcja
                  ORDER BY funkcja;
CURSOR iloscKotow IS SELECT COUNT(*) ilosc, SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) sumaMyszy
                     FROM Kocury, Bandy WHERE Kocury.nr_bandy = Bandy.nr_bandy
                     GROUP BY Bandy.nazwa, Kocury.plec
                     ORDER BY Bandy.nazwa, plec;
CURSOR funkcjezBand IS SELECT SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) sumaMyszy,
                              Kocury.Funkcja funkcja,
                              Bandy.nazwa naz,
                              Kocury.plec pl
                       FROM Kocury, Bandy WHERE Kocury.nr_bandy = Bandy.nr_bandy
                       GROUP BY Bandy.nazwa, Kocury.plec, Kocury.funkcja
                       ORDER BY Bandy.nazwa, Kocury.plec, Kocury.funkcja;
suma NUMBER;
    il iloscKotow%ROWTYPE;
    poszegolny_kot funkcjezBand%ROWTYPE;
BEGIN
    DBMS_OUTPUT.put('NAZWA BANDY       PLEC    ILE ');
FOR fun IN funkcje
        LOOP
            DBMS_OUTPUT.put(RPAD(fun.funkcja, 10));
END LOOP;
    DBMS_OUTPUT.put_line('    SUMA');
    DBMS_OUTPUT.put('---------------- ------ ----');
FOR fun IN funkcje
        LOOP
            DBMS_OUTPUT.put(' ---------');
END LOOP;

    DBMS_OUTPUT.put_line(' --------');

OPEN funkcjezBand;
OPEN iloscKotow;
FETCH funkcjezBand INTO poszegolny_kot;
FOR banda IN (SELECT nazwa, NR_BANDY FROM BANDY ORDER BY nazwa)
        LOOP
            FOR ple IN (SELECT PLEC FROM KOCURY GROUP BY PLEC ORDER BY PLEC )
                LOOP
                    DBMS_OUTPUT.put(CASE WHEN ple.plec = 'M' THEN RPAD(' ', 18) ELSE RPAD(banda.nazwa, 18) END);
                    DBMS_OUTPUT.put(CASE WHEN ple.plec = 'M' THEN 'Kocor' ELSE 'Kotka' END);

FETCH iloscKotow INTO il;
DBMS_OUTPUT.put(LPAD(il.ilosc, 4));
FOR fun IN funkcje
                        LOOP
                            IF fun.funkcja = poszegolny_kot.funkcja AND banda.nazwa = poszegolny_kot.naz AND ple.plec = poszegolny_kot.pl
                            THEN
                                DBMS_OUTPUT.put(LPAD(NVL(poszegolny_kot.sumaMyszy, 0), 10));
FETCH funkcjezBand INTO poszegolny_kot;
ELSE
                                DBMS_OUTPUT.put(LPAD(NVL(0, 0), 10));
END IF;
END LOOP;
                    DBMS_OUTPUT.put(LPAD(NVL(il.sumaMyszy, 0), 10));
                    DBMS_OUTPUT.new_line();
END LOOP;
END LOOP;
CLOSE iloscKotow;
CLOSE funkcjezBand;


DBMS_OUTPUT.put('Z---------------- ------ ----');
FOR fun IN funkcje
        LOOP
            DBMS_OUTPUT.put(' ---------');
END LOOP;
    DBMS_OUTPUT.put_line(' --------');
    DBMS_OUTPUT.put('Zjada razem                ');
FOR fun IN funkcje
        LOOP
            DBMS_OUTPUT.put(LPAD(NVL(fun.suma_dla_funkcji, 0), 10));
END LOOP;
SELECT SUM(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)) INTO suma FROM Kocury;
DBMS_OUTPUT.put(LPAD(suma, 10));
    DBMS_OUTPUT.new_line();
END;

--Lab 44
CREATE OR REPLACE FUNCTION podatek(pseudonim VARCHAR2, inny NUMBER := 0)
  RETURN NUMBER AS
  podstawowy NUMBER;
  podwladni NUMBER;
  wrogowie NUMBER;
BEGIN
SELECT 0.05 * przydzial_myszy INTO podstawowy FROM Kocury WHERE pseudo = pseudonim;
SELECT COUNT(*) INTO podwladni FROM Kocury WHERE szef = pseudonim;
SELECT COUNT(*) INTO wrogowie FROM Wrogowie_kocurow WHERE pseudo = pseudonim;

IF podwladni > 0 THEN
      podwladni := 0;
ELSE
      podwladni := 2;
END IF;

    IF wrogowie > 0 THEN
      wrogowie := 0;
ELSE
      wrogowie := 1;
END IF;

RETURN podstawowy + podwladni + wrogowie + inny;
END;

SELECT podatek('PUSZYSTA') FROM dual;

-- Lab 44b
CREATE OR REPLACE PACKAGE moj_pakiet AS

  PROCEDURE nowa_banda(nrB Bandy.nr_bandy%TYPE, nazwaB bandy.nazwa%TYPE, terenB bandy.teren%TYPE);
  FUNCTION podatek(pseudonim VARCHAR2, inny NUMBER := 0) RETURN NUMBER;

END moj_pakiet;
/

CREATE OR REPLACE PACKAGE BODY moj_pakiet AS

  PROCEDURE nowa_banda(nrB Bandy.nr_bandy%TYPE, nazwaB bandy.nazwa%TYPE, terenB bandy.teren%TYPE) IS
    blad VARCHAR2(256) := '';
    jest NUMBER := 0;
    zlaliczba EXCEPTION;
    istnieje EXCEPTION;
BEGIN
    IF nrB <= 0 THEN
      RAISE zlaliczba;
END IF;

SELECT COUNT(nr_bandy) INTO jest FROM Bandy WHERE nr_bandy = nrB;
IF jest > 0 THEN
      blad := TO_CHAR(nrB);
END IF;

SELECT COUNT(nazwa) INTO jest FROM Bandy WHERE nazwa = nazwaB;
IF jest > 0 THEN
      IF LENGTH(blad) > 0 THEN
        blad := blad || ', ' || nazwaB;
ELSE
        blad := nazwaB;
END IF;
END IF;

SELECT COUNT(teren) INTO jest FROM Bandy WHERE teren = terenB;
IF jest > 0 THEN
      IF LENGTH(blad) > 0 THEN
        blad := blad || ', ' || terenB;
ELSE
        blad := terenB;
END IF;
END IF;

    IF LENGTH(blad) > 0 THEN
      RAISE istnieje;
END IF;


INSERT INTO Bandy (nr_bandy, nazwa, teren) VALUES (nrB, nazwaB, terenB);

EXCEPTION
    WHEN zlaliczba THEN DBMS_OUTPUT.PUT_LINE('Liczba musi być > 0! ');
WHEN istnieje THEN DBMS_OUTPUT.PUT_LINE(blad || ' :wartość już istnieje');
END nowa_banda;

  FUNCTION podatek(pseudonim VARCHAR2, inny NUMBER := 0) RETURN NUMBER IS
    podstawowy NUMBER;
    podwladni NUMBER;
    wrogowie NUMBER;
BEGIN
SELECT 0.05 * przydzial_myszy INTO podstawowy FROM Kocury WHERE pseudo = pseudonim;
SELECT COUNT(*) INTO podwladni FROM Kocury WHERE szef = pseudonim;
SELECT COUNT(*) INTO wrogowie FROM Wrogowie_kocurow WHERE pseudo = pseudonim;

IF podwladni > 0 THEN
      podwladni := 0;
ELSE
      podwladni := 2;
END IF;

    IF wrogowie > 0 THEN
      wrogowie := 0;
ELSE
      wrogowie := 1;
END IF;

RETURN podstawowy + podwladni + wrogowie + inny;
END podatek;

END moj_pakiet;

DECLARE
v_tax NUMBER;
BEGIN
  moj_pakiet.nowa_banda(1, 'SZEFOSTWO', 'SAD');

FOR cat_rec IN (SELECT pseudo FROM Kocury) LOOP
    v_tax := moj_pakiet.podatek(cat_rec.pseudo);
    DBMS_OUTPUT.PUT_LINE('Tax for ' || cat_rec.pseudo || ': ' || v_tax);
END LOOP;
END;


--Lab 45

CREATE TABLE Dodatki_extra(pseudo VARCHAR2(15), dodatek NUMBER);

CREATE OR REPLACE TRIGGER zemsta_tygrysa
FOR UPDATE ON Kocury
               COMPOUND TRIGGER
               active BOOLEAN:=FALSE;
sqlQuery VARCHAR2(50);
  exist NUMBER;
CURSOR milusieC IS SELECT * FROM Kocury WHERE funkcja = 'MILUSIE';
milusie milusieC%ROWTYPE;

  BEFORE EACH ROW IS
BEGIN
    IF :NEW.funkcja = 'MILUSIA' AND NOT SYS.LOGIN_USER = 'TYGRYS' THEN
      active := TRUE;
END IF;
END BEFORE EACH ROW;

  AFTER STATEMENT IS
BEGIN
    IF active THEN
      OPEN milusieC;

      LOOP
FETCH milusieC INTO milusie;
        EXIT WHEN milusieC%NOTFOUND;

SELECT COUNT(*) INTO exist FROM dodatki_extra WHERE pseudo = milusie.pseudo;
IF exist > 0 THEN
          sqlquery := 'UPDATE Dodatki_extra SET dodatek = dodatek - 10 WHERE funkcja = ''MILUSIA'';';
ELSE
          sqlquery := 'INSERT INTO Dodatki_extra VALUES (' || TO_CHAR(milusie.pseudo) ||', -10);';
END IF;

EXECUTE IMMEDIATE sqlquery;
END LOOP;

      active := FALSE;
END IF;
END AFTER STATEMENT;
END;

--Lab 46
CREATE TABLE Log(kto VARCHAR2(20), kiedy DATE, kotu VARCHAR2(10), operacja VARCHAR2(2000));
DROP TABLE Log;

CREATE OR REPLACE TRIGGER constrain
BEFORE INSERT OR UPDATE ON Kocury
                            FOR EACH ROW
DECLARE
min_num NUMBER;
    max_num NUMBER;
    operation VARCHAR2(30);
BEGIN
SELECT min_myszy INTO min_num FROM Funkcje WHERE funkcja = :NEW.funkcja;
SELECT max_myszy INTO max_num FROM Funkcje WHERE funkcja = :NEW.funkcja;

operation := 'INSERTING';
    IF UPDATING THEN
      operation := 'UPDATING';
END IF;

    IF :NEW.przydzial_myszy < min_num OR :NEW.przydzial_myszy > max_num THEN
      INSERT INTO Log VALUES (SYS.LOGIN_USER, CURRENT_DATE, :NEW.pseudo, operation);
      :NEW.przydzial_myszy := :OLD.przydzial_myszy;
END IF;
END;


UPDATE kocury
SET przydzial_myszy = 31
WHERE pseudo = 'PUSZYSTA';
SELECT * FROM Log;
SELECT * FROM kocury WHERE pseudo = 'PUSZYSTA';
DELETE FROM LOG;



























--zad37
DECLARE
CURSOR topC IS
SELECT pseudo, NVL(przydzial_myszy,0) +  NVL(myszy_extra, 0) "zjada"
FROM KOCURY
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


--zad38
DECLARE
liczba_przelozonych     NUMBER := :liczba_przelozonych;
    max_liczba_przelozonych NUMBER;
    szerokosc_kol           NUMBER := 15;
    pseudo_aktualny         KOCURY.PSEUDO%TYPE;
    imie_aktualny           KOCURY.IMIE%TYPE;
    pseudo_nastepny         KOCURY.SZEF%TYPE;
CURSOR podwladni IS SELECT PSEUDO, IMIE
                    FROM KOCURY
                    WHERE FUNKCJA IN ('MILUSIA', 'KOT');
BEGIN
SELECT MAX(LEVEL) - 1
INTO max_liczba_przelozonych
FROM Kocury
    CONNECT BY PRIOR szef = pseudo
START WITH funkcja IN ('KOT', 'MILUSIA');
liczba_przelozonych := LEAST(max_liczba_przelozonych, liczba_przelozonych);

    DBMS_OUTPUT.PUT(RPAD('IMIE ', szerokosc_kol));
FOR licznik IN 1..liczba_przelozonych
        LOOP
            DBMS_OUTPUT.PUT(RPAD('|  SZEF ' || licznik, szerokosc_kol));
END LOOP;
    DBMS_OUTPUT.PUT_LINE('');
    DBMS_OUTPUT.PUT_LINE(RPAD('-', szerokosc_kol * (liczba_przelozonych + 1), '-'));

FOR kot IN podwladni
        LOOP
            DBMS_OUTPUT.PUT(RPAD(KOT.IMIE, szerokosc_kol));
SELECT SZEF INTO pseudo_nastepny FROM KOCURY WHERE PSEUDO = kot.PSEUDO;
FOR COUNTER IN 1..liczba_przelozonych
                LOOP
                    IF pseudo_nastepny IS NULL THEN
                        DBMS_OUTPUT.PUT(RPAD('|  ', szerokosc_kol));

ELSE
SELECT K.IMIE, K.PSEUDO, K.SZEF
INTO imie_aktualny, pseudo_aktualny, pseudo_nastepny
FROM KOCURY K
WHERE K.PSEUDO = pseudo_nastepny;
DBMS_OUTPUT.PUT(RPAD('|  ' || imie_aktualny, szerokosc_kol));
END IF;
END LOOP;
            DBMS_OUTPUT.PUT_LINE('');
END LOOP;
END;

--zad39
DECLARE
nr_ban NUMBER:= &nr;
    naz_ban BANDY.NAZWA%TYPE := '&nazwa';
    ter BANDY.TEREN%TYPE := '&ter';
    liczba_znalezionych NUMBER;
    juz_istnieje_exc EXCEPTION;
    zly_numer_bandy_exc EXCEPTION;
    wiadomosc_exc    VARCHAR2(30)         := '';
BEGIN
    IF nr_ban < 0 THEN RAISE zly_numer_bandy_exc;
END IF;

SELECT COUNT(*) INTO liczba_znalezionych
FROM Bandy
WHERE nr_bandy = nr_ban;
IF liczba_znalezionych <> 0 
        THEN wiadomosc_exc := wiadomosc_exc || ' ' || nr_ban || ',';
END IF;

SELECT COUNT(*) INTO liczba_znalezionych
FROM Bandy
WHERE nazwa = naz_ban;
IF liczba_znalezionych <> 0 
        THEN wiadomosc_exc := wiadomosc_exc || ' ' || naz_ban || ',';
END IF;

SELECT COUNT(*) INTO liczba_znalezionych
FROM Bandy
WHERE teren = ter;
IF liczba_znalezionych <> 0 
        THEN wiadomosc_exc := wiadomosc_exc || ' ' || ter || ',';
END IF;
    
    IF LENGTH(wiadomosc_exc) > 0 THEN
        RAISE juz_istnieje_exc;
END IF;

INSERT INTO BANDY(NR_BANDY, NAZWA, TEREN) VALUES (nr_ban, naz_ban, ter);

EXCEPTION
    WHEN zly_numer_bandy_exc THEN
        DBMS_OUTPUT.PUT_LINE('Nr bandy musi byc liczba dodatnia');
WHEN juz_istnieje_exc THEN
        DBMS_OUTPUT.PUT_LINE(TRIM(TRAILING ',' FROM wiadomosc_exc) || ': juz istnieje');
END;

--zad40 i zad 44
CREATE OR REPLACE PACKAGE PACK IS
    FUNCTION ObliczPodatek(pseudonim KOCURY.PSEUDO%TYPE) RETURN NUMBER;
    PROCEDURE  AddBanda(nr_ban BANDY.NR_BANDY%TYPE,
                                    naz_ban BANDY.NAZWA%TYPE,
                                    ter BANDY.TEREN%TYPE);
END PACK;

CREATE OR REPLACE PACKAGE BODY PACK IS
    FUNCTION ObliczPodatek(pseudonim KOCURY.PSEUDO%TYPE) RETURN NUMBER
        IS
        wysokosc_podatku NUMBER := 0;
        ile NUMBER := 0;
BEGIN
SELECT CEIL(0.05 * (NVL(przydzial_myszy,0) + NVL(myszy_extra,0)))
INTO wysokosc_podatku
FROM KOCURY
WHERE pseudo = pseudonim;

SELECT COUNT(pseudo)
INTO ile
FROM KOCURY
WHERE szef = pseudonim;

IF ile = 0 THEN
                wysokosc_podatku := wysokosc_podatku + 2;
END IF;

SELECT COUNT(pseudo) INTO ile FROM WROGOWIE_KOCUROW WHERE pseudo = pseudonim;
if ile = 0 THEN
                wysokosc_podatku := wysokosc_podatku + 1;
END IF;
SELECT NVL(przydzial_myszy,0) INTO ile FROM KOCURY WHERE pseudo = pseudonim;
IF ile > 20 THEN
                wysokosc_podatku := wysokosc_podatku + 5;
END IF;
RETURN wysokosc_podatku;
END;

    PROCEDURE AddBanda(nr_ban BANDY.NR_BANDY%TYPE,
                                    naz_ban BANDY.NAZWA%TYPE,
                                    ter BANDY.TEREN%TYPE)
IS
            liczba_znalezionych NUMBER;
            juz_istnieje_exc EXCEPTION;
            zly_numer_bandy_exc EXCEPTION;
            wiadomosc_exc    VARCHAR2(30) := '';
BEGIN
            IF nr_ban < 0 THEN 
                RAISE zly_numer_bandy_exc;
END IF;

SELECT COUNT(*)
INTO liczba_znalezionych
FROM Bandy
WHERE nr_bandy = nr_ban;

IF liczba_znalezionych <> 0 
                THEN wiadomosc_exc := wiadomosc_exc || ' ' || nr_ban || ',';
END IF;

SELECT COUNT(*) INTO liczba_znalezionych
FROM Bandy
WHERE nazwa = naz_ban;
IF liczba_znalezionych <> 0 
                THEN wiadomosc_exc := wiadomosc_exc || ' ' || naz_ban || ',';
END IF;

SELECT COUNT(*) INTO liczba_znalezionych
FROM Bandy
WHERE teren = ter;
IF liczba_znalezionych <> 0 
                THEN wiadomosc_exc := wiadomosc_exc || ' ' || ter || ',';
END IF;
            
            IF LENGTH(wiadomosc_exc) > 0 THEN
                RAISE juz_istnieje_exc;
END IF;

INSERT INTO BANDY(NR_BANDY, NAZWA, TEREN) VALUES (nr_ban, naz_ban, ter);
EXCEPTION
            WHEN zly_numer_bandy_exc THEN
                DBMS_OUTPUT.PUT_LINE('Nr bandy musi byc liczba dodatnia');
WHEN juz_istnieje_exc THEN
                DBMS_OUTPUT.PUT_LINE(TRIM(TRAILING ',' FROM wiadomosc_exc) || ': juz istnieje');
END;
END PACK;

EXECUTE PACK.AddBanda(1, 'PUSZYSCI', 'POLE');
EXECUTE PACK.AddBanda(2, 'CZARNI RYCERZE', 'POLE');
EXECUTE PACK.AddBanda(1, 'SZEFOSTWO', 'NOWE');
EXECUTE PACK.AddBanda(10, 'NOWI', 'NOWE');
SELECT * FROM bandy;

ROLLBACK;
BEGIN
FOR kot IN (SELECT pseudo FROM Kocury)
        LOOP
            DBMS_OUTPUT.PUT_LINE(RPAD(kot.pseudo, 8) || ' podatek równy ' || PACK.ObliczPodatek(kot.pseudo));
END LOOP;
END;

--zad41
CREATE OR REPLACE TRIGGER BiggerThenLastNumber
    BEFORE INSERT 
    ON BANDY
    FOR EACH ROW
DECLARE
ostatni_nr BANDY.NR_BANDY%TYPE;
BEGIN
SELECT MAX(NR_BANDY)
INTO ostatni_nr
FROM BANDY;
IF ostatni_nr + 1 <> :NEW.NR_BANDY THEN
        :NEW.NR_BANDY := ostatni_nr + 1;
END IF;
END;




EXECUTE AddBanda(10, 'NOWI', 'NOWE');

SELECT * FROM bandy;

ROLLBACK;

--zad42
--kilka wyzwalaczy + pakiet
CREATE OR REPLACE PACKAGE wirus IS
    kara NUMBER := 0;
    nagroda NUMBER := 0;
    przydzial_tygrysa KOCURY.PRZYDZIAL_MYSZY%TYPE;
END;

CREATE OR REPLACE TRIGGER trg_wirus_bef_update
    BEFORE UPDATE OF PRZYDZIAL_MYSZY
           ON KOCURY
DECLARE
BEGIN
SELECT PRZYDZIAL_MYSZY INTO wirus.przydzial_tygrysa FROM KOCURY WHERE pseudo = 'TYGRYS';
END;

CREATE OR REPLACE TRIGGER trg_wirus_bef_update_row
    BEFORE UPDATE OF PRZYDZIAL_MYSZY
           ON KOCURY
               FOR EACH ROW
DECLARE
BEGIN
    IF :NEW.funkcja = 'MILUSIA' THEN
        IF :NEW.przydzial_myszy <= :OLD.przydzial_myszy THEN
            DBMS_OUTPUT.PUT_LINE('brak zmiany');
            :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
        ELSIF :NEW.przydzial_myszy - :OLD.przydzial_myszy < 0.1 * wirus.przydzial_tygrysa THEN
            DBMS_OUTPUT.PUT_LINE('podwyzka mniejsza niz 10% Tygrysa');
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
          ON KOCURY
DECLARE
przydzial KOCURY.PRZYDZIAL_MYSZY%TYPE;
    ekstra    KOCURY.MYSZY_EXTRA%TYPE;
BEGIN
SELECT PRZYDZIAL_MYSZY, MYSZY_EXTRA
INTO przydzial, ekstra
FROM KOCURY
WHERE pseudo = 'TYGRYS';

przydzial := przydzial - wirus.kara;
    ekstra := ekstra + wirus.nagroda;
    
    IF wirus.kara <> 0 OR wirus.nagroda <> 0 THEN
        wirus.kara := 0;
        wirus.nagroda := 0;
UPDATE KOCURY
SET PRZYDZIAL_MYSZY = przydzial,
    MYSZY_EXTRA     = ekstra
WHERE pseudo = 'TYGRYS';
END IF;
END;

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 50
WHERE PSEUDO = 'PUSZYSTA';

UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 1
WHERE funkcja = 'MILUSIA';

UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 20
WHERE funkcja = 'MILUSIA';

SELECT *
FROM KOCURY
WHERE PSEUDO IN ('PUSZYSTA', 'TYGRYS');

ROLLBACK;

DROP TRIGGER TRG_WIRUS_AFT_UPDATE;
DROP TRIGGER TRG_WIRUS_BEF_UPDATE;
DROP TRIGGER TRG_WIRUS_BEF_UPDATE_ROW;
DROP PACKAGE WIRUS;


--rozwiazanie compound
CREATE OR REPLACE TRIGGER trg_wirus_comp
    FOR UPDATE OF PRZYDZIAL_MYSZY
        ON KOCURY
            COMPOUND TRIGGER
            przydzial_tygrysa KOCURY.PRZYDZIAL_MYSZY%TYPE;
ekstra KOCURY.MYSZY_EXTRA%TYPE;
    kara NUMBER:=0;
    nagroda NUMBER:=0;
    
BEFORE STATEMENT IS
BEGIN
SELECT przydzial_myszy INTO przydzial_tygrysa
FROM KOCURY
WHERE pseudo = 'TYGRYS';
END BEFORE STATEMENT;

BEFORE EACH ROW IS
BEGIN
    IF :NEW.funkcja = 'MILUSIA' THEN
        IF :NEW.przydzial_myszy <= :OLD.przydzial_myszy THEN
            DBMS_OUTPUT.PUT_LINE('brak zmiany');
            :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
        ELSIF :NEW.przydzial_myszy - :OLD.przydzial_myszy < 0.1 * przydzial_tygrysa THEN
            DBMS_OUTPUT.PUT_LINE('podwyzka mniejsza niz 10% Tygrysa');
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
FROM KOCURY
WHERE pseudo = 'TYGRYS';
przydzial_tygrysa := przydzial_tygrysa - kara;
    ekstra := ekstra + nagroda;
    IF kara <> 0 OR nagroda <> 0 THEN
        DBMS_OUTPUT.PUT_LINE('Nowy przydzial Tygrysa: ' || przydzial_tygrysa);
        DBMS_OUTPUT.PUT_LINE('Nowe myszy ekstra Tygrysa: ' || ekstra);
        kara := 0;
        nagroda := 0;
UPDATE KOCURY
SET przydzial_myszy = przydzial_tygrysa,
    myszy_extra = ekstra
WHERE pseudo = 'TYGRYS';
END IF;
END AFTER STATEMENT;
END;

UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 25
WHERE PSEUDO = 'PUSZYSTA';

UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 1
WHERE funkcja = 'MILUSIA';

UPDATE Kocury
SET przydzial_myszy = przydzial_myszy + 20
WHERE funkcja = 'MILUSIA';

SELECT *
FROM KOCURY
WHERE PSEUDO IN ('PUSZYSTA', 'TYGRYS');

ROLLBACK;
DROP TRIGGER trg_wirus_comp;

--zad43
SELECT DISTINCT FUNKCJA
FROM KOCURY;

SELECT funkcja
FROM FUNKCJE;

SELECT funkcja, SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))
FROM KOCURY
GROUP BY funkcja
ORDER BY funkcja;


--zad43 
DECLARE
CURSOR funkcje IS SELECT funkcja, SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) suma_dla_funkcji
                  FROM KOCURY
                  GROUP BY funkcja
                  ORDER BY funkcja;
CURSOR iloscKotow IS SELECT COUNT(*) ilosc, SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) sumaMyszy
                     FROM Kocury, Bandy WHERE Kocury.nr_bandy = Bandy.nr_bandy
                     GROUP BY Bandy.nazwa, Kocury.plec
                     ORDER BY Bandy.nazwa, plec;
CURSOR funkcjezBand IS SELECT SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)) sumaMyszy,
                              Kocury.Funkcja funkcja,
                              Bandy.nazwa naz,
                              Kocury.plec pl
                       FROM Kocury, Bandy WHERE Kocury.nr_bandy = Bandy.nr_bandy
                       GROUP BY Bandy.nazwa, Kocury.plec, Kocury.funkcja
                       ORDER BY Bandy.nazwa, Kocury.plec, Kocury.funkcja;
ilosc NUMBER;
    suma NUMBER;
    il iloscKotow%ROWTYPE;
    poszegolny_kot funkcjezBand%ROWTYPE;
BEGIN
    DBMS_OUTPUT.put('NAZWA BANDY       PLEC    ILE ');
FOR fun IN funkcje
        LOOP
            DBMS_OUTPUT.put(RPAD(fun.funkcja, 10));
END LOOP;
    DBMS_OUTPUT.put_line('    SUMA');
    DBMS_OUTPUT.put('---------------- ------ ----');
FOR fun IN funkcje
        LOOP
            DBMS_OUTPUT.put(' ---------');
END LOOP;
    
    DBMS_OUTPUT.put_line(' --------');

OPEN funkcjezBand;
OPEN iloscKotow;
FETCH funkcjezBand INTO poszegolny_kot;
FOR banda IN (SELECT nazwa, NR_BANDY FROM BANDY WHERE nazwa <> 'ROCKERSI' ORDER BY nazwa) -- zastanow sie
        LOOP
            FOR ple IN (SELECT PLEC FROM KOCURY GROUP BY PLEC ORDER BY PLEC ) -- stinky cheese
                LOOP 
                    DBMS_OUTPUT.put(CASE WHEN ple.plec = 'M' THEN RPAD(' ', 18) ELSE RPAD(banda.nazwa, 18) END);
                    DBMS_OUTPUT.put(CASE WHEN ple.plec = 'M' THEN 'Kocor' ELSE 'Kotka' END);

FETCH iloscKotow INTO il;
DBMS_OUTPUT.put(LPAD(il.ilosc, 4));
FOR fun IN funkcje
                        LOOP
                            IF fun.funkcja = poszegolny_kot.funkcja AND banda.nazwa = poszegolny_kot.naz AND ple.plec = poszegolny_kot.pl
                            THEN 
                                DBMS_OUTPUT.put(LPAD(NVL(poszegolny_kot.sumaMyszy, 0), 10));
FETCH funkcjezBand INTO poszegolny_kot;
ELSE
                                DBMS_OUTPUT.put(LPAD(NVL(0, 0), 10));
END IF;
END LOOP;
                    DBMS_OUTPUT.put(LPAD(NVL(il.sumaMyszy, 0), 10));
                    DBMS_OUTPUT.new_line();
END LOOP;
END LOOP;
CLOSE iloscKotow;
CLOSE funkcjezBand;
DBMS_OUTPUT.put('Z---------------- ------ ----');
FOR fun IN funkcje
        LOOP
            DBMS_OUTPUT.put(' ---------');
END LOOP;
    DBMS_OUTPUT.put_line(' --------');
    DBMS_OUTPUT.put('Zjada razem                ');
FOR fun IN funkcje
        LOOP            
            DBMS_OUTPUT.put(LPAD(NVL(fun.suma_dla_funkcji, 0), 10));
END LOOP;
SELECT SUM(nvl(PRZYDZIAL_MYSZY, 0) + nvl(MYSZY_EXTRA, 0)) INTO suma FROM Kocury;
DBMS_OUTPUT.put(LPAD(suma, 10));
    DBMS_OUTPUT.new_line();
END;


--zad45
CREATE TABLE Dodatki_extra(
                              pseudo VARCHAR2(15) CONSTRAINT dodatki_pseudo_fk REFERENCES Kocury(pseudo),
                              dod_extra NUMBER(3) DEFAULT 0
);

SELECT * FROM Dodatki_extra;

DROP TABLE Dodatki_extra;

SELECT PSEUDO, (SELECT COUNT(*) FROM DODATKI_EXTRA WHERE KOCURY.PSEUDO = milusia.PSEUDO) ile
FROM KOCURY
WHERE funkcja = 'MILUSIA';

SELECT *
FROM Kocury
WHERE funkcja = 'MILUSIA';

SELECT * FROM DODATKI_EXTRA;


--45 Pragma autonomous_transaction: 
/*Transakcja taka jest niezależną transakcją, osadzoną w 
transakcji głównej, wykonywaną w trakcie zawieszonej transakcji 
głównej. Po jej zakończeniu transakcja główna jest kontynuowana. 
Transakcja autonomiczna musi być zawsze zakończona lub wycofana.
Dzieki temu mimo wycofania zmian na przydzialach myszy w kocurach
nie wycofamy kary w dodatkach extra;
EXECUTE IMMEDIATE - wewn. dyn. SQL DDL które jest zabrobione w wyzwalaczach.
Dzięki pragma autonomous_transaction można wykonać zabroniony w blokach DCL - COMMIT
*/


CREATE OR REPLACE TRIGGER trg_tygrys_kara
    BEFORE UPDATE OF PRZYDZIAL_MYSZY
           ON KOCURY
               FOR EACH ROW
DECLARE
CURSOR milusie IS SELECT PSEUDO
                  FROM KOCURY
                  WHERE funkcja = 'MILUSIA';
ILE NUMBER;
    POLECENIE VARCHAR2(1000);
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
    IF LOGIN_USER <> 'TYGRYS' AND :NEW.PRZYDZIAL_MYSZY > :OLD.PRZYDZIAL_MYSZY AND :NEW.FUNKCJA = 'MILUSIA' THEN
    FOR milusia IN milusie
        LOOP
SELECT COUNT(*) INTO ILE FROM DODATKI_EXTRA WHERE pseudo = milusia.pseudo;
IF ILE > 0 THEN
                POLECENIE:='UPDATE DODATKI_EXTRA SET dod_extra = dod_extra - 10 WHERE :mil_ps = pseudo';
ELSE 
                POLECENIE:='INSERT INTO DODATKI_EXTRA (PSEUDO, DOD_EXTRA) VALUES (:mil_ps, -10)';
END IF;
EXECUTE IMMEDIATE POLECENIE USING milusia.pseudo;
END LOOP;
COMMIT;
END IF;
END;


UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 80
WHERE IMIE = 'RUDA';

UPDATE KOCURY
SET przydzial_myszy = 150
WHERE imie = 'RUDA';

SELECT *
FROM KOCURY
WHERE FUNKCJA = 'MILUSIA';

SELECT * FROM Dodatki_extra;

ROLLBACK;

DROP TRIGGER trg_tygrys_kara;


--zad 46
--tabela
CREATE TABLE Proby_wykroczenia
(
    kto VARCHAR2(15) NOT NULL,
    kiedy DATE NOT NULL,
    jakiemu VARCHAR2(15) NOT NULL,
    operacja VARCHAR2(15) NOT NULL
);

DROP TABLE Proby_wykroczenia;

--wyzwalacz.
CREATE OR REPLACE TRIGGER trg_monitor_wykroczenia_other
    BEFORE INSERT OR UPDATE OF PRZYDZIAL_MYSZY
                     ON KOCURY
                         FOR EACH ROW
DECLARE
min_mysz FUNKCJE.MIN_MYSZY%TYPE;
    max_mysz FUNKCJE.MAX_MYSZY%TYPE;
    poza EXCEPTION;
    curr_data DATE DEFAULT SYSDATE;
    zdarzenie VARCHAR2(20);
    PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
SELECT MIN_MYSZY, MAX_MYSZY INTO min_mysz, max_mysz FROM FUNKCJE WHERE FUNKCJA = :NEW.FUNKCJA;
IF max_mysz < :NEW.PRZYDZIAL_MYSZY OR min_mysz > :NEW.PRZYDZIAL_MYSZY THEN
        IF INSERTING THEN 
            zdarzenie := 'INSERT';
        ELSIF UPDATING THEN
            zdarzenie := 'UPDATE';
END IF;
INSERT INTO Proby_wykroczenia(kto, kiedy, jakiemu, operacja) VALUES (ORA_LOGIN_USER, curr_data, :NEW.PSEUDO, zdarzenie);
COMMIT;
RAISE poza;
END IF;
EXCEPTION
    WHEN poza THEN
        DBMS_OUTPUT.PUT_LINE('poza zakresem');
        :NEW.PRZYDZIAL_MYSZY := :OLD.PRZYDZIAL_MYSZY;
END;

DROP TRIGGER trg_monitor_wykroczenia_other;

CREATE OR REPLACE TRIGGER trg_monitor_wykroczenia
    BEFORE INSERT OR UPDATE OF PRZYDZIAL_MYSZY
                     ON KOCURY
                         FOR EACH ROW
DECLARE
min_mysz FUNKCJE.MIN_MYSZY%TYPE;
    max_mysz FUNKCJE.MAX_MYSZY%TYPE;
    curr_data DATE DEFAULT SYSDATE;
    zdarzenie VARCHAR2(20);
    --PRAGMA AUTONOMOUS_TRANSACTION;
BEGIN
SELECT MIN_MYSZY, MAX_MYSZY INTO min_mysz, max_mysz FROM FUNKCJE WHERE FUNKCJA = :NEW.FUNKCJA;
IF max_mysz < :NEW.PRZYDZIAL_MYSZY OR min_mysz > :NEW.PRZYDZIAL_MYSZY THEN
        IF INSERTING THEN 
            zdarzenie := 'INSERT';
        ELSIF UPDATING THEN
            zdarzenie := 'UPDATE';
END IF;
INSERT INTO Proby_wykroczenia(kto, kiedy, jakiemu, operacja) VALUES (ORA_LOGIN_USER, curr_data, :NEW.PSEUDO, zdarzenie);
--COMMIT;
RAISE_APPLICATION_ERROR(-20001,'Przydzial myszy jest poza zakresem przydziału funkcji kota, nie wykonano zmian.');
END IF;
END;

DROP TRIGGER trg_monitor_wykroczenia;


UPDATE KOCURY
SET PRZYDZIAL_MYSZY = 80
WHERE IMIE = 'JACEK';

INSERT INTO Kocury VALUES ('GRUBY','M','BEN','LAPACZ','RAFA','2008-11-01',70,NULL,4);

SELECT * FROM Kocury;
SELECT * FROM Proby_wykroczenia;

ROLLBACK;
TRUNCATE TABLE Proby_wykroczenia;

DROP TABLE Proby_wykroczenia;
