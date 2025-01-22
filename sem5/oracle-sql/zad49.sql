--zad49 --------------------------------------------------------------
BEGIN
    EXECUTE IMMEDIATE 'CREATE TABLE MYSZY(
        nr_myszy NUMBER(15)     CONSTRAINT m_pk PRIMARY KEY,
        lowca VARCHAR2(15)      CONSTRAINT m_lowca_fk REFERENCES Kocury(pseudo),
        zjadacz VARCHAR2(15)    CONSTRAINT m_zjadacz_fk REFERENCES Kocury(pseudo),
        waga_myszy NUMBER(3)    CONSTRAINT waga_myszy_ogr CHECK (waga_myszy BETWEEN 20 AND 50),
        data_zlowienia DATE     CONSTRAINT dat_nn NOT NULL,
        data_wydania DATE,
        CONSTRAINT data_ch CHECK (data_zlowienia <= data_wydania)
    )';
END;

SELECT * FROM MYSZY;

DROP TABLE Myszy;

CREATE SEQUENCE seq_myszy;

DROP SEQUENCE seq_myszy;

COMMIT;

-- myszy data
DECLARE
    start_data DATE := TO_DATE('2004-01-01','YYYY-MM-DD');
    end_data DATE := TO_DATE('2025-01-20','YYYY-MM-DD');
    last_sroda DATE := NEXT_DAY(LAST_DAY(start_data) - 7, 'ŚRODA');
               
    zjedzonych_myszy NUMBER(10);
    avg_myszy NUMBER(10);
    id_zjadacza NUMBER;
    
    nr_myszy BINARY_INTEGER := 0;
    rand_date_num BINARY_INTEGER;                    
    temp_num BINARY_INTEGER;
    rand_num BINARY_INTEGER;

    TYPE tp IS TABLE OF Kocury.pseudo%TYPE;
    TYPE tzm IS TABLE OF NUMBER(10);
    TYPE tz IS TABLE OF NUMBER(10);
    TYPE tm IS TABLE OF Myszy%ROWTYPE INDEX BY BINARY_INTEGER;

    tab_pseudo tp := tp();
    tab_zlapanych tz := tz();
    tab_zjadanych_myszy tzm := tzm();
    tab_myszy tm;
