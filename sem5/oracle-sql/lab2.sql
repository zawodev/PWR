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
    NVL(K2.imie, ' ') as "SZEF 1",
    NVL(K3.imie, ' ') as "SZEF 2",
    NVL(K4.imie, ' ') as "SZEF 3"
FROM
    Kocury K1 LEFT JOIN
    Kocury K2 LEFT JOIN
    Kocury K3 LEFT JOIN
    Kocury K4
    ON K4.pseudo = K3.szef
    ON K3.pseudo = K2.szef
    ON K2.pseudo = K1.szef
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
    REVERSE(RTRIM(RTRIM(SYS_CONNECT_BY_PATH(REVERSE(imie), ' | '), imie), ' | ')) "IMIONA KOLEJNYCH SZEFÓW"
FROM
    Kocury
WHERE
    funkcja in ('KOT', 'MILUSIA')
    CONNECT BY PRIOR
    pseudo = szef
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
    Kocury JOIN
    BANDY
    ON Kocury.nr_bandy = Bandy.nr_bandy
    ON Wrogowie_kocurow.pseudo = Kocury.pseudo
    ON Wrogowie.imie_wroga = Wrogowie_kocurow.imie_wroga
WHERE
    Kocury.plec = 'D' AND
    Wrogowie_kocurow.data_incydentu > TO_DATE('2007-01-01');

----------------------------- ZAD 21 -----------------------------

SELECT
    Bandy.nazwa AS "NAZWA BANDY",
    COUNT(DISTINCT Kocury.pseudo) AS "KOTY Z WROGAMI"
FROM
    Bandy
        JOIN Kocury ON
        Kocury.nr_bandy = Bandy.nr_bandy
        JOIN Wrogowie_kocurow ON
        Kocury.pseudo = Wrogowie_kocurow.pseudo
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
    COUNT(Kocury.pseudo) > 1;

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
FROM
    Bandy
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
    NVL(przydzial_myszy, 0) >= 3 * (
        SELECT
            NVL(przydzial_myszy, 0)
        FROM
            Kocury JOIN Bandy
            ON
                Kocury.nr_bandy = Bandy.nr_bandy
        WHERE
            funkcja = 'MILUSIA' AND
            Bandy.teren IN ('SAD', 'CALOSC')
        ORDER BY
            NVL(przydzial_myszy, 0) DESC
            FETCH FIRST 1 ROW ONLY
    );


----------------------------- ZAD 26 -----------------------------

SELECT
    funkcja,
    CEIL(AVG(przydzial_myszy + NVL(myszy_extra, 0))) AS "Srednio najw. i najm. myszy"
FROM
    Kocury
WHERE
    funkcja != 'SZEFUNIO'
GROUP BY
    funkcja
HAVING
    CEIL(AVG(przydzial_myszy + NVL(myszy_extra, 0))) = (
    SELECT MIN(AVG_MYSZY) FROM (
    SELECT CEIL(AVG(przydzial_myszy + NVL(myszy_extra, 0))) AS AVG_MYSZY
    FROM Kocury
    WHERE funkcja != 'SZEFUNIO'
    GROUP BY funkcja
    )
    )
    OR CEIL(AVG(przydzial_myszy + NVL(myszy_extra, 0))) = (
    SELECT MAX(AVG_MYSZY) FROM (
    SELECT CEIL(AVG(przydzial_myszy + NVL(myszy_extra, 0))) AS AVG_MYSZY
    FROM Kocury
    WHERE funkcja != 'SZEFUNIO'
    GROUP BY funkcja
    )
    )
ORDER BY 2 ASC;


----------------------------- ZAD 27a -----------------------------

SELECT
    pseudo,
    przydzial_myszy + NVL(myszy_extra, 0) "ZJADA"
FROM
    Kocury K1
WHERE(
         SELECT
             COUNT(*)
         FROM
             Kocury K2
         WHERE
             K2.przydzial_myszy + NVL(K2.myszy_extra, 0) > K1.przydzial_myszy + NVL(K1.myszy_extra, 0)
     ) < &n
ORDER BY 2 DESC;

