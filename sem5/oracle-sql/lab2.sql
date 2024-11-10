ALTER SESSION SET NLS_DATE_FORMAT='YYYY-MM-DD';

----------------------------- ZAD 17 -----------------------------

SELECT
    pseudo as "POLUJE W POLU",
    przydzial_myszy as "PRZYDZIAL MYSZY",
    nazwa as "BANDA"
FROM
    Kocury JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE
    (teren = 'CALOSC' OR teren = 'POLE') AND przydzial_myszy > 50
ORDER BY
    przydzial_myszy DESC;

----------------------------- ZAD 18 -----------------------------

SELECT
    K1.imie,
    TO_CHAR(K1.w_stadku_od, 'yyyy-mm-dd') "POLUJE OD"
FROM
    Kocury K1 JOIN Kocury K2 ON K2.imie = 'JACEK'
WHERE
    K1.w_stadku_od < K2.w_stadku_od
ORDER BY
    K1.w_stadku_od DESC;

----------------------------- ZAD 19a -----------------------------

SELECT
    K1.imie,
    K1.funkcja,
    K2.imie as "SZEF 1",
    K3.imie as "SZEF 2",
    K4.imie as "SZEF 3"
FROM
    (Kocury K1 LEFT JOIN
    (Kocury K2 LEFT JOIN
    (Kocury K3 LEFT JOIN
    (Kocury K4
    ON K4.pseudo = K3.szef))
    ON K3.pseudo = K2.szef)
    ON K2.pseudo = K1.szef)
WHERE
    K1.funkcja = 'KOT' OR K1.funkcja = 'MILUSIA';

----------------------------- ZAD 19b -----------------------------

SELECT *
FROM(
    SELECT
        CONNECT_BY_ROOT imie "IMIE ",
        imie,
        CONNECT_BY_ROOT funkcja "FUNKCJA",
        LEVEL "L"
    FROM Kocury
        CONNECT BY PRIOR szef = pseudo
    START WITH
        funkcja IN ('KOT', 'MILUSIA'))
PIVOT (
    MAX(imie) FOR L IN (2 szef1, 3 szef2, 4 szef3)
)
ORDER BY
    szef3;

----------------------------- ZAD 19c -----------------------------

--RTRIM(SYS_CONNECT_BY_PATH(imie, ' | '), ' | ') AS "IMIONA KOLEJNYCH SZEFÓW"
--RTRIM(REVERSE(RTRIM(SYS_CONNECT_BY_PATH(REVERSE(imie), ' | '), imie)), ' | ') "IMIONA KOLEJNYCH SZEFÓW"

SELECT
    imie as "IMIE",
    funkcja as "FUNKCJA",
    RTRIM(REVERSE(RTRIM(SYS_CONNECT_BY_PATH(REVERSE(imie), ' | '), imie)), ' | ') "IMIONA KOLEJNYCH SZEFÓW"
FROM
    Kocury
WHERE
    funkcja in ('KOT', 'MILUSIA')
    CONNECT BY
    PRIOR pseudo = szef
START WITH
    szef IS NULL;

----------------------------- ZAD 20 -----------------------------

SELECT
    Kocury.imie "IMIE KOTKI",
    Bandy.nazwa "NAZWA BADNY",
    Wrogowie.imie_wroga "IMIE WROGA",
    Wrogowie.stopien_wrogosci "OCENA WROGA",
    Wrogowie_kocurow.data_incydentu "DATA INC."
FROM
    Wrogowie JOIN
    Wrogowie_kocurow JOIN
    Kocury JOIN BANDY
    ON Kocury.nr_bandy = Bandy.nr_bandy
    ON Wrogowie_kocurow.pseudo = Kocury.pseudo
    ON Wrogowie.imie_wroga = Wrogowie_kocurow.imie_wroga
WHERE
    Kocury.plec = 'D' AND
    Wrogowie_kocurow.DATA_INCYDENTU > TO_DATE('2007-01-01');

