import pandas as pd
import seaborn as sns
import numpy as np

# ---------------------- ZADANIE 3 ----------------------

print(f"{'-'*20} Zadanie 3: Ramki danych {'-'*20}")

# ładowanie danych
flights = sns.load_dataset("flights")
tips = sns.load_dataset("tips")
iris = sns.load_dataset("iris")
print("Dane załadowane.")

# ---------------------- Zadanie 3a ----------------------
# Sprawdź  rozmiar ramki danych flights, tips, iris. Wywołaj metody head(), tail() 
# oraz info() na obiektach flights, tips, iris.

print(f"\n{'-'*20} Zadanie 3a {'-'*20}")

# podstawowe info
print("Flights info:")
flights.info()
print(f"\nHead:\n{flights.head()}")
print(f"\nTail:\n{flights.tail()}")

# ---------------------- Zadanie 3b ----------------------
# Ramka danych flights zawiera kolumny year i month. Wygneruj na ich 
# podstawie nową zmienną typu data i czas. 

print(f"\n{'-'*20} Zadanie 3b {'-'*20}")

# generowanie daty
# tworzymy kolumnę z datą łącząc rok i miesiąc (przyjmujemy 1. dzień miesiąca)
flights['date'] = pd.to_datetime(flights['year'].astype(str) + '-' + flights['month'].astype(str) + '-01')

# dodanie czasu nie jest możliwe, ponieważ nie mamy informacji o godzinie
# ale możemy dodać godzinę 08:00:00 arbitralnie (żeby pokazać jak wyświetlać)
flights['date'] = flights['date'] + pd.to_timedelta('08:00:00')

print(f"Nowa kolumna date:\n{flights[['year', 'month', 'date']].head()}")

# ---------------------- Zadanie 3c ----------------------
# Zastosuj  wektor  etykiet  hierarchicznych  do  nazwania  wierszy  ramki  danych 
# flights. Wykorzystaj do tego celu dane zawarte w kolumnie year i month. 

print(f"\n{'-'*20} Zadanie 3c {'-'*20}")

# multiindex
# ustawiamy hierarchiczny indeks na rok i miesiąc
flights_idx = flights.set_index(['year', 'month'])
print(f"MultiIndex:\n{flights_idx.head()}")

# ---------------------- Zadanie 3d ----------------------
# Podziel ramkę danych irys na dwie rozłączne części: pierwsza 80% 
# obserwacji, druga 20%. 

print(f"\n{'-'*20} Zadanie 3d {'-'*20}")

# podział zbioru 80/20
# sample losuje wiersze, frac=0.8 to 80%
train = iris.sample(frac=0.8)
# drop usuwa wiersze, które trafiły do zbioru treningowego
test = iris.drop(train.index)
print(f"Podział Iris: 80%={len(train)}, 20%={len(test)}")

# ---------------------- Zadanie 3e ----------------------
# Dokonaj standaryzacji wszystkich zmiennych liczbowych w ramce danych iris.

print(f"\n{'-'*20} Zadanie 3e {'-'*20}")

# standaryzacja w ramce danych
# wybieramy tylko kolumny liczbowe
num_cols = iris.select_dtypes(include=[np.number]).columns
iris_std = iris.copy()
# zastosowanie wzoru na standaryzację dla wybranych kolumn
iris_std[num_cols] = (iris[num_cols] - iris[num_cols].mean()) / iris[num_cols].std()
print(f"Iris po standaryzacji (head):\n{iris_std.head()}")

# ---------------------- Zadanie 3f ----------------------
# Wyznacz podstawowe statystyki próbkowe (średnia, odchylenie standardowe, 
# kwartyle)  dla  liczby  pasażerów  (flights)  w  każdym  roku  z  sobna.  Przedstaw 
# wyniki w taki sposób, by zagregowane wartości przechowywane były 
# w kolumnach, a kolejne lata w wierszach.

print(f"\n{'-'*20} Zadanie 3f {'-'*20}")

# agregacja statystyk
# grupowanie po roku i statystyki dla pasażerów
# describe() zwraca podstawowe statystyki (mean, std, min, max, kwartyle)
stats = flights.groupby('year')['passengers'].describe()
print(f"Statystyki pasażerów:\n{stats[['mean', 'std', 'min', 'max']]}")
