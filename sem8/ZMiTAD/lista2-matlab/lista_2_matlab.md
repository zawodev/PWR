# Testowanie hipotez statystycznych
wstęp

## Hipoteza zerowa i alternatywna

Hipotezą statystyczną jest dowolne przypuszczenie co do rozkładu populacji generalnej (jego
postaci funkcyjnej lub wartości parametrów). Prawdziwość tego przypuszczenia jest ocenia-
na na podstawie wyników próby losowej.

Testem statystycznym nazywamy regułę postępowania, która każdej możliwej próbie przypo-
rządkowuje decyzję przyjęcia lub odrzucenia hipotezy. Oznacza to, że test statystyczny jest
regułą rozstrzygającą, jakie wyniki próby pozwalają uznać sprawdzaną hipotezę za prawdzi-
wą, a jakie – za fałszywą.

Testy statystyczne dzielimy zasadniczo na:

•  parametryczne, czyli dotyczące wartości parametrów statystycznych populacji, takich

jak np. średnia,

•  nieparametryczne, czyli dotyczące postaci rozkładu zmiennej lub losowości próby.

Hipotezę, która podlega weryfikacji nazywamy hipotezą zerową, a jej przeciwieństwo - hipo-
tezą alternatywną.

Każdy test statystyczny rozpoczynamy od sformułowania hipotezy zerowej H0, czyli hipotezy
podlegającej sprawdzeniu, oraz hipotezy konkurencyjnej H1, którą jesteśmy w stanie przyjąć,
gdy odrzucimy hipotezę zerową. Ponadto musimy określić poziom istotności α, czyli maksy-
malne ryzyko błędu, jakie badacz jest skłonny zaakceptować.

Następnie  wybieramy  odpowiednią  statystykę  testową  (wybór  statystyki  uzależniony  od  in-
formacja jaką posiadamy o próbie oraz od postaci hipotezy zerowej i alternatywnej) oraz ob-
liczamy  wartość  tej  funkcji  dla  badanej  próby.  Jeśli  prawdopodobieństwo  osiągnięcia  otrzy-
manej bądź jeszcze bardziej ekstremalnej wartości statystyki jest niskie to wątpimy, że nasze
dane są zgodne z hipotezą zerową i jesteśmy skłonni przyjąć hipotezę alternatywną:

•
•
•

Jeżeli p <=α ⇒ odrzucamy H0 przyjmując H1,
Jeżeli p > α ⇒ nie ma podstaw, aby odrzucić H0.
Inaczej:  jeżeli  wartość  statystyki  wpada  do  obszaru  krytycznego  to  odrzucamy  H0
przyjmując H1, w przeciwnym przypadku nie ma podstaw, aby odrzucić H0.










Uwaga: Testy statystyczne w zależności od wyniku pozwalają nam hipotezę zerową odrzu-
cić i wtedy przyjąć hipotezę konkurencyjną lub nie dają podstaw do odrzucenia H0, co nie jest
równoznaczne  z  jej  przyjęciem.  Używając  testów,  którymi  dysponuje  MATLAB,  należy
sprawdzić, jaka hipoteza przyjmowana jest w tym teście.

## Testowanie hipotez na temat średniej

Przykład 1. Każda linia komunikacji miejskiej ma określony czas przejazdu (od pętli do pętli).
Przeprowadźmy test hipotezy dla wybranej linii. Podany czas na rozkładzie wynosi 28 minut.

H0: μ=28

H1: µ≠28

Wybieramy  losową  próbę  100  przejazdów  tej  linii  i  obliczamy  średni  czas  dla  tej  próby
5,31=x
rozkładu, średnia arytmetyczna próby pobranej z populacji o rozkładzie

minuty.  i  odchylenie  standardowe  próby  s  =  5  minut.  Przy  założeniu  normalności

 ma rozkład

( sµN
,
)

. Jeśli prawdziwa jest hipoteza zerowa, to statystyka o postaci

)

N