----------------------------- ZAD 21 -----------------------------

SELECT
    Bandy.nazwa "NAZWA BANDY",
    COUNT(Q1.pseudo) "KOTY Z WROGAMI"
FROM
    Bandy JOIN(
        SELECT DISTINCT
            Kocury.pseudo,
            Kocury.nr_bandy
        FROM (
            Kocury JOIN Wrogowie_kocurow
            ON Kocury.pseudo = Wrogowie_kocurow.pseudo))
        Q1 ON Q1.nr_bandy= Bandy.nr_bandy
GROUP BY
    Bandy.nazwa;

----------------------------- ZAD 22 -----------------------------

SELECT
    funkcja,
    Kocury.pseudo "PSEUDONIM KOTA",
    COUNT(Kocury.pseudo) "LICZBA WROGOW"
FROM
    Kocury
        JOIN Wrogowie_kocurow
        ON Kocury.pseudo = Wrogowie_kocurow.pseudo
GROUP BY
    Kocury.pseudo,
    funkcja
HAVING
    COUNT(Kocury.pseudo) >= 2;

----------------------------- ZAD 23 -----------------------------

SELECT
    imie "IMIE",
    12 * (przydzial_myszy + NVL(myszy_extra, 0)) "DAWKA ROCZNA",
    'ponizej 864' "DAWKA"
FROM
    Kocury
WHERE
    myszy_extra IS NOT NULL AND
    12 * (przydzial_myszy + NVL(myszy_extra, 0)) < 864

UNION

SELECT
    imie,
    12 * (przydzial_myszy + NVL(myszy_extra, 0)),
    '864'
FROM
    Kocury
WHERE
    myszy_extra IS NOT NULL AND
    12 * (przydzial_myszy + NVL(myszy_extra, 0)) = 864

UNION

SELECT
    imie,
    12 * (przydzial_myszy + NVL(myszy_extra, 0)),
    'powyzej 864'
FROM
    Kocury
WHERE
    myszy_extra IS NOT NULL AND
    12 * (przydzial_myszy + NVL(myszy_extra, 0)) > 864
ORDER BY
    2 DESC;

----------------------------- ZAD 24a -----------------------------

SELECT
    Bandy.nr_bandy "NR BANDY",
    nazwa,
    teren
FROM
    Bandy
        LEFT JOIN Kocury
        ON Bandy.nr_bandy = Kocury.nr_bandy
WHERE
    imie IS NULL;

----------------------------- ZAD 24b -----------------------------

SELECT
    Bandy.nr_bandy "NR BANDY",
    nazwa,
    teren
FROM
    Bandy

MINUS

SELECT DISTINCT
    Kocury.nr_bandy,
    Bandy.nazwa,
    Bandy.teren
FROM Bandy
    LEFT JOIN Kocury
    ON Bandy.nr_bandy = Kocury.nr_bandy;


----------------------------- ZAD 25 -----------------------------

SELECT
    imie,
    funkcja,
    NVL(przydzial_myszy, 0) "PRZYDZIAL MYSZY"
FROM
    Kocury
WHERE
    NVL(przydzial_myszy, 0) >= ALL (
        SELECT 3 * NVL(przydzial_myszy, 0)
            FROM Kocury
                JOIN Bandy
                ON Kocury.nr_bandy = Bandy.nr_bandy
                    WHERE
                        funkcja = 'MILUSIA' AND
                        Bandy.teren IN ('SAD', 'CALOSC')
    );

----------------------------- ZAD 26 -----------------------------

SELECT
    K2.funkcja,
    K2.AVG "Srednio najw. i najm. myszy"
FROM(
    SELECT
        MIN(AVG) "MINAVG",
        MAX(AVG) "MAXAVG"
    FROM(
        SELECT
            funkcja,
            CEIL(AVG(przydzial_myszy + NVL(myszy_extra, 0))) "AVG"
        FROM
            Kocury
        WHERE
            funkcja != 'SZEFUNIO'
        GROUP BY
            funkcja
    )
) K1

