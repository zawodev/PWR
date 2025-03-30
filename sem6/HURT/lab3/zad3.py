import pandas as pd
from ydata_profiling import ProfileReport

data = pd.read_csv('dane_lista3.csv')

# data frame info
print("Info o DataFrame:")
print(data.info())
# statystyki opisowe
print("\nStatystyki opisowe (wszystkie kolumny):")
print(data.describe(include='all'))

# liczba wystąpień error i unknown
print("\nLiczba wystąpień 'ERROR' i 'UNKNOWN' w każdej kolumnie:")
print(data.isin(['ERROR', 'UNKNOWN']).sum())

# liczba brakujących wartości
print("\nLiczba brakujących wartości:")
print(data.isnull().sum())

profile = ProfileReport(data, title="Raport profilu danych - dane_lista3.csv", explorative=True)
profile.to_file("raport_danych.html")

print("\nraport został zapisany do pliku 'raport_danych.html'")

