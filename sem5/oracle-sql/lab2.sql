-- Lab 17
SELECT pseudo, przydzial_myszy, nazwa
FROM Kocury JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
WHERE (teren = 'CALOSC'
      OR teren = 'POLE')
      AND przydzial_myszy > 50;

-- Lab 18
SELECT Q1.imie, TO_CHAR(Q1.w_stadku_od, 'yyyy-mm-dd') "Poluje od"
FROM Kocury Q1 JOIN Kocury Q2 ON Q2.imie = 'JACEK'
WHERE Q1.w_stadku_od < Q2.w_stadku_od
ORDER BY Q1.w_stadku_od DESC;

-- Lab 19a
SELECT Q1.imie, Q1.funkcja, Q2.imie, Q3.imie, Q4.imie
  FROM Kocury Q1 LEFT JOIN
    (Kocury Q2 LEFT JOIN
      (Kocury Q3 LEFT JOIN Kocury Q4
          ON Q3.szef = Q4.pseudo)
        ON Q2.szef = Q3.pseudo)
      ON Q1.szef = Q2.pseudo
WHERE Q1.funkcja = 'KOT'
  OR Q1.funkcja = 'MILUSIA';

-- Lab 19b
SELECT *
FROM
(
  SELECT CONNECT_BY_ROOT imie "Imie", imie, CONNECT_BY_ROOT funkcja "funkcja", LEVEL "L"
  FROM Kocury
  CONNECT BY PRIOR szef = pseudo
  START WITH funkcja IN ('KOT', 'MILUSIA')
) PIVOT (
   MIN(imie) FOR L IN (2 szef1, 3 szef2, 4 szef3)
);

-- Lab 19c
SELECT imie, funkcja, RTRIM(REVERSE(RTRIM(SYS_CONNECT_BY_PATH(REVERSE(imie), ' | '), imie)), '| ') "IMIONA KOLEJNYCH SZEFÓW"
FROM Kocury
WHERE funkcja = 'KOT'
      OR funkcja = 'MILUSIA'
CONNECT BY PRIOR pseudo = szef
START WITH szef IS NULL;

-- Lab 20
SELECT Kocury.imie, Bandy.nazwa, Wrogowie.imie_wroga,
  Wrogowie.stopien_wrogosci, Wrogowie_kocurow.data_incydentu
FROM
    Wrogowie JOIN
      Wrogowie_kocurow JOIN
      (Kocury JOIN BANDY
        ON Kocury.nr_bandy = Bandy.nr_bandy)
      ON Wrogowie_kocurow.pseudo = Kocury.pseudo
    ON Wrogowie.imie_wroga = Wrogowie_kocurow.imie_wroga
WHERE Kocury.plec = 'D'
      AND Wrogowie_kocurow.DATA_INCYDENTU > TO_DATE('2007-01-01');

-- Lab 21
SELECT Bandy.nazwa, COUNT(Q1.pseudo)
FROM Bandy JOIN
  (SELECT DISTINCT Kocury.pseudo, Kocury.nr_bandy
    FROM (Kocury JOIN Wrogowie_kocurow
         ON Kocury.pseudo = Wrogowie_kocurow.pseudo)
  ) Q1 ON Q1.nr_bandy= Bandy.nr_bandy
GROUP BY Bandy.nazwa;

-- Lab 22
SELECT funkcja, Kocury.pseudo, COUNT(Kocury.pseudo)
FROM Kocury JOIN Wrogowie_kocurow
    ON Kocury.pseudo = Wrogowie_kocurow.pseudo
GROUP BY Kocury.pseudo, funkcja
HAVING COUNT(Kocury.pseudo) >= 2;

-- Lab 23
SELECT imie, 12 * (przydzial_myszy + NVL(myszy_extra, 0)), 'ponizej 864'
FROM Kocury
WHERE myszy_extra IS NOT NULL
      AND 12 * (przydzial_myszy + NVL(myszy_extra, 0)) < 864