JOIN(
SELECT
    funkcja,
    CEIL(AVG(przydzial_myszy + NVL(myszy_extra, 0))) "AVG"
FROM
    Kocury
WHERE
    funkcja != 'SZEFUNIO'
GROUP BY
    funkcja
) K2

ON K1.MINAVG = K2.AVG
OR K1.MAXAVG = K2.AVG

ORDER BY
    K2.AVG;

----------------------------- ZAD 27a -----------------------------

SELECT
    pseudo,
    przydzial_myszy + NVL(myszy_extra, 0) "ZJADA"
FROM
    Kocury K
WHERE(
    SELECT
        COUNT(DISTINCT przydzial_myszy + NVL(myszy_extra, 0))
    FROM
        Kocury
    WHERE
        przydzial_myszy + NVL(myszy_extra, 0) > K.przydzial_myszy + NVL(K.myszy_extra, 0)
) < 6
ORDER BY
    2 DESC;

----------------------------- ZAD 27b -----------------------------

SELECT
    pseudo,
    przydzial_myszy + NVL(myszy_extra, 0) "ZJADA"
FROM
    Kocury
WHERE
    przydzial_myszy + NVL(myszy_extra, 0) IN (
    SELECT *
    FROM (
        SELECT DISTINCT
            przydzial_myszy + NVL(myszy_extra, 0)
        FROM
            Kocury
        ORDER BY
            1 DESC
    )
    WHERE
        ROWNUM <= 6
);

----------------------------- ZAD 27c -----------------------------

SELECT
    K1.pseudo,
    AVG(K1.przydzial_myszy + NVL(K1.myszy_extra, 0)) "ZJADA"
FROM
    Kocury K1 LEFT JOIN
    Kocury K2 ON
        K1.przydzial_myszy + NVL(K1.myszy_extra, 0) < K2.przydzial_myszy + NVL(K2.myszy_extra, 0)
GROUP BY
    K1.pseudo
HAVING
    COUNT(K2.pseudo) <= 6
ORDER BY
    2 DESC;

----------------------------- ZAD 27d -----------------------------

SELECT
    pseudo,
    ZJADA
FROM (
    SELECT
        pseudo,
        NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) "ZJADA",
        DENSE_RANK() OVER (
            ORDER BY
                przydzial_myszy + NVL(myszy_extra, 0) DESC
        ) RANK
    FROM
        Kocury
    )
WHERE RANK <= 6;


----------------------------- ZAD 28 -----------------------------

SELECT
    TO_CHAR(YEAR) "ROK",
    SUM "LICZBA WSTAPIEN"
FROM (
    SELECT
        YEAR,
        SUM,
        ABS(SUM-AVG) "DIFF"
    FROM (
        SELECT
            EXTRACT(YEAR FROM w_stadku_od) "YEAR",
            COUNT(EXTRACT(YEAR FROM w_stadku_od)) "SUM"
        FROM
            Kocury
        GROUP BY
            EXTRACT(YEAR FROM w_stadku_od)
    )
    JOIN (
        SELECT
            AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od))) "AVG"
        FROM
            Kocury
        GROUP BY
            EXTRACT(YEAR FROM w_stadku_od)
    ) ON SUM < AVG
)
WHERE DIFF < ALL (
    SELECT
        MAX(ABS(SUM-AVG)) "DIFF"
    FROM (
        SELECT
            EXTRACT(YEAR FROM w_stadku_od) "YEAR",
            COUNT(EXTRACT(YEAR FROM w_stadku_od)) "SUM"
        FROM
            Kocury
        GROUP BY
            EXTRACT(YEAR FROM w_stadku_od)
    )
    JOIN (
        SELECT
            AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od))) "AVG"
        FROM
            Kocury
        GROUP BY
            EXTRACT(YEAR FROM w_stadku_od)
    ) ON SUM < AVG
)

