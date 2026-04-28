from pathlib import Path

import matplotlib.pyplot as plt
import numpy as np
import pandas as pd
import seaborn as sns
from scipy import stats


# Autor: Aleksander Stepaniuk 272644
# Metody planowania i analizy eksperymentow - Wnioskowanie statystyczne (zadanie domowe nr 2)


BASE_DIR = Path(__file__).resolve().parent
DATA_PATH = BASE_DIR / "palmer_penguins_dataset.csv"
WYNIKI_DIR = BASE_DIR / "wyniki"
WYKRESY_DIR = BASE_DIR / "wykresy"


def mean_confidence_interval(sample: np.ndarray, confidence: float = 0.95) -> tuple[float, float, float]:
    n = len(sample)
    mean = float(np.mean(sample))
    sem = stats.sem(sample)
    t_crit = stats.t.ppf((1 + confidence) / 2, df=n - 1)
    margin = float(t_crit * sem)
    return mean, mean - margin, mean + margin


def welch_difference_ci(
    sample_a: np.ndarray, sample_b: np.ndarray, confidence: float = 0.95
) -> tuple[float, float, float, float]:
    mean_a = float(np.mean(sample_a))
    mean_b = float(np.mean(sample_b))
    var_a = float(np.var(sample_a, ddof=1))
    var_b = float(np.var(sample_b, ddof=1))
    n_a = len(sample_a)
    n_b = len(sample_b)

    diff = mean_a - mean_b
    se = np.sqrt(var_a / n_a + var_b / n_b)

    numerator = (var_a / n_a + var_b / n_b) ** 2
    denominator = ((var_a / n_a) ** 2) / (n_a - 1) + ((var_b / n_b) ** 2) / (n_b - 1)
    df = float(numerator / denominator)

    t_crit = stats.t.ppf((1 + confidence) / 2, df=df)
    margin = float(t_crit * se)

    return diff, diff - margin, diff + margin, df