UNION ALL

SELECT imie, 12 * (przydzial_myszy + NVL(myszy_extra, 0)), '864'
FROM Kocury
WHERE myszy_extra IS NOT NULL
      AND 12 * (przydzial_myszy + NVL(myszy_extra, 0)) = 864

UNION ALL

SELECT imie, 12 * (przydzial_myszy + NVL(myszy_extra, 0)), 'powyzej 864'
FROM Kocury
WHERE myszy_extra IS NOT NULL
      AND 12 * (przydzial_myszy + NVL(myszy_extra, 0)) > 864
ORDER BY 2 DESC;

-- Lab 24
SELECT Bandy.nr_bandy, nazwa, teren
FROM Bandy LEFT JOIN Kocury
  ON Bandy.nr_bandy = Kocury.nr_bandy
WHERE imie IS NULL;

SELECT Bandy.nr_bandy, nazwa, teren
FROM Bandy

MINUS

SELECT DISTINCT Kocury.nr_bandy, Bandy.nazwa, Bandy.teren
FROM Bandy LEFT JOIN Kocury
    ON Bandy.nr_bandy = Kocury.nr_bandy;


-- Lab 25
SELECT imie, pseudo, funkcja, NVL(przydzial_myszy, 0)
FROM Kocury
WHERE NVL(przydzial_myszy, 0) >= ALL (SELECT 3 * NVL(przydzial_myszy, 0)
                                     FROM Kocury JOIN Bandy
                                         ON Kocury.nr_bandy= Bandy.nr_bandy
                                     WHERE funkcja = 'MILUSIA'
                                           AND Bandy.teren IN ('SAD', 'CALOSC'));

-- Lab 26
SELECT K2.funkcja, K2.AVG
FROM
  (SELECT MIN(AVG) "MINAVG", MAX(AVG) "MAXAVG"
  FROM (
    SELECT funkcja, CEIL(AVG(przydzial_myszy + NVL(myszy_extra, 0))) "AVG"
    FROM Kocury
    WHERE funkcja != 'SZEFUNIO'
    GROUP BY funkcja
  )) K1

  JOIN

  (SELECT funkcja, CEIL(AVG(przydzial_myszy + NVL(myszy_extra, 0))) "AVG"
  FROM Kocury
  WHERE funkcja != 'SZEFUNIO'
  GROUP BY funkcja) K2

  ON K1.MINAVG = K2.AVG
     OR K1.MAXAVG = K2.AVG
ORDER BY K2.AVG;

--Lab 27a
SELECT pseudo, przydzial_myszy + NVL(myszy_extra, 0) "ZJADA"
FROM Kocury K
WHERE (SELECT COUNT(DISTINCT przydzial_myszy + NVL(myszy_extra, 0)) FROM Kocury
      WHERE przydzial_myszy + NVL(myszy_extra, 0) > K.przydzial_myszy + NVL(K.myszy_extra, 0)) < 12
ORDER BY 2 DESC;

--Lab 27b
SELECT pseudo, przydzial_myszy + NVL(myszy_extra, 0) "ZJADA"
FROM Kocury
WHERE przydzial_myszy + NVL(myszy_extra, 0) IN (
  SELECT *
  FROM (
    SELECT DISTINCT przydzial_myszy + NVL(myszy_extra, 0)
    FROM Kocury
    ORDER BY 1 DESC
  ) WHERE ROWNUM <= 12

);

--Lab 27c
SELECT K1.pseudo, AVG(K1.przydzial_myszy + NVL(K1.myszy_extra, 0)) "ZJADA"
FROM Kocury K1 LEFT JOIN Kocury K2
    ON K1.przydzial_myszy + NVL(K1.myszy_extra, 0) < K2.przydzial_myszy + NVL(K2.myszy_extra, 0)
GROUP BY K1.pseudo
HAVING COUNT(K2.pseudo) <= 12
ORDER BY 2 DESC;

