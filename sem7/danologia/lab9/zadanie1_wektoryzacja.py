import numpy as np

# ---------------------- ZADANIE 1 ----------------------
# Przykładowy  wektor.  Zacznijmy  od  stworzenia  wektora  o  sześciu  elementach typu całkowitego.

print(f"{'-'*20} Zadanie 1: Wektoryzacja {'-'*20}")

# tworzenie wektora
x = np.array([-2, -1, 0, 1, 2, 3])
print(f"Wektor: {x}")
print(f"Typ: {type(x)}")

# liczba wymiarów tablicy
print(f"Wymiar (ndim): {x.ndim}")

# krotka z rozmiarem każdego wymiaru
print(f"Kształt (shape): {x.shape}")

# ---------------------- Zadanie 1a ----------------------
# Stwórz tablice 2 wymiarową 4 elementową. Sprawdź wymiar i kształt macierzy. 
# Zmień kształt tablicy na tablicę 2 i 6 elementową. 

print(f"\n{'-'*20} Zadanie 1a {'-'*20}")

# tablica 2-wymiarowa, 4-elementowa
arr = np.array([[1, 2], [3, 4]])
print(f"Tablica 2x2:\n{arr}")
print(f"Wymiar: {arr.ndim}, Kształt: {arr.shape}")

# zmiana kształtu (reshape)
# reshape zmienia wymiary tablicy bez zmiany danych
arr_12 = np.arange(12)
arr_2x6 = arr_12.reshape(2, 6)
print(f"\nPo reshape(2, 6):\n{arr_2x6}")

# ---------------------- Zadanie 1b ----------------------
# Stwórz tablicę zawiera ciąg arytmetyczny o zadanym przyroście. 
# Stwórz tablicę zawiera ciąg arytmetyczny złożony z wartości z przedziału [a,b]. 

print(f"\n{'-'*20} Zadanie 1b {'-'*20}")

# ciągi arytmetyczne
# arange tworzy ciąg z zadanym krokiem (przyrostem)
start = 0
stop = 10
step = 2
print(f"arange({start}, {stop}, {step}): {np.arange(start, stop, step)}")

# linspace tworzy ciąg o określonej liczbie elementów w przedziale
a = 0
b = 1
num = 5
print(f"linspace({a}, {b}, {num}): {np.linspace(a, b, num)}")

# ---------------------- Zadanie 1c ----------------------
# Stwórz macierz: jednostkową, wypełnioną zerami i jedynkami.

print(f"\n{'-'*20} Zadanie 1c {'-'*20}")

# macierze specjalne
print(f"Jednostkowa:\n{np.eye(3)}")
print(f"Zera:\n{np.zeros((3, 3))}")
print(f"Jedynki:\n{np.ones((3, 3))}")

# ---------------------- Zadanie 1d ----------------------
# Stwórz macierz 4x2, a następnie dodaj do niej dowolny element.

print(f"\n{'-'*20} Zadanie 1d {'-'*20}")

# macierz 4x2 i dodawanie elementu
mat = np.array([[1, 2], [3, 4], [5, 6], [7, 8]])
print(f"Macierz przed:\n{mat}")
# append dodaje element na końcu (spłaszcza tablicę jeśli nie podano osi)
print(f"Macierz po dodaniu elementu:\n{np.append(mat, 9)}")

# ---------------------- Zadanie 1e ----------------------
# Stwórz 2 różne macierze, a następnie wykonaj na nich operacje: +, -, *, /, **, //, %. 

print(f"\n{'-'*20} Zadanie 1e {'-'*20}")

# operacje na macierzach
A = np.array([[10, 20], [30, 40]])
B = np.array([[2, 4], [5, 8]])
print(f"Macierz A:\n{A}")
print(f"Macierz B:\n{B}")
print(f"\n----- Operacje: -----")
print(f"Dodawanie:\n{A + B}")
print(f"Odejmowanie:\n{A - B}")
print(f"Mnożenie (element-wise):\n{A * B}")
print(f"Dzielenie:\n{A / B}")
print(f"Potęgowanie:\n{A ** 2}")
print(f"Dzielenie całkowite:\n{A // B}")
print(f"Reszta z dzielenia:\n{A % B}")