def main() -> None:
    if not DATA_PATH.exists():
        raise FileNotFoundError(f"Nie znaleziono danych: {DATA_PATH}")

    WYNIKI_DIR.mkdir(exist_ok=True)
    WYKRESY_DIR.mkdir(exist_ok=True)

    df = pd.read_csv(DATA_PATH)

    analysis_df = (
        df[["species", "sex", "body_mass_g"]]
        .dropna(subset=["sex", "body_mass_g"])
        .copy()
    )

    female_mass = analysis_df.loc[analysis_df["sex"] == "Female", "body_mass_g"].to_numpy()
    male_mass = analysis_df.loc[analysis_df["sex"] == "Male", "body_mass_g"].to_numpy()

    if len(female_mass) < 2 or len(male_mass) < 2:
        raise ValueError("Zbyt malo obserwacji po podziale na plec do wykonania testu t.")

    # test normalności Shapiro-Wilka
    shapiro_female = stats.shapiro(female_mass)
    shapiro_male = stats.shapiro(male_mass)

    with open(WYNIKI_DIR / "test_normalnosci_shapiro_wilk.txt", "w", encoding="utf-8") as file:
        file.write("Test normalności Shapiro-Wilka\n")
        file.write("H0: zmienna ma rozkład normalny\n")
        file.write("H1: zmienna nie ma rozkładu normalnego\n\n")
        file.write(f"Grupa Female (n={len(female_mass)}):\n")
        file.write(f"  statystyka: {shapiro_female.statistic:.4f}\n")
        file.write(f"  p-value: {shapiro_female.pvalue:.8f}\n\n")
        file.write(f"Grupa Male (n={len(male_mass)}):\n")
        file.write(f"  statystyka: {shapiro_male.statistic:.4f}\n")
        file.write(f"  p-value: {shapiro_male.pvalue:.8f}\n\n")
        file.write(f"Poziom istotności α: 0.05\n")
        if shapiro_female.pvalue < 0.05 and shapiro_male.pvalue < 0.05:
            file.write("Wniosek: W obu grupach odrzucamy H0 (brak normalności).\n")
        elif shapiro_female.pvalue < 0.05:
            file.write("Wniosek: W grupie Female odrzucamy H0 (brak normalności).\n")
        elif shapiro_male.pvalue < 0.05:
            file.write("Wniosek: W grupie Male odrzucamy H0 (brak normalności).\n")
        else:
            file.write("Wniosek: W obu grupach nie ma podstaw do odrzucenia H0 (normalność).\n")

    # estymacja punktowa
    desc_by_sex = (
        analysis_df.groupby("sex")["body_mass_g"]
        .agg(["count", "mean", "median", "std"])
        .round(2)
        .reset_index()
    )
    desc_by_sex.to_csv(WYNIKI_DIR / "statystyki_opisowe_body_mass_sex.csv", index=False)

    overall_mean = float(analysis_df["body_mass_g"].mean())
    female_mean = float(np.mean(female_mass))
    male_mean = float(np.mean(male_mass))
    mean_difference = male_mean - female_mean

    # estymacja przedzialowa
    overall_ci = mean_confidence_interval(analysis_df["body_mass_g"].to_numpy())
    female_ci = mean_confidence_interval(female_mass)
    male_ci = mean_confidence_interval(male_mass)
    diff_ci = welch_difference_ci(male_mass, female_mass)

    # weryfikacja hipotezy: H0: mu_male = mu_female, H1: mu_male != mu_female
    ttest = stats.ttest_ind(male_mass, female_mass, equal_var=False)

    alpha = 0.05
    decision = "Odrzucamy H0" if ttest.pvalue < alpha else "Brak podstaw do odrzucenia H0"

    inference_results = pd.DataFrame(
        [
            {
                "parametr": "Srednia masa ciala (ogolem)",
                "wartosc": round(overall_mean, 2),
                "CI95_dol": round(overall_ci[1], 2),
                "CI95_gora": round(overall_ci[2], 2),
            },
            {
                "parametr": "Srednia masa ciala (Female)",
                "wartosc": round(female_mean, 2),
                "CI95_dol": round(female_ci[1], 2),
                "CI95_gora": round(female_ci[2], 2),
            },
            {
                "parametr": "Srednia masa ciala (Male)",
                "wartosc": round(male_mean, 2),
                "CI95_dol": round(male_ci[1], 2),
                "CI95_gora": round(male_ci[2], 2),
            },
            {
                "parametr": "Roznica srednich (Male - Female)",
                "wartosc": round(mean_difference, 2),
                "CI95_dol": round(diff_ci[1], 2),
                "CI95_gora": round(diff_ci[2], 2),
            },
        ]
    )
    inference_results.to_csv(WYNIKI_DIR / "wyniki_wnioskowania_body_mass.csv", index=False)

    with open(WYNIKI_DIR / "test_hipotezy_body_mass.txt", "w", encoding="utf-8") as file:
        file.write("Test t-Welcha dla dwoch niezaleznych prob\n")
        file.write("H0: srednia masa ciala samcow = srednia masa ciala samic\n")
        file.write("H1: srednie sa rozne\n\n")
        file.write(f"Liczebnosc Female: {len(female_mass)}\n")
        file.write(f"Liczebnosc Male: {len(male_mass)}\n")
        file.write(f"Statystyka t: {ttest.statistic:.4f}\n")
        file.write(f"p-value: {ttest.pvalue:.8f}\n")
        file.write(f"Stopnie swobody (Welch): {diff_ci[3]:.2f}\n")
        file.write(f"Poziom istotnosci alpha: {alpha}\n")
        file.write(f"Decyzja: {decision}\n")

    # wizualizacje pomocnicze
    sns.set_theme(style="whitegrid")

    plt.figure(figsize=(10, 6))
    sns.histplot(
        data=analysis_df,
        x="body_mass_g",
        hue="sex",
        kde=True,
        bins=24,
        palette="Set1",
        alpha=0.6,
    )
    plt.title("Rozklad masy ciala pingwinow wg plci")
    plt.xlabel("Masa ciala [g]")
    plt.ylabel("Liczebnosc")
    plt.savefig(WYKRESY_DIR / "histogram_body_mass_sex.png", dpi=300, bbox_inches="tight")
    plt.close()

    plt.figure(figsize=(8, 6))
    sns.boxplot(data=analysis_df, x="sex", y="body_mass_g", palette="Set2")
    plt.title("Porownanie masy ciala: Female vs Male")
    plt.xlabel("Plec")
    plt.ylabel("Masa ciala [g]")
    plt.savefig(WYKRESY_DIR / "boxplot_body_mass_sex.png", dpi=300, bbox_inches="tight")
    plt.close()

    print("--- WNIOSKOWANIE STATYSTYCZNE DLA ZMIENNEJ body_mass_g ---")
    print(desc_by_sex)
    print("\nEstymacja przedzialowa i roznica srednich zapisane do pliku CSV.")
    print("Test hipotezy zapisany do pliku TXT.")
    print("Wykresy zapisane w katalogu 'wykresy'.")


if __name__ == "__main__":
    main()
