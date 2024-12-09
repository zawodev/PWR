--49
/* Zad 49 */
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE MYSZY(
        nr_myszy NUMBER(15)     CONSTRAINT m_pk PRIMARY KEY,
        lowca VARCHAR2(15)      CONSTRAINT m_lowca_fk REFERENCES Kocury(pseudo),
        zjadacz VARCHAR2(15)    CONSTRAINT m_zjadacz_fk REFERENCES Kocury(pseudo),
        waga_myszy NUMBER(3)    CONSTRAINT waga_myszy_ogr CHECK (waga_myszy BETWEEN 15 AND 40),
        data_zlowienia DATE     CONSTRAINT dat_nn NOT NULL,
        data_wydania DATE,
        CONSTRAINT daty_popr CHECK (data_zlowienia <= data_wydania)
    )';
END;
/
DROP TABLE Myszy;
/
CREATE SEQUENCE myszy_seq;
/
DROP SEQUENCE myszy_seq;
/

DECLARE
    aktualna_data DATE := TO_DATE('2004-01-01','YYYY-MM-DD');
    koncowa_data DATE := TO_DATE('2024-01-21','YYYY-MM-DD');
    ostatnia_sroda DATE := NEXT_DAY(LAST_DAY(aktualna_data) - 7, 'WEDNESDAY');
    losowy_dodatek_do_daty BINARY_INTEGER;
    zjedzonych_myszy NUMBER(10);

    nr_myszy BINARY_INTEGER := 0;
    indeks_zjadacza NUMBER;
    losowa_liczba BINARY_INTEGER;
    liczba BINARY_INTEGER;

    srednio_myszy NUMBER(5);

    TYPE tp IS TABLE OF Kocury.pseudo%TYPE;
    TYPE tk IS TABLE OF NUMBER(5);
    TYPE tz IS TABLE OF NUMBER(5);
    TYPE tm IS TABLE OF Myszy%ROWTYPE INDEX BY BINARY_INTEGER;

    tab_pseudo tp := tp();
    tab_zlapanych tz := tz();
    tab_konsumpcji tk := tk();
    tab_myszy tm;
BEGIN
    LOOP
        EXIT WHEN aktualna_data >= koncowa_data;

        indeks_zjadacza := 1;

        IF aktualna_data < NEXT_DAY(LAST_DAY(aktualna_data), 'WEDNESDAY') - 7 THEN
            ostatnia_sroda := LEAST(NEXT_DAY(LAST_DAY(aktualna_data), 'WEDNESDAY') - 7, koncowa_data);
        ELSE
            ostatnia_sroda := LEAST(NEXT_DAY(LAST_DAY(ADD_MONTHS(aktualna_data, 1)), 'WEDNESDAY') - 7, koncowa_data);
        END IF;

        --Koty w bandzie w danym czasie, i ilosc ilosc zjadanych przez nie myszy
        SELECT pseudo, NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)
        BULK COLLECT INTO tab_pseudo, tab_konsumpcji
        FROM Kocury
        WHERE w_stadku_od < ostatnia_sroda;

        --Ilosc myszy zjedzonych w danym miesiacu
        SELECT SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))
        INTO zjedzonych_myszy
        FROM Kocury
        WHERE w_stadku_od < ostatnia_sroda;

        srednio_myszy := CEIL(zjedzonych_myszy / tab_pseudo.COUNT);

        SELECT srednio_myszy
        BULK COLLECT INTO tab_zlapanych
        FROM Kocury
        WHERE w_stadku_od < ostatnia_sroda;

        FOR i IN 1..zjedzonych_myszy
            LOOP
                nr_myszy := nr_myszy + 1;
                tab_myszy(nr_myszy).nr_myszy:= nr_myszy;

                --Dodawana, aby przy rownomiernym rozlozeniu zlapanych myszy lapacze z jedna mniej/wiecej zlapanych myszy nie byli tacy sami w kazdym miesiacu
                losowa_liczba := i + DBMS_RANDOM.VALUE(0, tab_pseudo.COUNT);

                WHILE tab_zlapanych(MOD(losowa_liczba, tab_pseudo.COUNT) + 1) <= 0
                    LOOP
                        losowa_liczba := losowa_liczba + 1;
                    END LOOP;

                liczba := MOD(losowa_liczba, tab_pseudo.COUNT) + 1;

                tab_myszy(nr_myszy).lowca := tab_pseudo(liczba);
                tab_zlapanych(liczba) := tab_zlapanych(liczba) - 1;

                IF ostatnia_sroda < koncowa_data THEN
                    tab_myszy(nr_myszy).data_wydania := TRUNC(ostatnia_sroda);

                    IF tab_konsumpcji(indeks_zjadacza) = 0 THEN
                        indeks_zjadacza := indeks_zjadacza + 1;
                    ELSE
                        tab_konsumpcji(indeks_zjadacza) := tab_konsumpcji(indeks_zjadacza) - 1;
                    end if;

                    --losowe rozlozenie nadwyzek (dodatkowe zabezpieczenie, nadwyzki nie powinny wystapic)
                    IF indeks_zjadacza > tab_pseudo.COUNT THEN
                        indeks_zjadacza := DBMS_RANDOM.VALUE(1, tab_pseudo.COUNT);
                    end if;

                    tab_myszy(nr_myszy).zjadacz := tab_pseudo(indeks_zjadacza);
                end if;

                tab_myszy(nr_myszy).waga_myszy := DBMS_RANDOM.VALUE(15, 40);
                losowy_dodatek_do_daty := DBMS_RANDOM.VALUE(0, 30);
                tab_myszy(nr_myszy).data_zlowienia := aktualna_data + MOD(nr_myszy + losowy_dodatek_do_daty, TRUNC(ostatnia_sroda) - TRUNC(aktualna_data));

            end loop;

            aktualna_data := ostatnia_sroda + 1;
            ostatnia_sroda := NEXT_DAY(LAST_DAY(ADD_MONTHS(aktualna_data, 1)) - 7, 'WEDNESDAY');
    END LOOP;

    FORALL i in 1..tab_myszy.COUNT
        INSERT INTO Myszy(nr_myszy, lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania)
        VALUES (myszy_seq.NEXTVAL, tab_myszy(i).LOWCA, tab_myszy(i).ZJADACZ, tab_myszy(i).WAGA_MYSZY, tab_myszy(i).DATA_ZLOWIENIA,
                tab_myszy(i).DATA_WYDANIA);
