#listy
a = (1, 2, 3, 6, 1)
print(a[:-2])
print(a[-2:])


#plytka kopia (referencja ta sama na oryginalny obiekt)
plytkakopia = a[:]


#kopia gleboka
from copy import deepcopy
deepkopia = deepcopy(a)


#odwrocenie kolejnosci elementow
b = a[::-1]
print(b)


#multiplikacja listy
c = a * 3
print(c)


#zliczanie wystapien elementu i index
print(a.count(1))
print(a.index(3))


l = [1, 2, 3, 4, 5]
#dodanie elementu na koniec
l.append(6)
l += [7]

print(l)

#usuwanie elementu z listy przez wartosc
#l.remove(7)

del l[1]

print(l)



# ================== SLowniki ==================

fruits = ['apple', 'banana', 'cherry']
prices = [1.2, 3.4, 5.6]

for index, fruit in enumerate(fruits):
    print(fruit, prices[index])

for fruit, price in zip(fruits, prices):
    print(fruit, price)


numbers = [5, 6, 1, 3, 7]
print(sorted(numbers))

for number in reversed(numbers):
    print(number, end='')


# ================== SLOWNIKI ==================

from itertools import cycle #1, 2, 3, 4, 1, 2, 3...
from itertools import count #1, 11, 21, 31...import
from itertools import repeat #1, 1, 1, 1, 1, 1, 1, 1, 1, 1...
from itertools import accumulate #1, 3, 6, 10, 15, 21, 28, 36, 45, 55...
from itertools import product #('a', 1), ('a', 2), ('a', 3), ('b', 1), ('b', 2), ('b', 3), ('c', 1), ('c', 2), ('c', 3)...

it = cycle([1, 2, 3, 4])
for _ in range(10):
    print(next(it), end='')


