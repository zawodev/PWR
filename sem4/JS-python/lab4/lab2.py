import os
import sys


def wypisz_katalogi():
    for katalog in os.environ['PATH'].split(os.pathsep):
        print(katalog)


def wypisz_pliki_wykonywalne():
    for katalog in os.environ['PATH'].split(os.pathsep):
        try:
            # Listuje pliki w danym katalogu
            pliki = os.listdir(katalog)
        except OSError:
            # Pomija katalog, jeśli wystąpiły błędy (np. brak dostępu)
            continue

        wykonywalne_pliki = [plik for plik in pliki if os.path.isfile(os.path.join(katalog, plik)) and os.access(os.path.join(katalog, plik), os.X_OK)]
        if wykonywalne_pliki:
            print(f"{katalog}:")
            for plik in wykonywalne_pliki:
                print(f"  {plik}")
            print()  # Dla lepszej czytelności


if __name__ == "__main__":
    usage_msg = "Usage: python lab2.py [f|x]; f - folders, x - executables"
    if len(sys.argv) < 2:
        print("No parameter given. " + usage_msg)
    elif sys.argv[1].lower() == "f":
        wypisz_katalogi()
    elif sys.argv[1].lower() == "x":
        wypisz_pliki_wykonywalne()
    else:
        print("Unknown parameter. " + usage_msg)