--Lab 27d
SELECT  pseudo, ZJADA
FROM
(
  SELECT  pseudo,
    NVL(przydzial_myszy, 0) + NVL(myszy_extra, 0) "ZJADA",
    DENSE_RANK() OVER (
      ORDER BY przydzial_myszy + NVL(myszy_extra, 0) DESC
    ) RANK
  FROM Kocury
)
WHERE RANK <= 6;


-- Lab 28
SELECT TO_CHAR(YEAR), SUM
FROM
(
  SELECT YEAR, SUM, ABS(SUM-AVG) "DIFF"
  FROM
    (
      SELECT EXTRACT(YEAR FROM w_stadku_od) "YEAR", COUNT(EXTRACT(YEAR FROM w_stadku_od)) "SUM"
      FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
    ) JOIN (
      SELECT AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od))) "AVG"
      FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
    ) ON SUM < AVG
)
WHERE DIFF < ALL
(
  SELECT MAX(ABS(SUM-AVG)) "DIFF"
  FROM
    (
      SELECT EXTRACT(YEAR FROM w_stadku_od) "YEAR", COUNT(EXTRACT(YEAR FROM w_stadku_od)) "SUM"
      FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
    ) JOIN (
      SELECT AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od))) "AVG"
      FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
    ) ON SUM < AVG
)

UNION ALL

SELECT 'Srednia', ROUND(AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od))), 7) "AVG"
FROM Kocury
GROUP BY EXTRACT(YEAR FROM w_stadku_od)

UNION ALL

SELECT TO_CHAR(YEAR), SUM
FROM
(
  SELECT YEAR, SUM, ABS(SUM-AVG) "DIFF"
  FROM
    (
      SELECT EXTRACT(YEAR FROM w_stadku_od) "YEAR", COUNT(EXTRACT(YEAR FROM w_stadku_od)) "SUM"
      FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
    ) JOIN (
      SELECT AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od))) "AVG"
      FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
    ) ON SUM > AVG
)
WHERE DIFF < ALL
(
  SELECT MAX(ABS(SUM-AVG)) "DIFF"
  FROM
    (
      SELECT EXTRACT(YEAR FROM w_stadku_od) "YEAR", COUNT(EXTRACT(YEAR FROM w_stadku_od)) "SUM"
      FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
    ) JOIN  (
      SELECT AVG(COUNT(EXTRACT(YEAR FROM w_stadku_od))) "AVG"
      FROM Kocury
      GROUP BY EXTRACT(YEAR FROM w_stadku_od)
    ) ON SUM > AVG
);

--Lab 29a
SELECT K1.imie, MIN(K1.przydzial_myszy + NVL(K1.myszy_extra, 0)) "ZJADA", K1.nr_bandy, TO_CHAR(AVG(K2.przydzial_myszy + NVL(K2.myszy_extra, 0)), '99.99') "SREDNIA BANDY"
FROM Kocury K1 JOIN Kocury K2 ON K1.nr_bandy= K2.nr_bandy
WHERE K1.PLEC = 'M'
GROUP BY K1.imie, K1.nr_bandy
HAVING MIN(K1.przydzial_myszy + NVL(K1.myszy_extra, 0)) < AVG(K2.przydzial_myszy + NVL(K2.myszy_extra, 0));

--Lab 29b
SELECT imie, przydzial_myszy + NVL(myszy_extra, 0) "ZJADA", K1.nr_bandy, TO_CHAR(AVG, '99.99') "SREDNIA BANDY"
FROM Kocury K1 JOIN (SELECT nr_bandy, AVG(przydzial_myszy + NVL(myszy_extra, 0)) "AVG" FROM Kocury GROUP BY nr_bandy) K2
    ON K1.nr_bandy= K2.nr_bandy
       AND przydzial_myszy + NVL(myszy_extra, 0) < AVG
WHERE PLEC = 'M';

