import pandas as pd

# Wczytanie pliku CSV z odpowiednim kodowaniem
df = pd.read_csv(
    'cities_1250.csv',
    delimiter=';',        # Ustaw odpowiedni separator, np. ';' lub ','
    encoding='cp1250',    # Kodowanie Windows-1250 (ANSI 1250)
    dtype=str             # Wczytaj wszystkie kolumny jako tekst
)

# Konwersja kolumn 'AREA' i 'GDP_CAPITA' na typ float
for col in ['AREA', 'GDP_CAPITA']:
    df[col] = (
        df[col]
        .str.replace(',', '', regex=False)  # Usuń przecinki jako separatory tysięcy
        .str.replace(' ', '', regex=False)  # Usuń spacje
        .str.replace('\xa0', '', regex=False)  # Usuń niełamiące spacje
        .astype(float)
        .round(2)  # Zaokrąglij do dwóch miejsc po przecinku
    )

# Zapisz przetworzone dane do nowego pliku CSV z kodowaniem UTF-8
df.to_csv('cities_clean.csv', sep=';', index=False, encoding='cp1250')