BEGIN
    LOOP
        EXIT WHEN start_data >= end_data;

        id_zjadacza := 1;

        IF start_data < NEXT_DAY(LAST_DAY(start_data), 'ŚRODA') - 7 THEN
            last_sroda := LEAST(NEXT_DAY(LAST_DAY(start_data), 'ŚRODA') - 7, end_data);
        ELSE
            last_sroda := LEAST(NEXT_DAY(LAST_DAY(ADD_MONTHS(start_data, 1)), 'ŚRODA') - 7, end_data);
        END IF;

        --koty ktore sa w bandzie w tym czasie plus ile zjadaja myszy
        SELECT pseudo, NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0)
        BULK COLLECT INTO tab_pseudo, tab_zjadanych_myszy
        FROM Kocury
        WHERE w_stadku_od < last_sroda;

        --ile myszy zjedzonych w tym miesiacu
        SELECT SUM(NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0))
        INTO zjedzonych_myszy
        FROM Kocury
        WHERE w_stadku_od < last_sroda;

        avg_myszy := CEIL(zjedzonych_myszy / tab_pseudo.COUNT);

        SELECT avg_myszy
        BULK COLLECT INTO tab_zlapanych
        FROM Kocury
        WHERE w_stadku_od < last_sroda;

        FOR i IN 1..zjedzonych_myszy
            LOOP
                nr_myszy := nr_myszy + 1;
                tab_myszy(nr_myszy).nr_myszy := nr_myszy;

                --losowa liczba zeby nie bylo powtarzalne per miesiac
                temp_num := i + DBMS_RANDOM.VALUE(0, tab_pseudo.COUNT);
                WHILE tab_zlapanych(MOD(temp_num, tab_pseudo.COUNT) + 1) <= 0
                    LOOP
                        temp_num := temp_num + 1;
                    END LOOP;
                rand_num := MOD(temp_num, tab_pseudo.COUNT) + 1;

                tab_myszy(nr_myszy).lowca := tab_pseudo(rand_num);
                tab_zlapanych(rand_num) := tab_zlapanych(rand_num) - 1;

                IF last_sroda < end_data THEN
                    --TRUNC zostawia date bez czasu
                    tab_myszy(nr_myszy).data_wydania := TRUNC(last_sroda);

                    IF tab_zjadanych_myszy(id_zjadacza) = 0 THEN
                        id_zjadacza := id_zjadacza + 1;
                    ELSE
                        tab_zjadanych_myszy(id_zjadacza) := tab_zjadanych_myszy(id_zjadacza) - 1;
                    end if;

                    --zagospodarowanie ewentualnych nadwyżek
                    IF id_zjadacza > tab_pseudo.COUNT THEN
                        id_zjadacza := DBMS_RANDOM.VALUE(1, tab_pseudo.COUNT);
                    end if;

                    tab_myszy(nr_myszy).zjadacz := tab_pseudo(id_zjadacza);
                end if;

                tab_myszy(nr_myszy).waga_myszy := DBMS_RANDOM.VALUE(20, 50);
                rand_date_num := DBMS_RANDOM.VALUE(0, 20);
                tab_myszy(nr_myszy).data_zlowienia := start_data + MOD(nr_myszy + rand_date_num, TRUNC(last_sroda) - TRUNC(start_data));

            end loop;

            start_data := last_sroda + 1;
            last_sroda := NEXT_DAY(LAST_DAY(ADD_MONTHS(start_data, 1)) - 7, 'ŚRODA');
    END LOOP;

    FORALL i in 1..tab_myszy.COUNT
        INSERT INTO Myszy(nr_myszy, lowca, zjadacz, waga_myszy, data_zlowienia, data_wydania)
        VALUES (seq_myszy.NEXTVAL, tab_myszy(i).LOWCA, tab_myszy(i).ZJADACZ, tab_myszy(i).WAGA_MYSZY, tab_myszy(i).DATA_ZLOWIENIA, tab_myszy(i).DATA_WYDANIA);
END;



SELECT COUNT(*) FROM Myszy;



-- konta osobiste
BEGIN
   FOR kot in (SELECT pseudo FROM Kocury)
    LOOP
       EXECUTE IMMEDIATE 'CREATE TABLE Konto_osobiste_' || kot.pseudo ||
         '( nr_myszy NUMBER(10) CONSTRAINT Kos_pk_'     || kot.pseudo || ' PRIMARY KEY,' ||
           'waga NUMBER(5)      CONSTRAINT Kos_waga_'   || kot.pseudo || ' CHECK (waga BETWEEN 20 AND 50),' ||
           'data_zlowienia DATE CONSTRAINT Kos_data_nn_'|| kot.pseudo || ' NOT NULL)';
       END LOOP;
END;



BEGIN
    FOR kot IN (SELECT pseudo FROM Kocury)
    LOOP
        EXECUTE IMMEDIATE 'DROP TABLE Konto_osobiste_' || kot.pseudo;
        END LOOP;
END;

-- end of konta osobiste



CREATE OR REPLACE PROCEDURE przyjmij_na_stan(pseudonim Kocury.pseudo%TYPE, data_zlowienia DATE)
AS
    TYPE tw IS TABLE OF NUMBER(5);
    TYPE tn IS TABLE OF NUMBER(10);

    tab_wag tw := tw();
    tab_numerow tn := tn();
    pseudo_kota Kocury.pseudo%TYPE := UPPER(pseudonim);

    czy_istnieje NUMBER;
    konto VARCHAR(128);

    brak_kota_exception EXCEPTION;
    bad_date_exception EXCEPTION;
    no_mouse_in_day_exception EXCEPTION;