UNION

SELECT
    'Srednia',
    ROUND(AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od))), 7) "AVG"
FROM
    Kocury
GROUP BY
    EXTRACT(YEAR FROM w_stadku_od)

UNION

SELECT
    TO_CHAR(YEAR),
    SUM
FROM (
    SELECT
        YEAR,
        SUM,
        ABS(SUM-AVG) "DIFF"
    FROM (
        SELECT
            EXTRACT(YEAR FROM w_stadku_od) "YEAR",
            COUNT(EXTRACT(YEAR FROM w_stadku_od)) "SUM"
        FROM
            Kocury
        GROUP BY
            EXTRACT(YEAR FROM w_stadku_od)
    )
    JOIN (
        SELECT AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od))) "AVG"
    FROM
        Kocury
    GROUP BY
        EXTRACT(YEAR FROM w_stadku_od)
    ) ON SUM > AVG
)
WHERE DIFF < ALL (
    SELECT
        MAX(ABS(SUM-AVG)) "DIFF"
    FROM (
        SELECT
            EXTRACT(YEAR FROM w_stadku_od) "YEAR",
            COUNT(EXTRACT(YEAR FROM w_stadku_od)) "SUM"
        FROM
            Kocury
        GROUP BY
            EXTRACT(YEAR FROM w_stadku_od)
    )
    JOIN (
        SELECT AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od))) "AVG"
    FROM
        Kocury
    GROUP BY
        EXTRACT(YEAR FROM w_stadku_od)
    ) ON SUM > AVG
)
ORDER BY 2 ASC;

----------------------------- ZAD 29a -----------------------------

SELECT
    K1.imie,
    MIN(K1.przydzial_myszy + NVL(K1.myszy_extra, 0)) "ZJADA",
    K1.nr_bandy,
    TO_CHAR(AVG(K2.przydzial_myszy + NVL(K2.myszy_extra, 0)), '99.99') "SREDNIA BANDY"
FROM
    Kocury K1 JOIN
    Kocury K2 ON K1.nr_bandy= K2.nr_bandy
WHERE
    K1.PLEC = 'M'
GROUP BY
    K1.imie,
    K1.nr_bandy
HAVING
    MIN(K1.przydzial_myszy + NVL(K1.myszy_extra, 0)) < AVG(K2.przydzial_myszy + NVL(K2.myszy_extra, 0))
ORDER BY 4 ASC;

----------------------------- ZAD 29b -----------------------------

SELECT
    imie,
    przydzial_myszy + NVL(myszy_extra, 0) "ZJADA",
    K1.nr_bandy, TO_CHAR(AVG, '99.99') "SREDNIA BANDY"
FROM
    Kocury K1 JOIN (
        SELECT
            nr_bandy,
            AVG(przydzial_myszy + NVL(myszy_extra, 0)) "AVG"
        FROM
            Kocury
        GROUP BY
            nr_bandy
    ) K2 ON
    K1.nr_bandy = K2.nr_bandy AND
    przydzial_myszy + NVL(myszy_extra, 0) < AVG
WHERE
    PLEC = 'M'
ORDER BY 4 ASC;

----------------------------- ZAD 29c -----------------------------

SELECT
    imie,
    przydzial_myszy + NVL(myszy_extra, 0) "ZJADA",
    nr_bandy,
    TO_CHAR((SELECT AVG(przydzial_myszy + NVL(myszy_extra, 0)) "AVG"
FROM
    Kocury K
WHERE
    Kocury.nr_bandy = K.nr_bandy), '99.99') "SREDNIA BANDY"
FROM
    Kocury
WHERE
    PLEC = 'M' AND
    przydzial_myszy + NVL(myszy_extra, 0) < (
        SELECT
            AVG(przydzial_myszy + NVL(myszy_extra, 0)) "AVG"
        FROM
            Kocury K
        WHERE
            Kocury.nr_bandy= K.nr_bandy
    )