----------------------------- ZAD 27b -----------------------------
/*
SELECT
    pseudo,
    zjada "ZJADA"
FROM(
    SELECT
        pseudo,
        przydzial_myszy + NVL(myszy_extra, 0) as zjada
    FROM
        Kocury
    ORDER BY 2 DESC
)
WHERE ROWNUM <= &n;
*/
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
            ROWNUM <= &n
    );

----------------------------- ZAD 27c -----------------------------

SELECT
    K1.pseudo,
    MAX(K1.przydzial_myszy + NVL(K1.myszy_extra, 0)) "ZJADA"
FROM
    Kocury K1 LEFT JOIN
    Kocury K2 ON
        K1.przydzial_myszy + NVL(K1.myszy_extra, 0) < K2.przydzial_myszy + NVL(K2.myszy_extra, 0)
GROUP BY
    K1.pseudo
HAVING
    COUNT(*) < &n
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
        ) ranking
         FROM
             Kocury
     )
WHERE ranking <= &n;


----------------------------- ZAD 28 -----------------------------

-- CTE
-- COMMON TABLE EXPRESSION != VIEW
-- (it is temporary)
WITH
    YearData AS (
        SELECT
            EXTRACT(YEAR FROM w_stadku_od) AS YEAR,
    COUNT(EXTRACT(YEAR FROM w_stadku_od)) AS SUM
FROM Kocury
GROUP BY EXTRACT(YEAR FROM w_stadku_od)
    ),
    AvgData AS (
SELECT AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od))) AS AVG
FROM Kocury
GROUP BY EXTRACT(YEAR FROM w_stadku_od)
    ),
    DiffData AS (
SELECT
    year_data.YEAR,
    year_data.SUM,
    avg_data.AVG,
    ABS(year_data.SUM - avg_data.AVG) AS DIFF,
    CASE
    WHEN year_data.SUM < avg_data.AVG THEN 'lower'
    ELSE 'higher'
    END AS diff_side
FROM YearData year_data
    CROSS JOIN AvgData avg_data
    ),
    MinDiffLower AS (
SELECT MIN(DIFF) AS MIN_DIFF
FROM DiffData
WHERE diff_side = 'lower'
    ),
    MinDiffHigher AS (
SELECT MIN(DIFF) AS MIN_DIFF
FROM DiffData
WHERE diff_side = 'higher'
    )

SELECT
    TO_CHAR(diff_data.YEAR) AS "ROK",
    diff_data.SUM AS "LICZBA WSTAPIEN"
FROM DiffData diff_data
WHERE
    diff_data.DIFF = (SELECT MIN_DIFF FROM MinDiffLower) OR
    diff_data.DIFF = (SELECT MIN_DIFF FROM MinDiffHigher)

UNION

SELECT
    'Srednia',
    ROUND(AVG(year_data.SUM), 7) AS "AVG"
FROM YearData year_data
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
    K1.nr_bandy,
    TO_CHAR(AVG, '99.99') "SREDNIA BANDY"
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
    TO_CHAR((
                SELECT
                    AVG(przydzial_myszy + NVL(myszy_extra, 0)) "AVG"
                FROM
                    Kocury K
                WHERE
                    Kocury.nr_bandy = K.nr_bandy), '99.99'
    ) "SREDNIA BANDY"
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
             w_stadku_od,
             nazwa,
             MIN(w_stadku_od) OVER (PARTITION BY Kocury.nr_bandy) minstaz
         FROM
             Kocury
                 JOIN Bandy ON
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
             w_stadku_od,
             nazwa,
             MAX(w_stadku_od) OVER (PARTITION BY Kocury.nr_bandy) maxstaz
         FROM
             Kocury
                 JOIN Bandy ON
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
             w_stadku_od,
             nazwa,
             MIN(w_stadku_od) OVER (PARTITION BY Kocury.nr_bandy) minstaz,
                 MAX(w_stadku_od) OVER (PARTITION BY Kocury.nr_bandy) maxstaz
         FROM
             Kocury
                 JOIN Bandy ON
                 Kocury.nr_bandy = Bandy.nr_bandy
     )
WHERE
    w_stadku_od != minstaz AND
    w_stadku_od != maxstaz
ORDER BY 1;

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
    pseudo = UPPER(&name);

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