BEGIN

    IF data_zlowienia > SYSDATE
        THEN RAISE bad_date_exception;
    END IF;

    SELECT COUNT(*) INTO czy_istnieje
    FROM KOCURY
    WHERE pseudo = pseudo_kota;

    IF czy_istnieje = 0 THEN
        RAISE brak_kota_exception;
    END IF;

    konto := 'Konto_osobiste_' || pseudo_kota;
    DBMS_OUTPUT.PUT_LINE(konto);

    EXECUTE IMMEDIATE
        'SELECT nr_myszy, waga
            FROM Konto_osobiste_'||pseudo_kota||
            ' WHERE data_zlowienia= '''||data_zlowienia||''''
        BULK COLLECT INTO tab_numerow, tab_wag;

    IF tab_numerow.COUNT = 0 THEN
        RAISE no_mouse_in_day_exception;
    end if;

    FORALL i in 1..tab_numerow.COUNT
        INSERT INTO Myszy VALUES (tab_numerow(i), UPPER(pseudo_kota), NULL, tab_wag(i), data_zlowienia, NULL);

    EXECUTE IMMEDIATE 'DELETE FROM Konto_osobiste_'||pseudo_kota||' WHERE data_zlowienia = '''||data_zlowienia||'''';

    EXCEPTION
        WHEN brak_kota_exception THEN DBMS_OUTPUT.PUT_LINE('brak kota o pseudonimie '|| UPPER(pseudo_kota));
        WHEN bad_date_exception THEN DBMS_OUTPUT.PUT_LINE('data zlowienia nie moze byc pozniejsza niz dzisiejsza data.');
        WHEN no_mouse_in_day_exception THEN DBMS_OUTPUT.PUT_LINE('brak myszy zlowionych w dniu ' || data_zlowienia || ' przez ' || pseudo_kota);
END;





CREATE OR REPLACE PROCEDURE wyplata
AS
    TYPE tp IS TABLE OF Kocury.pseudo%TYPE;
    TYPE tzm is TABLE OF NUMBER(5);
    TYPE tz IS TABLE OF Kocury.pseudo%TYPE INDEX BY BINARY_INTEGER;
    TYPE tm IS TABLE OF Myszy%ROWTYPE;

    tab_pseudo tp := tp();
    tab_zjadanych_myszy tzm := tzm();
    tab_zjadaczy tz;
    tab_myszy tm;

    start_data DATE := TRUNC(NEXT_DAY(LAST_DAY(SYSDATE) - 7, 'ŚRODA'));

    najedzone_koty_num NUMBER(5) := 0;
    id_zjadacza NUMBER(5) := 1;
    wyplacone_num NUMBER(5);

    ponowna_wyplata_exception EXCEPTION;
    brak_myszy_wyplaty_exception EXCEPTION;
BEGIN
    SELECT COUNT(nr_myszy) INTO wyplacone_num
    FROM MYSZY
    WHERE data_wydania = start_data;

    IF wyplacone_num > 0 THEN
        RAISE ponowna_wyplata_exception;
    END IF;

    SELECT *
    BULK COLLECT INTO tab_myszy
    FROM Myszy
    WHERE data_wydania IS NULL;

    IF tab_myszy.COUNT < 1 THEN
        RAISE brak_myszy_wyplaty_exception;
    END IF;

    SELECT pseudo, NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0)
    BULK COLLECT INTO tab_pseudo, tab_zjadanych_myszy
    FROM Kocury CONNECT BY PRIOR pseudo = szef
    START WITH SZEF IS NULL
    ORDER BY level;

    FOR i IN 1..tab_myszy.COUNT
        LOOP
            WHILE tab_zjadanych_myszy(id_zjadacza) = 0 AND najedzone_koty_num < tab_pseudo.COUNT
                LOOP
                    -- kazdy obrot petli to jeden kot zjada
                    najedzone_koty_num := najedzone_koty_num + 1;
                    id_zjadacza := MOD(id_zjadacza + 1, tab_pseudo.COUNT) + 1;
                END LOOP;

            IF najedzone_koty_num = tab_pseudo.COUNT THEN
                --nadmiary zbiera szef szefow
                tab_zjadaczy(i) := 'TYGRYS';
            ELSE
                tab_zjadaczy(i) := tab_pseudo(id_zjadacza);
                tab_zjadanych_myszy(id_zjadacza) := tab_zjadanych_myszy(id_zjadacza) - 1;
            END IF;

            IF NEXT_DAY(LAST_DAY(tab_myszy(i).data_zlowienia) - 7, 'ŚRODA') < tab_myszy(i).data_zlowienia THEN
                tab_myszy(i).data_wydania := NEXT_DAY(LAST_DAY(ADD_MONTHS(tab_myszy(i).data_zlowienia,1)) - 7, 'ŚRODA');
            ELSE
                tab_myszy(i).data_wydania := NEXT_DAY(LAST_DAY(tab_myszy(i).data_wydania)-7, 'ŚRODA');
            END IF;
            
        END LOOP;
        
    FORALL i IN 1..tab_myszy.COUNT
            UPDATE Myszy SET data_wydania=start_data , zjadacz=tab_zjadaczy(i)
            WHERE nr_myszy=tab_myszy(i).nr_myszy;

    COMMIT;

    EXCEPTION
            WHEN ponowna_wyplata_exception THEN DBMS_OUTPUT.PUT_LINE('nie mozna wyplacic wiecej niz raz w jednym miesiacu.');
            WHEN brak_myszy_wyplaty_exception THEN DBMS_OUTPUT.PUT_LINE('brak myszy do wydania wyplaty.');
END;


COMMIT;


--test przyjmij na stan

INSERT INTO Konto_osobiste_LYSY VALUES(seq_myszy.nextval, 21, '2025-01-13');
INSERT INTO Konto_osobiste_LYSY VALUES(seq_myszy.nextval, 25, '2025-01-13');
INSERT INTO Konto_osobiste_LYSY VALUES(seq_myszy.nextval, 29, '2025-01-15');
INSERT INTO Konto_osobiste_LYSY VALUES(seq_myszy.nextval, 27, '2025-01-15');
INSERT INTO Konto_osobiste_LYSY VALUES(seq_myszy.nextval, 41, '2025-01-17');

INSERT INTO Konto_osobiste_TYGRYS VALUES(seq_myszy.nextval, 31, '2025-01-13');
INSERT INTO Konto_osobiste_TYGRYS VALUES(seq_myszy.nextval, 30, '2025-01-15');
INSERT INTO Konto_osobiste_TYGRYS VALUES(seq_myszy.nextval, 34, '2025-01-15');
INSERT INTO Konto_osobiste_TYGRYS VALUES(seq_myszy.nextval, 26, '2025-01-17');
INSERT INTO Konto_osobiste_TYGRYS VALUES(seq_myszy.nextval, 28, '2025-01-17');



SELECT * FROM Konto_osobiste_TYGRYS;
SELECT * FROM Konto_osobiste_LYSY;


BEGIN
    przyjmij_na_stan('LYSY', '2025-01-13');
end;

BEGIN
    przyjmij_na_stan('TYGRYS', '2025-01-15');
end;



SELECT * FROM Konto_osobiste_TYGRYS;
SELECT * FROM Konto_osobiste_LYSY;


-- test wyplata

SELECT COUNT(*)
FROM MYSZY
WHERE data_wydania = '2025-01-29';


BEGIN
    wyplata();
END;


-- suma dla wszystkich kotow (NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))
SELECT SUM(NVL(PRZYDZIAL_MYSZY, 0) + NVL(MYSZY_EXTRA, 0))
FROM Kocury;



SELECT COUNT(*)
FROM MYSZY
WHERE data_wydania = '2025-01-29';


COMMIT;

ROLLBACK;

