kartkowka za tydzien (bayes + metody grupowania)
za tydzien czyli chodzi o 6 maj bodajże


# Wykład 6 - Metody grupowanie (inaczej klasteryzacja)

kryteria podziału:
- homogeniczność w grupach
- heterogeniczność pomiędzy grupami

zastosowania:
- redukcja do kilku pierwotnych kategorii
- odkrycie nieznanej struktury analizowanych danych
- podział klientów na grupy dla zadań rekomendacji

miara miejska: x+y
miara euklidesowa: sqrt(x^2+y^2)

// funkcja odległości Jaccarda (dla danych binarnych)
d(x, y) = 1 - (część wspólna / część łączna)
d(x, y) = 1 - (|x ∩ y| / |x ∪ y|)


funkcja oceny jakości grupowania:
- suma błędów kwadratowych (suma odległości punktów od centroidu we wszystkich klasach)

działanie k means:
1. wybieramy k punktów jako centroidy (losowo lub na podstawie danych)
2. przypisujemy każdy punkt do najbliższego centroidu (tworząc grupy)
3. aktualizujemy położenie k punktów, obliczając dla nich nowy centroid (średnia punktów w grupie)
4. powtarzamy kroki 2 i 3, aż centroidy przestaną się zmieniać lub osiągniemy maksymalną liczbę iteracji


ZADANIE:
dokonać grupowania dla danych metodą k-średnich
- dane są punkty w przestrzeni jednowymiarowej: 2, 5, 6, 8, 9
- k = 2
- początkowe centroidy: 2 i 9
- jako odległość proszę przyjąć odległość euklidesową dla wektorów jednowymiarowych (czyli po prostu wartość bezwzględną różnicy)
- w trakcie obliczenia centroidów [...]

iteracja 1:

elementy | 2 | 5 | 6 | 8 | 9
---------|---|---|---|---|---
c1 = 2   | 0 | 3 | 4 | 6 | 7
c2 = 9   | 7 | 4 | 3 | 1 | 0
decyzja  | c1| c1| c1| c2| c2

iteracja 2:
(zaokrąglamy w dół do pełnych int)
elementy | 2 | 5 | 6 | 8 | 9
---------|---|---|---|---|---
c1 = (2+5)/2 = 3| 2.33 | 0.33 | 2.67 | 4.67
c2 = (8+9)/2 = 8 | 6.5 | 2.5 | 0.5 | 0
decyzja  | c1| c1| c1| c2| c2


zad 2:
- punkty w przestrzeni jednowymiarowej: 2, 3, 6, 8, 9, 12, 15, 18, 22
- k = 2
- początkowe centroidy: 2 i 3
- używamy części całkowitej

iteracja 1:

elementy | 2 | 3 | 6 | 8 | 9 | 12 | 15 | 18 | 22
---------|---|---|---|---|---|----|----|----|----
c1 = 2   | 0 | 1 | 4 | 6 | 7 | 10 | 13 | 16 | 20
c2 = 3   | 1 | 0 | 3 | 5 | 6 | 9  | 12 | 15 | 19
decyzja  | c1| c1| c2| c2| c2| c2 | c2 | c2 | c2

iteracja 2:

elementy | 2 | 3 | 6 | 8 | 9 | 12 | 15 | 18 | 22
---------|---|---|---|---|---|----|----|----|----
c1 = (2+3)/2 = 2| 0 | 1 | 4 | 6 | 7 | 10 | 13 | 16 | 20
c2 = (6+8+9+12+15+18+22)/7 = 12 | 10 | 9 | 6 | 4 | 3 | 0 | 3 | 6 | 10
decyzja  | c1| c1| c1 | c2| c2| c2 | c2 | c2 | c2 | c2

iteracja 3:
elementy | 2 | 3 | 6 | 8 | 9 | 12 | 15 | 18 | 22
---------|---|---|---|---|---|----|----|----|----
c1 = (2+3+6)/3 = 3| 1 | 0 | 3 | 5 | 6 | 9  | 12 | 15 | 19
c2 = (8+9+12+15+18+22)/6 = 14 | 12 | 11 | 8 | 6 | 5 | 2 | 1 | 4 | 8
decyzja  | c1 | c1 | c1 | c1 | c2 | c2 | c2 | c2 | c2 | c2

iteracja 4:
elementy | 2 | 3 | 6 | 8 | 9 | 12 | 15 | 18 | 22
---------|---|---|---|---|---|----|----|----|----
c1 = (2+3+6+8)/4 = 4| 2 | 1 | 2 | 4 | 5 | 8 | 11 | 14 | 18
c2 = (9+12+15+18+22)/5 = 15 | 13 | 12 | 9 | 7 | 6 | 3 | 0 | 3 | 7
decyzja  | c1 | c1 | c1 | c1 | c1 | c2 | c2 | c2 | c2 | c2

iteracja 5:
elementy | 2 | 3 | 6 | 8 | 9 | 12 | 15 | 18 | 22
---------|---|---|---|---|---|----|----|----|----
c1 = (2+3+6+8+9)/5 = 5| 3 | 2 | 1 | 3 | 4 | 7 | 10 | 13 | 17
c2 = (12+15+18+22)/4 = 16 | 14 | 13 | 10 | 8 | 5 | 2 | 0 | 4 | 8
decyzja  | c1 | c1 | c1 | c1 | c1 | c2 | c2 | c2 | c2 | c2