END;
/
TRUNCATE TABLE Myszy;
/



SELECT COUNT(*) FROM Myszy;



BEGIN
   FOR kot in (SELECT pseudo FROM Kocury)
    LOOP
       EXECUTE IMMEDIATE 'CREATE TABLE Konto_osobiste_' || kot.pseudo ||
         '( nr_myszy NUMBER(10) CONSTRAINT Kos_pk_'     || kot.pseudo || ' PRIMARY KEY,' ||
           'waga NUMBER(5)      CONSTRAINT Kos_waga_'   || kot.pseudo || ' CHECK (waga BETWEEN 15 AND 40),' ||
           'data_zlowienia DATE CONSTRAINT Kos_data_nn_'|| kot.pseudo || ' NOT NULL)';
       END LOOP;
END;
/


BEGIN
    FOR kot IN (SELECT pseudo FROM Kocury)
    LOOP
        EXECUTE IMMEDIATE 'DROP TABLE Konto_osobiste_' || kot.pseudo;
        END LOOP;
END;
/

CREATE OR REPLACE PROCEDURE przyjmij_na_stan(pseudonim Kocury.pseudo%TYPE, data_zlowienia DATE)
AS
    TYPE tw IS TABLE OF NUMBER(5);
    TYPE tn IS TABLE OF NUMBER(10);

    tab_wagi tw := tw();
    tab_nr tn := tn();
    pseudo_kota Kocury.pseudo%TYPE := UPPER(pseudonim);

    czy_istnieje NUMBER;
    konto VARCHAR(128);

    brak_kota EXCEPTION;
    zla_data EXCEPTION;
    brak_myszy_zlowionych_w_dniu EXCEPTION;
