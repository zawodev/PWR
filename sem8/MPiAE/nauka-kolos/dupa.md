1) 

bernuliego -> k sukcesów  w n próbach
- P(X=k) = C(n, k) * p^k * (1-p)^(n-k)

gdzie p to pojedyncza próba

gdzie C(n, k) to współczynnik dwumianowy, który można obliczyć jako:
- C(n, k) = n! / (k! * (n-k)!) -> 5! / 3! * 2!  *  p^3  *  1-p^2

wartość oczekiwana E(x) = n * p

p(0)
p(1)
p(2)

1 - (p(0) + p(1) + p(2))

0,32
p(0) = 5! / (5!) * 0,2(0) * 0,8(5) = 0,32768
p(1) = 5!/ (1 * 4! ) = 5 * 0,2 * 0,8(4) = 0,4096
p(2) = 5! / (2* 3!) = 10 * 0,04 * 0,8(3) = 0,512 * 0,04 * 10 = 0,2048


wynik = 0,32768 + 0,4096 + 0,2048 = 0,94208 => 0,05792

2) 

1 - p(0)
p(0) = 1000! / 1000! * 0,002^0 * 0,998 ^ 1000 = 1 - 0,8649

Rozkład Poissona:
lambda = n * p = 1000 * 0,002 = 2
P(brak uszkodzeń) = P(X=0) = lambda^x * e^-lambda / x! = e^-2

odp: 1 - e^-2 = 0,8647

3) 

Złota zasada:
suma prawdopodobieństw musi wynosić 1 więc, A = 0.1

E(x) = mnożymy każdą val przez prawdopodobienstwo i dodajemy

E(x) = -1 * 0,2 + 2 * 0,4 + 4 * 0,3 + 6 * 0,1 = 2.4
E(x) = 2.4


Wariancja: E(x^2) - (E(X))^2 

-1 2 4 6
1 4 16 36

E(x^2) = 1 * 0,2 + 4 * 0,4 + 16 * 0,3 + 36 * 0,1
E(x^2) = 0,2 + 1,6 + 4,8 + 3,6 = 10,2

var = 10,2 - (2,4)^2 = 4,44

4) 



całka <0, 2> C (2x - x^2) = 1

C * (x^2 - x^3/3) |0, 2> = 1
C * [(4 - 8/3) - (0 - 0)] = 1
C * (4/3) = 1
C = 3/4

E(x) = całka <0, 2> x * 3/4 * 2x - x^2)
E(x) = 3/4 * całka <0,2> 2x^2 - x^3
E(x) = 3/4 * 2x^3/3 - x^4/4 |0, 2>
E(x) = 3/4 * (16/3 - 4)
E(x) = 3/4 * 4/3 = 1


P(0.5 < X < 1) = całka <0,5 ; 1> 3/4 * 2x - x^2
P(0.5 < X < 1) = 3/4 * całka <0,5 ; 1> 2x - x^2
P(0.5 < X < 1) = 3/4 * (x^2 - x^3/3) |0,5 ; 1>
P(0.5 < X < 1) = 3/4 * (1 - 1/3 - (0,25 - 0,125/3))
P(0.5 < X < 1) = 3/4 * (2/3 - 1/4 + 1/24)
P(0.5 < X < 1) = 3/4 * (16/24 - 6/24 + 1/24)
P(0.5 < X < 1) = 3/4 * 11/24 = 33/96 = 11/32



5) 
a)

m/miu -> avg
sigma^2 -> var
sigma -> stddev

tablice pokazują rozkład normalny, gdzie m = 0, sigma = 1
mechanizm standaryzacji -> z = (x - m) / sigma
gdzie:
- z to standaryzowana wartość
- x to wartość, którą chcemy przekształcić
- m to średnia
- sigma to odchylenie standardowe

dla m = 0, sigma = 2

granice: [0, 0,2] po standaryzacji:
z1 = (0 - 0) / 2 = 0
z2 = (0,2 - 0) / 2 = 0,1

P(0 < X < 0,2) = P(0 < Z < 0,1) => odczytać z tablic Phi(0,1) - Phi(0) = 0,5398 - 0,5 = 0,0398


b) 

z = (0,5 - 0) / 2 = 0,25
P(X < 0,5) = P(Z < 0,25) => odczytać z tablic Phi(0,25) = 0,5987

6) 
m = 2
sigma = 3
a) P(X <= A) = 0,95
b) P(X > A) = 0,25

a) P(X <= A) = 0,95 => P(Z <= (A - m) / sigma) = 0,95
odczytać z tablic Phi(z) = 0,95 => z = 1,645
(A - 2) / 3 = 1,645
A = 2 + 3 * 1,645 = 6,935

b) P(X > A) = 0,25 => P(Z > (A - m) / sigma) = 0,25
P(Z <= (A - m) / sigma) = 0,75
odczytać z tablic Phi(z) = 0,75 => z = 0,674
(A - 2) / 3 = 0,674
A = 2 + 3 * 0,674 = 4,022

7) 

a)

m = 3
var = 4, std = 2

P(X > 0)
z = 0 - m / 2 = -3/2 = -1.5
P(Z > -1.5) = 1 - P(Z < -1.5) = 1 - (1 - P(Z < 1.5)) = P(Z < 1.5) = 0,9332

b) 

P(-5 < X <= 5)
z1 = -5 -3 / 2 = -8/2 = -4
z2 = 5 - 3 / 2 = 2/2 = 1

P(-4 < Z < 1)

Phi(1) - Phi(-4) = 0,8413 - 0,0000001 = 0,8413

8)

EX = (a+b)/2 = 0.5
VarX = (b-a)^2 / 12 = 1/12

n = 10, p = 0,5
EY = n * p = 5
VarY = n * p * (1-p) = 10 * 0,5 * 0,5 = 2,5

a) E(2X − 3Y) = 2*EX - 3*EY = 2 * 0,5 - 3 * 5 = -14
b) EXY = EX * EY = 0,5 * 5 = 2,5
c) Var((3Y - X) / 2) = Var(3/2Y - 1/2X) = (3/2)^2 * VarY + (1/2)^2 * VarX = 9/4*5/2 + 1/4*1/12 = 
= 45/8 + 1/48 = 271 / 48 = 5 + 31/48

Var(aX + bY) = a^2 VarX + b^2 VarY

9)

m=50
std = 5

P(X >= T) >= 0,9
P(X < T) < 0,1

P(Z < (T-50) / 5) < 0,1
Phi(0,1) = -1,282 (bo Phi(0,9) = 1,282)

T-50 / 5 < -1,282
T-50 < -1,282 * 5
T < -1,282 * 5 + 50
T < 43,59

Odp: T<=43

10)
m = 3000
var = 10^6
std = 10^3

a) 
P(2800 < X < 3200)
z1 = 2800 - 3000 = -200 / 1000 = -0,2
z2 = 3200 - 3000 = 200 / 1000 = 0,2

P(-0,2 < X < 0,2)
Phi(0,2) - Phi(-0,2) = 0,5793 - (1-0,5793) = 
= 0,5793 - 0,4207 = 0,1586

b) 

nowe_std = 1000 / sqrt(25) = 200
z1 = -200 / 200 = -1
z2 = 1

P(Z > -1) = 1 - P(Z <= -1)

Phi(-1) = 1 - Phi(1) = 1 - 0,8413
P(Z > -1) = 1 - (1-0,8413) = 0,8413
