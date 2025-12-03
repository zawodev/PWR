import pandas as pd
import seaborn as sns
import numpy as np

print(f"{'-'*20} Zadanie 3: Ramki danych {'-'*20}")

# ładowanie danych
flights = sns.load_dataset("flights")
tips = sns.load_dataset("tips")
iris = sns.load_dataset("iris")
print("Dane załadowane.")

# ---------------------- Zadanie 3a ----------------------

print(f"\n{'-'*20} Zadanie 3a {'-'*20}")

# podstawowe info
print("Flights info:")
flights.info()
print(f"\nHead:\n{flights.head()}")
print(f"\nTail:\n{flights.tail()}")

# ---------------------- Zadanie 3b ----------------------

print(f"\n{'-'*20} Zadanie 3b {'-'*20}")

# generowanie daty
# tworzymy kolumnę z datą łącząc rok i miesiąc (przyjmujemy 1. dzień miesiąca)
flights['date'] = pd.to_datetime(flights['year'].astype(str) + '-' + flights['month'].astype(str) + '-01')
print(f"Nowa kolumna date:\n{flights[['year', 'month', 'date']].head()}")

# ---------------------- Zadanie 3c ----------------------

print(f"\n{'-'*20} Zadanie 3c {'-'*20}")

# multiindex
# ustawiamy hierarchiczny indeks na rok i miesiąc
flights_idx = flights.set_index(['year', 'month'])
print(f"MultiIndex:\n{flights_idx.head()}")

# ---------------------- Zadanie 3d ----------------------

print(f"\n{'-'*20} Zadanie 3d {'-'*20}")

# podział zbioru 80/20
# sample losuje wiersze, frac=0.8 to 80%
train = iris.sample(frac=0.8)
# drop usuwa wiersze, które trafiły do zbioru treningowego
test = iris.drop(train.index)
print(f"Podział Iris: 80%={len(train)}, 20%={len(test)}")

# ---------------------- Zadanie 3e ----------------------

print(f"\n{'-'*20} Zadanie 3e {'-'*20}")

# standaryzacja w ramce danych
# wybieramy tylko kolumny liczbowe
num_cols = iris.select_dtypes(include=[np.number]).columns
iris_std = iris.copy()
# zastosowanie wzoru na standaryzację dla wybranych kolumn
iris_std[num_cols] = (iris[num_cols] - iris[num_cols].mean()) / iris[num_cols].std()
print(f"Iris po standaryzacji (head):\n{iris_std.head()}")

# ---------------------- Zadanie 3f ----------------------

print(f"\n{'-'*20} Zadanie 3f {'-'*20}")

# agregacja statystyk
# grupowanie po roku i statystyki dla pasażerów
# describe() zwraca podstawowe statystyki (mean, std, min, max, kwartyle)
stats = flights.groupby('year')['passengers'].describe()
print(f"Statystyki pasażerów:\n{stats[['mean', 'std', 'min', 'max']]}")