SELECT
    b.nazwa AS "NAZWA BANDY",
    CASE
        WHEN k.plec = 'M' THEN 'Kocur'
        WHEN k.plec = 'D' THEN ' Kotka'
        END AS "PLEC",
    NVL(TO_CHAR(COUNT(k.pseudo)), ' ') AS "ILE",
    NVL(TO_CHAR(SUM(DECODE(k.funkcja, 'SZEFUNIO',  k.przydzial_myszy + NVL(k.myszy_extra, 0), 0))), ' ') AS "SZEFUNIO",
    NVL(TO_CHAR(SUM(DECODE(k.funkcja, 'BANDZIOR',  k.przydzial_myszy + NVL(k.myszy_extra, 0), 0))), ' ') AS "BANDZIOR",
    NVL(TO_CHAR(SUM(DECODE(k.funkcja, 'LOWCZY',  k.przydzial_myszy + NVL(k.myszy_extra, 0), 0))), ' ') AS "LOWCZY",
    NVL(TO_CHAR(SUM(DECODE(k.funkcja, 'LAPACZ',  k.przydzial_myszy + NVL(k.myszy_extra, 0), 0))), ' ') AS "LAPACZ",
    NVL(TO_CHAR(SUM(DECODE(k.funkcja, 'KOT',  k.przydzial_myszy + NVL(k.myszy_extra, 0), 0))), ' ') AS "KOT",
    NVL(TO_CHAR(SUM(DECODE(k.funkcja, 'MILUSIA',  k.przydzial_myszy + NVL(k.myszy_extra, 0), 0))), ' ') AS "MILUSIA",
    NVL(TO_CHAR(SUM(DECODE(k.funkcja, 'DZIELCZY',  k.przydzial_myszy + NVL(k.myszy_extra, 0), 0))), ' ') AS "DZIELCZY",
    NVL(TO_CHAR(SUM(k.przydzial_myszy + NVL(k.myszy_extra, 0))), ' ') AS "SUMA"
FROM
    Kocury k
        JOIN
    Bandy b ON k.nr_bandy = b.nr_bandy
GROUP BY
    b.nazwa, k.plec

UNION ALL

SELECT
    'Z--------------' AS "NAZWA BANDY",
    '------' AS "PLEC",
    '--------' AS "ILE",
    '---------' AS "SZEFUNIO",
    '---------' AS "BANDZIOR",
    '--------' AS "LOWCZY",
    '--------' AS "LAPACZ",
    '--------' AS "KOT",
    '--------' AS "MILUSIA",
    '--------' AS "DZIELCZY",
    '--------' AS "SUMA"
FROM
    dual

UNION ALL

SELECT
    'ZJADA RAZEM' AS "NAZWA BANDY",
    ' ' AS "PLEC", -- Pusty string zamiast NULL
    ' ' AS "ILE",  -- Pusty string zamiast NULL
    NVL(TO_CHAR(SUM(DECODE(k.funkcja, 'SZEFUNIO',  k.przydzial_myszy + NVL(k.myszy_extra, 0), 0))), ' ') AS "SZEFUNIO",
    NVL(TO_CHAR(SUM(DECODE(k.funkcja, 'BANDZIOR',  k.przydzial_myszy + NVL(k.myszy_extra, 0), 0))), ' ') AS "BANDZIOR",
    NVL(TO_CHAR(SUM(DECODE(k.funkcja, 'LOWCZY',  k.przydzial_myszy + NVL(k.myszy_extra, 0), 0))), ' ') AS "LOWCZY",
    NVL(TO_CHAR(SUM(DECODE(k.funkcja, 'LAPACZ',  k.przydzial_myszy + NVL(k.myszy_extra, 0), 0))), ' ') AS "LAPACZ",
    NVL(TO_CHAR(SUM(DECODE(k.funkcja, 'KOT',  k.przydzial_myszy + NVL(k.myszy_extra, 0), 0))), ' ') AS "KOT",
    NVL(TO_CHAR(SUM(DECODE(k.funkcja, 'MILUSIA',  k.przydzial_myszy + NVL(k.myszy_extra, 0), 0))), ' ') AS "MILUSIA",
    NVL(TO_CHAR(SUM(DECODE(k.funkcja, 'DZIELCZY',  k.przydzial_myszy + NVL(k.myszy_extra, 0), 0))), ' ') AS "DZIELCZY",
    NVL(TO_CHAR(SUM(k.przydzial_myszy + NVL(k.myszy_extra, 0))), ' ') AS "SUMA"