ORDER BY 4 ASC;

----------------------------- ZAD 30 -----------------------------

SELECT
    imie,
    TO_CHAR(w_stadku_od, 'YYYY-MM-DD') || ' <--- NAJSTARSZY STAZEM W BANDZIE ' || nazwa "WSTAPIL DO STADKA"
FROM (
    SELECT
        imie,
        w_stadku_od, nazwa,
        MIN(w_stadku_od) OVER (PARTITION BY Kocury.nr_bandy) minstaz
    FROM
        Kocury
    JOIN
        Bandy
    ON
        Kocury.nr_bandy = Bandy.nr_bandy
)
WHERE
    w_stadku_od = minstaz

UNION

SELECT
    imie,
    TO_CHAR(w_stadku_od, 'YYYY-MM-DD') || ' <--- NAJMLODSZY STAZEM W BANDZIE ' || nazwa "WSTAPIL DO STADKA"
FROM (
    SELECT
        imie,
        w_stadku_od, nazwa,
        MAX(w_stadku_od) OVER (PARTITION BY Kocury.nr_bandy) maxstaz
    FROM
        Kocury
    JOIN
        Bandy
    ON
        Kocury.nr_bandy = Bandy.nr_bandy
)
WHERE
    w_stadku_od = maxstaz

UNION

SELECT
    imie,
    TO_CHAR(w_stadku_od, 'YYYY-MM-DD')
FROM (
    SELECT
        imie,
        w_stadku_od, nazwa,
        MIN(w_stadku_od) OVER (PARTITION BY Kocury.nr_bandy) minstaz,
        MAX(w_stadku_od) OVER (PARTITION BY Kocury.nr_bandy) maxstaz
    FROM
        Kocury
    JOIN
        Bandy
    ON
        Kocury.nr_bandy = Bandy.nr_bandy
)
WHERE
    W_STADKU_OD != minstaz AND
    W_STADKU_OD != maxstaz
ORDER BY IMIE;

----------------------------- ZAD 31 -----------------------------


CREATE OR REPLACE
    VIEW Statystyki(nazwa_bandy, sre_spoz, max_spoz, min_spoz, koty, koty_z_dod)
AS
SELECT
    nazwa,
    AVG(przydzial_myszy),
    MAX(przydzial_myszy),
    MIN(przydzial_myszy),
    COUNT(pseudo),
    COUNT(myszy_extra)
FROM
    Kocury
JOIN
    Bandy
ON
    Kocury.nr_bandy = Bandy.nr_bandy
GROUP BY nazwa;

SELECT *
FROM Statystyki;

SELECT
    pseudo "PSEUDONIM",
    imie,
    funkcja,
    przydzial_myszy "ZJADA", 'OD ' || min_spoz || ' DO ' || max_spoz "GRANICE SPOZYCIA",
    TO_CHAR(w_stadku_od, 'YYYY-MM-DD') "LOWI OD"
FROM (
    Kocury
    JOIN
        Bandy
    ON
        Kocury.nr_bandy = Bandy.nr_bandy
    JOIN
        Statystyki
    ON
        Bandy.nazwa = Statystyki.nazwa_bandy
)
WHERE
    pseudo = UPPER('PLACEK');

----------------------------- ZAD 32 -----------------------------

CREATE OR REPLACE
    VIEW StaraGwardia(pseudo, plec, przydzial_myszy, myszy_extra, nr_bandy)
AS
SELECT
    pseudo,
    plec,
    przydzial_myszy,
    myszy_extra,
    nr_bandy
FROM
    Kocury
WHERE pseudo IN (
    SELECT
        pseudo
    FROM
        Kocury
    JOIN
        Bandy
    ON
        Kocury.nr_bandy = Bandy.nr_bandy
    WHERE
        nazwa = 'CZARNI RYCERZE'
    ORDER BY
        w_stadku_od
    FETCH NEXT 3 ROWS ONLY
) OR pseudo IN (
    SELECT
        pseudo
    FROM
        Kocury
    JOIN
        Bandy
    ON
        Kocury.nr_bandy= Bandy.nr_bandy
    WHERE
        nazwa = 'LACIACI MYSLIWI'
    ORDER BY
        w_stadku_od
    FETCH NEXT 3 ROWS ONLY
);