--Lab 29c
SELECT imie, przydzial_myszy + NVL(myszy_extra, 0) "ZJADA", nr_bandy,
  TO_CHAR((SELECT AVG(przydzial_myszy + NVL(myszy_extra, 0)) "AVG" FROM Kocury K WHERE Kocury.nr_bandy = K.nr_bandy), '99.99') "SREDNIA BANDY"
FROM Kocury
WHERE PLEC = 'M'
      AND przydzial_myszy + NVL(myszy_extra, 0) < (SELECT AVG(przydzial_myszy + NVL(myszy_extra, 0)) "AVG" FROM Kocury K WHERE Kocury.nr_bandy= K.nr_bandy);

-- Lab 30
SELECT imie, TO_CHAR(w_stadku_od, 'YYYY-MM-DD') || ' <--- NAJSTARSZY STAZEM W BANDZIE ' || nazwa "WSTAPIL DO STADKA"
FROM (
  SELECT imie, w_stadku_od, nazwa, MIN(w_stadku_od) OVER (PARTITION BY Kocury.nr_bandy) minstaz
  FROM Kocury JOIN Bandy ON Kocury.nr_bandy= Bandy.nr_bandy
)
WHERE w_stadku_od = minstaz

UNION ALL

SELECT imie, TO_CHAR(w_stadku_od, 'YYYY-MM-DD') || ' <--- NAJMLODSZY STAZEM W BANDZIE ' || nazwa "WSTAPIL DO STADKA"
FROM (
  SELECT imie, w_stadku_od, nazwa, MAX(w_stadku_od) OVER (PARTITION BY Kocury.nr_bandy) maxstaz
  FROM Kocury JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
)
WHERE w_stadku_od = maxstaz

UNION ALL

SELECT imie, TO_CHAR(w_stadku_od, 'YYYY-MM-DD')
FROM (
  SELECT imie, w_stadku_od, nazwa,
    MIN(w_stadku_od) OVER (PARTITION BY Kocury.nr_bandy) minstaz,
    MAX(w_stadku_od) OVER (PARTITION BY Kocury.nr_bandy) maxstaz
  FROM Kocury JOIN Bandy ON Kocury.nr_bandy= Bandy.nr_bandy
)
WHERE W_STADKU_OD != minstaz AND
      W_STADKU_OD != maxstaz
ORDER BY IMIE;

-- Lab 31
CREATE OR REPLACE VIEW Statystyki(nazwa_bandy, sre_spoz, max_spoz, min_spoz, koty, koty_z_dod)
AS
SELECT nazwa, AVG(przydzial_myszy), MAX(przydzial_myszy), MIN(przydzial_myszy), COUNT(pseudo), COUNT(myszy_extra)
FROM Kocury JOIN Bandy ON Kocury.nr_bandy= Bandy.nr_bandy
GROUP BY nazwa;

SELECT *
FROM Statystyki;

SELECT pseudo "PSEUDONIM", imie, funkcja, przydzial_myszy "ZJADA", 'OD ' || min_spoz || ' DO ' || max_spoz "GRANICE SPOZYCIA", TO_CHAR(w_stadku_od, 'YYYY-MM-DD') "LOWI OD"
FROM (Kocury JOIN Bandy ON Kocury.nr_bandy= Bandy.nr_bandy JOIN Statystyki  ON Bandy.nazwa = Statystyki.nazwa_bandy)
WHERE pseudo = UPPER(?);

-- Lab 32
CREATE OR REPLACE VIEW StaraGwardia(pseudo, plec, przydzial_myszy, myszy_extra, nr_bandy)
AS
SELECT pseudo, plec, przydzial_myszy, myszy_extra, nr_bandy
FROM Kocury
WHERE pseudo IN
(
  SELECT pseudo
  FROM Kocury JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy
  WHERE nazwa = 'CZARNI RYCERZE'
  ORDER BY w_stadku_od
  FETCH NEXT 3 ROWS ONLY
)
OR pseudo IN
(
  SELECT pseudo
  FROM Kocury JOIN Bandy ON Kocury.nr_bandy= Bandy.nr_bandy
  WHERE nazwa = 'LACIACI MYSLIWI'
  ORDER BY w_stadku_od
  FETCH NEXT 3 ROWS ONLY
);