FROM
    Kocury k
        JOIN
    Bandy b ON k.nr_bandy = b.nr_bandy
ORDER BY
    "NAZWA BANDY", "PLEC";

----------------------------- ZAD 33b -----------------------------

SELECT *
FROM (
         SELECT
             TO_CHAR(nazwa) "NAZWA BANDY",
             TO_CHAR(DECODE(plec, 'D', ' Kotka', 'Kocur')) AS "PLEC",
             TO_CHAR(ile) AS "ILE",
             TO_CHAR(NVL(szefunio, 0)) AS "SZEFUNIO",
             TO_CHAR(NVL(bandzior, 0)) AS "BANDZIOR",
             TO_CHAR(NVL(lowczy, 0)) AS "LOWCZY",
             TO_CHAR(NVL(lapacz, 0)) AS "LAPACZ",
             TO_CHAR(NVL(kot, 0)) AS "KOT",
             TO_CHAR(NVL(milusia, 0)) AS "MILUSIA",
             TO_CHAR(NVL(dzielczy, 0)) AS "DZIELCZY",
             TO_CHAR(NVL(suma, 0)) AS "SUMA"
         FROM (
                  SELECT
                      b.nazwa,
                      k.plec,
                      k.funkcja,
                      (k.przydzial_myszy + NVL(k.myszy_extra, 0)) AS liczba
                  FROM
                      Kocury k
                          JOIN
                      Bandy b
                      ON
                          k.nr_bandy = b.nr_bandy
              ) PIVOT (
                       SUM(liczba) FOR funkcja IN (
            'SZEFUNIO' AS szefunio, 'BANDZIOR' AS bandzior, 'LOWCZY' AS lowczy,
            'LAPACZ' AS lapacz, 'KOT' AS kot, 'MILUSIA' AS milusia, 'DZIELCZY' AS dzielczy
        )
             )
                  JOIN (
             SELECT
                 b.nazwa AS "N",
                 k.plec AS "P",
                 COUNT(k.pseudo) AS ile,
                 SUM(k.przydzial_myszy + NVL(k.myszy_extra, 0)) AS suma
             FROM
                 Kocury k
                     JOIN
                 Bandy b
                 ON
                     k.nr_bandy = b.nr_bandy
             GROUP BY
                 b.nazwa, k.plec
             ORDER BY
                 b.nazwa
         ) summary
                       ON
                           summary.N = nazwa AND summary.P = plec
     )

UNION

SELECT
    'Z--------------', '------', '--------', '---------', '---------',
    '--------', '--------', '--------', '--------', '--------', '--------'
FROM
    DUAL

UNION

SELECT
    'ZJADA RAZEM', ' ', ' ', TO_CHAR(NVL(szefunio, 0)) AS szefunio,
    TO_CHAR(NVL(bandzior, 0)) AS bandzior, TO_CHAR(NVL(lowczy, 0)) AS lowczy,
    TO_CHAR(NVL(lapacz, 0)) AS lapacz, TO_CHAR(NVL(kot, 0)) AS kot,
    TO_CHAR(NVL(milusia, 0)) AS milusia, TO_CHAR(NVL(dzielczy, 0)) AS dzielczy,
    TO_CHAR(NVL(suma, 0)) AS suma
FROM (
         SELECT
             k.funkcja,
             (k.przydzial_myszy + NVL(k.myszy_extra, 0)) AS liczba
         FROM
             Kocury k
                 JOIN
             Bandy b
             ON
                 k.nr_bandy = b.nr_bandy
     )
         PIVOT (
                SUM(liczba) FOR funkcja IN (
        'SZEFUNIO' AS szefunio, 'BANDZIOR' AS bandzior, 'LOWCZY' AS lowczy,
        'LAPACZ' AS lapacz, 'KOT' AS kot, 'MILUSIA' AS milusia, 'DZIELCZY' AS dzielczy
    )
        )
         CROSS JOIN (
    SELECT
        SUM(k.przydzial_myszy + NVL(k.myszy_extra, 0)) AS suma
    FROM
        Kocury k
);