SELECT
    pseudo,
    plec,
    przydzial_myszy "Myszy przed podw.",
    NVL(myszy_extra, 0) "Ekstra przed podw."
FROM
    StaraGwardia;
UPDATE
    StaraGwardia
SET
    przydzial_myszy = przydzial_myszy + DECODE(plec, 'D', 0.1 * (
        SELECT
            MIN(przydzial_myszy)
        FROM
            Kocury
        ), 10),
    myszy_extra = NVL(myszy_extra, 0) + 0.15 * (
    SELECT
        AVG(NVl(myszy_extra, 0))
    FROM
        Kocury
    WHERE
        StaraGwardia.nr_bandy = nr_bandy
    );

SELECT
    pseudo,
    plec,
    przydzial_myszy "Myszy po podw.",
    NVL(myszy_extra, 0) "Ekstra po podw."
FROM
    StaraGwardia;

ROLLBACK;

----------------------------- ZAD 33a -----------------------------

SELECT *
FROM (
    SELECT
        TO_CHAR(DECODE(plec, 'D', nazwa, ' ')) "NAZWA BANDY",
        TO_CHAR(DECODE(plec, 'D', 'Kotka', 'Kocor')),
        TO_CHAR(COUNT(pseudo)) "ILE",
        TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE funkcja = 'SZEFUNIO' AND K.nr_bandy= Kocury.nr_bandy AND K.plec = Kocury.plec),0)) "SZEFUNIO",
        TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE funkcja = 'BANDZIOR' AND K.nr_bandy= Kocury.nr_bandy AND K.plec = Kocury.plec),0)) "BANDZIOR",
        TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE funkcja = 'LOWCZY' AND K.nr_bandy= Kocury.nr_bandy AND K.plec = Kocury.plec),0)) "LOWCZY",
        TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE funkcja = 'LAPACZ' AND K.nr_bandy= Kocury.nr_bandy AND K.plec = Kocury.plec),0)) "LAPACZ",
        TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE funkcja = 'KOT' AND K.nr_bandy= Kocury.nr_bandy AND K.plec = Kocury.plec),0)) "KOT",
        TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE funkcja = 'MILUSIA' AND K.nr_bandy= Kocury.nr_bandy AND K.plec = Kocury.plec),0)) "MILUSIA",
        TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE funkcja = 'DZIELCZY' AND K.nr_bandy= Kocury.nr_bandy AND K.plec = Kocury.plec),0)) "DZIELCZY",
        TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE K.nr_bandy= Kocury.nr_bandy AND K.plec = Kocury.plec),0)) "SUMA"
    FROM (
        Kocury
        JOIN
            Bandy
        ON
            Kocury.nr_bandy = Bandy.nr_bandy
    )
    GROUP BY
        nazwa,
        plec,
        Kocury.nr_bandy
    ORDER BY
        nazwa
)

UNION

SELECT
    'Z--------------',
    '------',
    '--------',
    '---------',
    '---------',
    '--------',
    '--------',
    '--------',
    '--------',
    '--------',
    '--------'
FROM
    DUAL

UNION

