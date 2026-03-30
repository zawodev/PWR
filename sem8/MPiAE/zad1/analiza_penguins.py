import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import os

# 1. Pobranie danych za pomocą biblioteki seaborn (oryginalne dane Palmer Penguins)
# Źródło: Gorman KB, Williams TD, Fraser WR (2014) - stacja badawcza Palmer Station, Antarktyda.
# Zbiór można też znaleźć na Kaggle: https://www.kaggle.com/datasets/parulpandey/palmer-archipelago-antarctica-penguin-data
df = sns.load_dataset('penguins')

# Zapisanie surowych danych do pliku CSV dla wglądu własnego
df.to_csv('palmer_penguins_dataset.csv', index=False)

# Czyszczenie danych z braków dla rzetelności analizy
df = df.dropna()

# 2. Obliczenia i wskaźniki sumaryczne
print("--- Podstawowe statystyki opisowe wszystkich zmiennych numerycznych ---")
print(df.describe().round(2))

# Analiza Porównawcza (Masa ciała [g] względem Gatunku i Płci)
print("\n--- Analiza Porównawcza: Masa ciała (body_mass_g) zgrupowana po płci i gatunku ---")
summary_stats = df.groupby(['species', 'sex'])['body_mass_g'].agg(['count', 'mean', 'median', 'std']).round(2)
print(summary_stats)

# Zapis statystyk z analizy porównawczej do pliku
summary_stats.to_csv('penguins_summary_stats.csv')

# 3. Wizualizacja
sns.set_theme(style="whitegrid")
os.makedirs('wykresy', exist_ok=True)

# Wykres 1: Rozkład masy ciała względem płci (Histogram - weryfikacja czy zmienna grupuje się logicznie)
plt.figure(figsize=(10, 6))
sns.histplot(data=df, x='body_mass_g', hue='sex', kde=True, bins=25, alpha=0.6, palette='Set1')
plt.title('Rozkład masy ciała pingwinów z podziałem na płeć')
plt.xlabel('Masa ciała [g]')
plt.ylabel('Liczność')
plt.savefig('wykresy/histogram_masa_plec.png', dpi=300, bbox_inches='tight')
plt.close()

# Wykres 2: Porównanie długości płetw u różnych gatunków (Boxplot - ukazanie różnic międzygatunkowych)
plt.figure(figsize=(10, 6))
sns.boxplot(data=df, x='species', y='flipper_length_mm', hue='sex', palette='Set2')
plt.title('Długość płetwy w zależności od gatunku i płci')
plt.xlabel('Gatunek')
plt.ylabel('Długość płetwy [mm]')
plt.savefig('wykresy/boxplot_pletwa_gatunek.png', dpi=300, bbox_inches='tight')
plt.close()

# Wykres 3: Zależność wymiarów dzioba (Scatterplot - sprawdzenie, czy pozwala na dyskryminację)
plt.figure(figsize=(10, 6))
sns.scatterplot(data=df, x='bill_length_mm', y='bill_depth_mm', hue='species', style='sex', s=100, alpha=0.8)
plt.title('Zależność wymiarów dzioba (długość vs głębokość) między gatunkami')
plt.xlabel('Długość dzioba [mm]')
plt.ylabel('Głębokość dzioba [mm]')
plt.savefig('wykresy/scatter_dziob_gatunek.png', dpi=300, bbox_inches='tight')
plt.close()

print("\nPobrano prawdziwe dane Palmer Penguins. Wykresy i pliki .csv zostały wygenerowane pomyślnie.")