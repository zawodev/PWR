import pandas as pd
from ucimlrepo import fetch_ucirepo

# fetch datasetu
cardiotocography = fetch_ucirepo(id=193)
X = cardiotocography.data.features
y = cardiotocography.data.targets

# 1. podgląd pierwszych wierszy
print(X.head())

# 2. podstawowe statystyki opisowe
print(X.describe())

# 3. rozkład klas
print(y['CLASS'].value_counts().sort_index())

# 4. liczba brakujących wartości w każdej kolumnie
print(X.isna().sum())