BEGIN

    IF data_zlowienia > SYSDATE
        THEN RAISE zla_data;
    END IF;

    SELECT COUNT(*) INTO czy_istnieje
    FROM KOCURY
    WHERE pseudo = pseudo_kota;

    IF czy_istnieje = 0 THEN
        RAISE brak_kota;
    END IF;

    konto := 'Konto_osobiste_' || pseudo_kota;
    DBMS_OUTPUT.PUT_LINE(konto);

    EXECUTE IMMEDIATE
        'SELECT nr_myszy, waga
            FROM Konto_osobiste_'||pseudo_kota||
            ' WHERE data_zlowienia= '''||data_zlowienia||''''
        BULK COLLECT INTO tab_nr, tab_wagi;

    IF tab_nr.COUNT = 0 THEN
        RAISE brak_myszy_zlowionych_w_dniu;
    end if;

    FORALL i in 1..tab_nr.COUNT
        INSERT INTO Myszy VALUES (tab_nr(i), UPPER(pseudo_kota), NULL, tab_wagi(i),data_zlowienia, NULL);

    EXECUTE IMMEDIATE 'DELETE FROM Konto_osobiste_'||pseudo_kota||' WHERE data_zlowienia = '''||data_zlowienia||'''';

    EXCEPTION
        WHEN brak_kota THEN DBMS_OUTPUT.PUT_LINE('Brak kota o pseudonimie '|| UPPER(pseudo_kota));
        WHEN zla_data THEN DBMS_OUTPUT.PUT_LINE('ZLA DATA');
        WHEN brak_myszy_zlowionych_w_dniu THEN DBMS_OUTPUT.PUT_LINE('Brak myszy zlowionych w dniu ' || data_zlowienia || ' przez ' || pseudo_kota);
END;
/




CREATE OR REPLACE PROCEDURE Wyplata
AS
    TYPE tp IS TABLE OF Kocury.pseudo%TYPE;
    TYPE tk is TABLE OF NUMBER(5);
    TYPE tz IS TABLE OF Kocury.pseudo%TYPE INDEX BY BINARY_INTEGER;
    TYPE tm IS TABLE OF Myszy%ROWTYPE;

    tab_pseudo tp := tp();
    tab_konsumpcji tk := tk();
    tab_zjadaczy tz;
    tab_myszy tm;

    aktualna_data_wydania DATE := TRUNC(NEXT_DAY(LAST_DAY(SYSDATE)-7, 'WEDNESDAY'));

    liczba_najedzonych NUMBER(2) := 0;
    indeks_zjadacza NUMBER(2) := 1;
    juz_wyplacone NUMBER(5);

    ponowna_wyplata EXCEPTION;
    brak_myszy_do_wyplacenia EXCEPTION;
BEGIN

    SELECT pseudo, NVL(przydzial_myszy,0) + NVL(myszy_extra, 0)
    BULK COLLECT INTO tab_pseudo, tab_konsumpcji
    FROM Kocury CONNECT BY PRIOR pseudo = szef
    START WITH SZEF IS NULL
    ORDER BY level;

    SELECT COUNT(nr_myszy) INTO juz_wyplacone
    FROM MYSZY
    WHERE data_wydania = aktualna_data_wydania;

    IF juz_wyplacone > 0 THEN
        RAISE ponowna_wyplata;
    END IF;

    SELECT *
    BULK COLLECT INTO tab_myszy
    FROM Myszy
    WHERE data_wydania IS NULL;

    IF tab_myszy.COUNT < 1 THEN
        RAISE brak_myszy_do_wyplacenia;
    END IF;

    FOR i IN 1..tab_myszy.COUNT
        LOOP
            WHILE tab_konsumpcji(indeks_zjadacza) = 0 AND liczba_najedzonych < tab_pseudo.COUNT
                LOOP
                    liczba_najedzonych := liczba_najedzonych + 1;
                    indeks_zjadacza := MOD(indeks_zjadacza + 1, tab_pseudo.COUNT) + 1;
                END LOOP;


            IF liczba_najedzonych = tab_pseudo.COUNT THEN
                tab_zjadaczy(i) := 'TYGRYS';
            ELSE
                tab_zjadaczy(i) := tab_pseudo(indeks_zjadacza);
                tab_konsumpcji(indeks_zjadacza) := tab_konsumpcji(indeks_zjadacza) - 1;
            END IF;

            IF NEXT_DAY(LAST_DAY(tab_myszy(i).data_zlowienia)-7, 'WEDNESDAY') < tab_myszy(i).data_zlowienia THEN
                tab_myszy(i).data_wydania := NEXT_DAY(LAST_DAY(ADD_MONTHS(tab_myszy(i).data_zlowienia,1))-7, 'WEDNESDAY');
            ELSE
                tab_myszy(i).data_wydania := NEXT_DAY(LAST_DAY(tab_myszy(i).data_wydania)-7, 'WEDNESDAY');
            END IF;
        END LOOP;
    FORALL i IN 1..tab_myszy.COUNT
            UPDATE Myszy SET data_wydania=aktualna_data_wydania , zjadacz=tab_zjadaczy(i)
            WHERE nr_myszy=tab_myszy(i).nr_myszy;
    COMMIT;
    EXCEPTION
            WHEN ponowna_wyplata THEN DBMS_OUTPUT.PUT_LINE('Nie mo�na wyplacic 2 razy w jednym miesiacu.');
            WHEN brak_myszy_do_wyplacenia THEN DBMS_OUTPUT.PUT_LINE('Brak myszy do wyplacenia.');
END;
/

ALTER SESSION SET NLS_DATE_FORMAT = 'YYYY-MM-DD';

INSERT INTO Konto_osobiste_LYSY VALUES(myszy_seq.nextval, 15, '2024-01-13');
INSERT INTO Konto_osobiste_LYSY VALUES(myszy_seq.nextval, 25, '2024-01-12');
INSERT INTO Konto_osobiste_LYSY VALUES(myszy_seq.nextval, 16, '2024-01-13');
INSERT INTO Konto_osobiste_LYSY VALUES(myszy_seq.nextval, 20, '2024-01-13');

INSERT INTO Konto_osobiste_TYGRYS VALUES(myszy_seq.nextval, 31, '2024-01-01');
INSERT INTO Konto_osobiste_TYGRYS VALUES(myszy_seq.nextval, 30, '2024-01-01');
INSERT INTO Konto_osobiste_TYGRYS VALUES(myszy_seq.nextval, 34, '2024-01-10');
INSERT INTO Konto_osobiste_TYGRYS VALUES(myszy_seq.nextval, 26, '2024-01-13');
INSERT INTO Konto_osobiste_TYGRYS VALUES(myszy_seq.nextval, 28, '2024-01-13');
/

BEGIN
    przyjmij_na_stan('LYSY', '2024-01-13');
end;
/

BEGIN
    przyjmij_na_stan('TYGRYS', '2024-01-01');
end;
/
SELECt * FROM Konto_osobiste_TYGRYS;
SELECt * FROM Konto_osobiste_LYSY;
BEGIN
    Wyplata();
END;

/
SELECT COUNT(*)
FROM MYSZY
WHERE data_wydania = '2024-01-31';