SELECT DISTINCT
    'ZJADA RAZEM',
    ' ',
    ' ',
    TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE funkcja = 'SZEFUNIO'),0)) "SZEFUNIO",
    TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE funkcja = 'BANDZIOR'),0)) "BANDZIOR",
    TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE funkcja = 'LOWCZY'),0)) "LOWCZY",
    TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE funkcja = 'LAPACZ'),0)) "LAPACZ",
    TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE funkcja = 'KOT'),0)) "KOT",
    TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE funkcja = 'MILUSIA'),0)) "MILUSIA",
    TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K WHERE funkcja = 'DZIELCZY'),0)) "DZIELCZY",
    TO_CHAR(NVL((SELECT SUM(przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury K),0)) "SUMA"
FROM (
    Kocury
    JOIN
        Bandy
    ON
        Kocury.nr_bandy = Bandy.nr_bandy
);

----------------------------- ZAD 33b -----------------------------

SELECT *
FROM (
    SELECT
        TO_CHAR(DECODE(plec, 'D', nazwa, ' ')) "NAZWA BANDY",
        TO_CHAR(DECODE(plec, 'D', 'Kotka', 'Kocor')),
        TO_CHAR(ile) "ILE",
        TO_CHAR(NVL(szefunio, 0)) "SZEFUNIO",
        TO_CHAR(NVL(bandzior,0)) "BANDZIOR",
        TO_CHAR(NVL(lowczy,0)) "LOWCZY",
        TO_CHAR(NVL(lapacz,0)) "LAPACZ",
        TO_CHAR(NVL(kot,0)) "KOT",
        TO_CHAR(NVL(milusia,0)) "MILUSIA",
        TO_CHAR(NVL(dzielczy,0)) "DZIELCZY",
        TO_CHAR(NVL(suma,0)) "SUMA"
    FROM (
        SELECT
            nazwa,
            plec,
            funkcja,
            przydzial_myszy + NVL(myszy_extra, 0) liczba
        FROM
            Kocury
        JOIN
            Bandy
        ON
            Kocury.nr_bandy= Bandy.nr_bandy
    ) PIVOT (
        SUM(liczba) FOR funkcja IN (
            'SZEFUNIO' szefunio, 'BANDZIOR' bandzior, 'LOWCZY' lowczy, 'LAPACZ' lapacz, 'KOT' kot, 'MILUSIA' milusia, 'DZIELCZY' dzielczy
        )
    )
    JOIN (
        SELECT
            nazwa "N",
            plec "P",
            COUNT(pseudo) ile,
            SUM(przydzial_myszy + NVL(myszy_extra, 0)) suma
        FROM
            Kocury K
        JOIN
            Bandy B
        ON
            K.nr_bandy= B.nr_bandy
        GROUP BY
            nazwa,
            plec
        ORDER BY
            nazwa
    )
    ON
        N = nazwa AND P = plec
)

UNION

SELECT
    'Z--------------',
    '------',
    '--------',
    '---------',
    '---------',
    '--------',
    '--------',
    '--------',
    '--------',
    '--------',
    '--------'
FROM
    DUAL

UNION

SELECT
    'ZJADA RAZEM',
    ' ',
    ' ',
    TO_CHAR(NVL(szefunio, 0)) szefunio,
    TO_CHAR(NVL(bandzior, 0)) bandzior,
    TO_CHAR(NVL(lowczy, 0)) lowczy,
    TO_CHAR(NVL(lapacz, 0)) lapacz,
    TO_CHAR(NVL(kot, 0)) kot,
    TO_CHAR(NVL(milusia, 0)) milusia,
    TO_CHAR(NVL(dzielczy, 0)) dzielczy,
    TO_CHAR(NVL(suma, 0)) suma
FROM (
    SELECT
        funkcja,
        przydzial_myszy + NVL(myszy_extra, 0) liczba
    FROM
        Kocury
    JOIN
        Bandy
    ON
        Kocury.nr_bandy = Bandy.nr_bandy
)
PIVOT (
    SUM(liczba) FOR funkcja IN (
        'SZEFUNIO' szefunio, 'BANDZIOR' bandzior, 'LOWCZY' lowczy, 'LAPACZ' lapacz, 'KOT' kot, 'MILUSIA' milusia, 'DZIELCZY' dzielczy
    )
)
CROSS JOIN (
    SELECT
        SUM(przydzial_myszy + NVL(myszy_extra, 0)) suma
    FROM
        Kocury
);
