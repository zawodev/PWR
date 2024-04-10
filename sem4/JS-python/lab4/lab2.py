import os
import sys


def print_folders():
    for folder in os.environ['PATH'].split(os.pathsep):
        if folder: # if exist
            print(folder)


def print_executables():
    for folder in os.environ['PATH'].split(os.pathsep):
        try: # listuje files w danym katalogu
            files = os.listdir(folder)
        except OSError: # jeśli są błędy, pomijam katalog (np. brak dostępu)
            continue

        exec_files = [file for file in files if
                      os.path.isfile(os.path.join(folder, file)) and
                      os.access(os.path.join(folder, file), os.X_OK) and # liniksowy plik wykonywalny
                      file.endswith(".exe")] # mozliwe ze bez tej linijki

        if exec_files: # jeśli w folderze są pliki
            print(f"{folder}:")
            for file in exec_files:
                print(f"  {file}")
            print()


if __name__ == "__main__":
    usage_msg = "usage: python lab2.py [f|x]; f - folders, x - executables"
    if len(sys.argv) < 2:
        print("no parameters given, " + usage_msg)
    elif sys.argv[1].lower() == "f":
        print_folders()
    elif sys.argv[1].lower() == "x":
        print_executables()
    else:
        print("unknown parameter, " + usage_msg)