SELECT pseudo, plec, przydzial_myszy "Myszy przed podw.", NVL(myszy_extra, 0) "Ekstra przed podw."
FROM StaraGwardia;

UPDATE StaraGwardia
SET przydzial_myszy = przydzial_myszy + DECODE(plec, 'D', 0.1 * (SELECT MIN(przydzial_myszy) FROM Kocury), 10),
    myszy_extra = NVL(myszy_extra, 0) + 0.15 * (SELECT AVG(NVl(myszy_extra, 0)) FROM Kocury WHERE StaraGwardia.nr_bandy = nr_bandy);

SELECT pseudo, plec, przydzial_myszy "Myszy po podw.", NVL(myszy_extra, 0) "Ekstra po podw."
FROM StaraGwardia;

ROLLBACK;

-- Lab 33a
SELECT *
FROM
(
SELECT TO_CHAR(DECODE(plec, 'D', nazwa, ' ')) "NAZWA BANDY",
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
FROM (Kocury JOIN Bandy ON Kocury.nr_bandy = Bandy.nr_bandy)
GROUP BY nazwa, plec, Kocury.nr_bandy
ORDER BY nazwa
)

UNION ALL

SELECT 'Z--------------', '------', '--------', '---------', '---------', '--------', '--------', '--------', '--------', '--------', '--------' FROM DUAL

UNION ALL

SELECT DISTINCT 'ZJADA RAZEM',
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
FROM (Kocury JOIN Bandy ON Kocury.nr_bandy= Bandy.nr_bandy);

-- Lab 33b
SELECT *
FROM
(
  SELECT TO_CHAR(DECODE(plec, 'D', nazwa, ' ')) "NAZWA BANDY",
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
  FROM
  (
    SELECT nazwa, plec, funkcja, przydzial_myszy + NVL(myszy_extra, 0) liczba
    FROM Kocury JOIN Bandy ON Kocury.nr_bandy= Bandy.nr_bandy
  ) PIVOT (
      SUM(liczba) FOR funkcja IN (
      'SZEFUNIO' szefunio, 'BANDZIOR' bandzior, 'LOWCZY' lowczy, 'LAPACZ' lapacz,
      'KOT' kot, 'MILUSIA' milusia, 'DZIELCZY' dzielczy
    )
  ) JOIN (
    SELECT nazwa "N", plec "P", COUNT(pseudo) ile, SUM(przydzial_myszy + NVL(myszy_extra, 0)) suma
    FROM Kocury K JOIN Bandy B ON K.nr_bandy= B.nr_bandy
    GROUP BY nazwa, plec
    ORDER BY nazwa
  ) ON N = nazwa AND P = plec
)


UNION ALL

SELECT 'Z--------------', '------', '--------', '---------', '---------', '--------', '--------', '--------', '--------', '--------', '--------' FROM DUAL

UNION ALL

SELECT  'ZJADA RAZEM',
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
FROM
(
  SELECT      funkcja, przydzial_myszy + NVL(myszy_extra, 0) liczba
  FROM        Kocury JOIN Bandy ON Kocury.nr_bandy= Bandy.nr_bandy
) PIVOT (
    SUM(liczba) FOR funkcja IN (
    'SZEFUNIO' szefunio, 'BANDZIOR' bandzior, 'LOWCZY' lowczy, 'LAPACZ' lapacz,
    'KOT' kot, 'MILUSIA' milusia, 'DZIELCZY' dzielczy
  )
) CROSS JOIN (
  SELECT      SUM(przydzial_myszy + NVL(myszy_extra, 0)) suma
  FROM        Kocury
);