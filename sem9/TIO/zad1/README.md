# LcVRPContest w VS Code

Program jest aplikacją C++ uruchamianą z konsoli. Nie wymaga Visual Studio
Community ani pliku `.sln` — do kompilacji używa CMake i dowolnego kompilatora
C++17.

## Wymagane rozszerzenia VS Code

W VS Code zainstaluj:

- **C/C++** (`ms-vscode.cpptools`)
- **CMake Tools** (`ms-vscode.cmake-tools`)

Potrzebny jest także kompilator:

- **Linux (Ubuntu/Debian):** `sudo apt update && sudo apt install build-essential cmake ninja-build gdb`
- **Linux (Fedora):** `sudo dnf install gcc-c++ cmake ninja-build gdb`
- **Windows:** GCC, CMake i Ninja z MSYS2 UCRT64.

### Fedora Linux — instalacja krok po kroku

1. Otwórz terminal i zaktualizuj system:

   ```bash
   sudo dnf upgrade --refresh
   ```

2. Zainstaluj kompilator C++, CMake, Ninja, GDB oraz Git:

   ```bash
   sudo dnf install gcc-c++ cmake ninja-build gdb git
   ```

3. Sprawdź, czy narzędzia zostały zainstalowane:

   ```bash
   g++ --version
   cmake --version
   ninja --version
   gdb --version
   ```

