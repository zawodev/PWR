import os
import sys

# print folders
def print_folders():
    for katalog in os.environ['PATH'].split(os.pathsep):
        if katalog:
            print(katalog)

# print executables
def print_exec_files():
    for folder in os.environ['PATH'].split(os.pathsep):
        try:  # listuje files w danym katalogu
            files = os.listdir(folder)
        except OSError:  # jeśli są błędy, pomijam katalog (np. brak dostępu)
            continue

        exec_files = [plik for plik in files if
                      os.path.isfile(os.path.join(folder, plik)) and os.access(os.path.join(folder, plik), os.X_OK)]
        if exec_files:  # jeśli w danym folderze są pliki wykonywalne, to je wypisz
            print(f"{folder}:")
            for plik in exec_files:
                print(f"  {plik}")
            print()  # dla lepszej czytelności


if __name__ == "__main__":
    usage_msg = "Usage: python lab2.py [f|x]; f - folders, x - executables"
    if len(sys.argv) < 2:
        print("No parameter given. " + usage_msg)
    elif sys.argv[1].lower() == "f":
        print_folders()
    elif sys.argv[1].lower() == "x":
        print_exec_files()
    else:
        print("Unknown parameter. " + usage_msg)