,(
µ

s
n
)1,0(N
rozkład

.

Z

=

X

µ-
s

n

 ma

Zatem:

z

=

x

µ

-
s

n

=

28

5,31
-
5

100

7
>=

z
a

2/ =

96,1

Dlatego odrzucamy H0 na poziomie α=0,05.

Do badania hipotez dotyczących średniej służą funkcje: ttest, ttest2, tcdf, tinv. Więcej infor-
macji na temat założeń ttestu będzie można znaleźć w kolejnych listach.
[h,p] = ttest(x,m)
tcdf(t,n-1)

Ćwiczenie 1: Sprawdź powyższe rachunki korzystając z ttestu.








Wskazówka: Wylosuj próbę z rozkładu normalnego o zadanych parametrach i przeprowadź
analizę.

Ćwiczenie  2:  Chcemy  sprawdzić,  czy  czas  oczekiwania  na  dostarczenie  przesyłki  przez
pewna firmę kurierską to przeciętnie 3 dni (m = 3). W tym celu z populacji klientów tej firmy
wylosowano próbę liczącą 22 osoby i zapisano informacje o ilości dni, jakie minęły od dnia
nadania przesyłki do jej dostarczenia, były to następujące wielkości: (1, 1, 1, 2, 2, 2, 2, 3, 3,
3,  4,  4,  4,  4,  4,  5,  5,  6,  6,  6,  7,  7).  Ilość  dni  oczekiwania  na  przesyłkę  w  badanej  populacji
spełnia założenie normalności

Ćwiczenie  3:  Norma  techniczna  przewiduje  czas  montowania  elementu  w  pralce  na  6  min.
Obliczono, że w grupie 25 pracowników średni czas montowania wynosi 6 min i 20 sekund.
W zakładzie produkcyjnym stwierdzono, że wskazany czas normatywny jest za krótki. Należy
sprawdzić to przypuszczenie przy założeniu, że odchylenie standardowe wynosi 1,5 minuty.

## Testowanie hipotez na temat wariancji

Jednym z założeń testów parametrycznych (np. t-testu dla dwóch prób) jest homogeniczność
wariancji.  Homogeniczność  możemy  tutaj  rozumieć  jako  równość,  jednolitość.  Dokładniej,
porównywane  ze  sobą  grupy,  za  pomocą  testów  parametrycznych  powinny  mieć  podobne
wariancje.  Oznacza  to,  różnorodność  uzyskanych  wyników  w  poszczególnych  grupach  po-
winna być podobna. Do badania wariancji w grupie bądź w kilku grupach służą następujące
testy:

1.  Do testowania hipotez na temat wariancji używamy statystyki chi-kwadrat o n − 1

stopniach swobody (vartest(x,v)):

2
c

=

2

s

(

n -
)1
2
s
0

Gdzie s jest wariancją n-elementowej próby wylosowanej z populacji, a

2
0s

 jest war-

tością wariancji podaną w H0.

Test ten pozwala ocenić czy wariancja w próby jest równą założonej wariancji v.

2.  Do testowania równości wariancji w dwóch populacjach stosuje się test F (var-

test2(x,y)):

F
(

n
1

,1
-

n

2

=-
)1

2
s
1
2
s
2

gdzie

2
1s

 i

2
2s

populacji.

 są wariancjami próby odpowiednio o n1 i n2 elementach wylosowanymi z

3.  Przydatna może być również statystyka porównująca wariancję w większej ilości grup

np. test Barletta (vartestn(x,group)) czy test Levene’a (Levenetest(x))






Ćwiczenie 4: Chcemy sprawdzić, czy odchylenie standardowe w rozkładzie czasu montowa-
nia  elementu  w  pralce  rzeczywiście  wynosi  1,5  minuty.  Wygeneruj  25-elementową  próbę
rozkładu normalnego o średniej 6 min i 20 sekund i zadanym odchyleniu. Sprawdź też, sto-
sując  odpowiedni  test  (z  właściwie  dobranymi  parametrami),  czy  odchylenie  standardowe
wygenerowanej próby jest mniejsze niż 1,6min?

Sprawdź, czy wynik testowania zmienia się, gdy przyjmiemy poziom istotności równy 0,1?

Ćwiczenie 5: Przypuszcza się, że młodsze osoby łatwiej decydują się na zakup nowych nie-
znanych produktów. Badanie przeprowadzone wśród przypadkowych 20 nabywców nowego
produktu i 22 nabywców znanego już wyrobu pewnej firmy dostarczyło następujących infor-
macji o wieku klientów:

•  Nabywcy nowego produktu: średnia 27,7; odchylenie standardowe 5,5.
•  Nabywcy znanego produktu: średnia 32,1; odchylenie standardowe 6,3.

Wygeneruj  dwa  zestawy  danych  o  zadanych  parametrach.  Czy  różnica  pomiędzy  odchyle-
niami  standardowymi  jest  statystycznie  znacząca?  Jak  sformułujesz  wnioski  wynikające  z
przeprowadzonej analizy?