4. Zainstaluj VS Code. Możesz pobrać pakiet `.rpm` z
   [code.visualstudio.com](https://code.visualstudio.com/download) i
   zainstalować go poleceniem:

   ```bash
   sudo dnf install ./code-*.rpm
   ```

   Jeśli VS Code jest już zainstalowany, przejdź do następnego kroku.

5. Uruchom VS Code i zainstaluj rozszerzenia:

   - **C/C++** (`ms-vscode.cpptools`)
   - **CMake Tools** (`ms-vscode.cmake-tools`)

   Możesz też zainstalować je z terminala:

   ```bash
   code --install-extension ms-vscode.cpptools
   code --install-extension ms-vscode.cmake-tools
   ```

6. Sklonuj repozytorium albo przejdź do już pobranego katalogu projektu:

   ```bash
   git clone https://github.com/zawodev/PWR.git
   cd PWR/sem9/TIO/zad1
   ```

   Jeśli repozytorium jest już pobrane, wykonaj tylko `cd` do katalogu
   `sem9/TIO/zad1`.

7. Otwórz katalog projektu w VS Code:

   ```bash
   code .
   ```

   Otwórz katalog `zad1`, czyli ten zawierający `CMakeLists.txt` i `data/`.

8. W VS Code wybierz `Ctrl+Shift+P` → **CMake: Select a Kit**, a następnie
   wybierz GCC/G++.

9. Wybierz `Ctrl+Shift+P` → **CMake: Configure**, a następnie
   **CMake: Build**. CMake utworzy katalog `build/` z plikami generowanymi
   automatycznie.

10. Uruchom program przez **CMake: Run Without Debugging** albo z terminala:

   ```bash
   ./build/LcVRPContest
   ```

   Program powinien wykonać trzy eksperymenty algorytmu genetycznego, wypisać
   wyniki `final best fitness` i zakończyć działanie.

### Fedora Linux — uruchomienie z terminala bez VS Code

Jeżeli chcesz tylko skompilować i uruchomić program:

```bash
cd PWR/sem9/TIO/zad1
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
./build/LcVRPContest
```

### Windows — instalacja MSYS2 krok po kroku

1. Pobierz instalator MSYS2 z [msys2.org](https://www.msys2.org/) i zainstaluj
   program, najlepiej w domyślnym katalogu `C:\msys64`.
2. Z menu Start uruchom **MSYS2 UCRT64**. Nie wybieraj zwykłego **MSYS** ani
   **CLANG64**.
3. Zaktualizuj MSYS2:

   ```bash
   pacman -Syu
   ```

   Jeżeli terminal poprosi o zamknięcie, zamknij go, ponownie uruchom
   **MSYS2 UCRT64** i wykonaj ponownie:

   ```bash
   pacman -Syu
   ```

4. Zainstaluj kompilator i narzędzia:

   ```bash
   pacman -S --needed mingw-w64-ucrt-x86_64-gcc mingw-w64-ucrt-x86_64-cmake mingw-w64-ucrt-x86_64-ninja
   ```

5. Sprawdź instalację w tym samym terminalu:

   ```bash
   gcc --version
   cmake --version
   ninja --version
   ```

6. W terminalu **MSYS2 UCRT64** przejdź do projektu. Dla przykładowej
   lokalizacji repozytorium użyj:

   ```bash
   cd /e/GitHub/zawodev/PWR/sem9/TIO/zad1
   ```

   Następnie można od razu zbudować i uruchomić program:

   ```bash
   cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
   cmake --build build
   ./build/LcVRPContest.exe
   ```

### Windows — uruchomienie przez VS Code

Najprościej uruchomić VS Code z terminala **MSYS2 UCRT64**:

```bash
cd /e/GitHub/zawodev/PWR/sem9/TIO/zad1
code .
```

Jeśli polecenie `code` nie jest dostępne, otwórz VS Code normalnie i wybierz
**File → Open Folder**, wskazując katalog `zad1`. Następnie w VS Code wybierz
kompilator przez **CMake: Select Configure Preset** lub **CMake: Select a Kit**
i wybierz GCC z MSYS2/UCRT64.

Alternatywnie dodaj `C:\msys64\ucrt64\bin` do systemowej zmiennej `PATH`,
uruchom ponownie VS Code i wybierz `gcc`/`g++` jako kompilator. Nie trzeba
instalować Visual Studio Community.

### Windows — błąd „CMake executable not found in cache”

Jeżeli VS Code próbuje uruchomić:

```text
C:\Program Files\CMake\bin\cmake.exe
```

ale tego pliku nie ma, oznacza to, że CMake Tools ma zapamiętaną starą ścieżkę.
Po instalacji CMake przez MSYS2 wykonaj w **MSYS2 UCRT64**:

```bash
which cmake
```

Powinna pojawić się ścieżka podobna do `/ucrt64/bin/cmake`. W VS Code:

1. Wybierz `Ctrl+Shift+P` → **CMake: Delete Cache and Reconfigure**.
2. Jeżeli pojawi się wybór ścieżki, wskaż:
   `C:\msys64\ucrt64\bin\cmake.exe`.
3. Wybierz **CMake: Select a Kit** i wybierz zestaw UCRT64/GCC.
4. Uruchom **CMake: Configure**.

Ten projekt zawiera już ustawienie `cmake.cmakePath` wskazujące domyślną
lokalizację MSYS2 UCRT64. Jeśli MSYS2 zainstalowano w innym katalogu, zmień tę
wartość w `.vscode/settings.json`.

## Uruchomienie w VS Code

1. Otwórz w VS Code **katalog `zad1`**, czyli katalog zawierający ten plik
   `README.md` i `CMakeLists.txt` (nie sam plik `.sln`).
2. Przy pierwszym otwarciu zaakceptuj konfigurację CMake i wybierz kompilator
   GCC/`g++` (na Windows: UCRT64) albo `clang++`.
3. Kliknij **Build** na pasku CMake Tools.
4. Kliknij **Run** albo wybierz `LcVRPContest` jako cel i uruchom debugowanie
   przez **Run and Debug**.

Katalog roboczy jest ustawiony na katalog projektu, ponieważ program ładuje
instancję z relatywnej ścieżki `data/lcvrp/Vrp-Set-D/`.

## Uruchomienie z terminala

Polecenia wykonuj w katalogu `zad1`:

### Linux

```bash
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
./build/LcVRPContest
```

### Windows (PowerShell)

```powershell
cmake -S . -B build -G Ninja -DCMAKE_BUILD_TYPE=Debug
cmake --build build
.\build\LcVRPContest.exe
```

Program powinien wypisać 10 wierszy `current fitness: ...` oraz końcowy wiersz
`final best fitness: ...`, a następnie zakończyć działanie.

## Algorytm genetyczny

Program rozwiązuje problem za pomocą podstawowego algorytmu genetycznego.
Chromosom jest wektorem długości równej liczbie klientów. Wartość genu oznacza
numer grupy/pojazdu, do którego przypisano danego klienta. Kolejność klientów
jest określona przez `PERMUTATION` w pliku instancji.

Koszt rozwiązania jest obliczany przez `Evaluator`. Ponieważ algorytm genetyczny
maksymalizuje przystosowanie, używana jest funkcja:

```text
adaptation = 1 / (1 + route_cost)
```

Rozwiązania niepoprawne otrzymują przystosowanie równe zero. W każdej generacji
stosowane są:

- selekcja ruletkowa,
- krzyżowanie jednopunktowe z prawdopodobieństwem `Pc`,
- mutacja pojedynczych genów z prawdopodobieństwem `Pm`.

Warunkiem stopu jest osiągnięcie ustalonej liczby generacji. Program w
`LcVRPContest.cpp` uruchamia trzy eksperymenty dla tej samej instancji i małej
populacji, zmieniając `Pc` i `Pm`.
