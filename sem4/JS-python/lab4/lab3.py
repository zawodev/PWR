import sys
import time
import argparse

def tail(file, lines=10, follow=False):
    """
    Wyświetla ostatnie 'lines' linii z pliku lub danych wejściowych.
    Opcjonalnie, w przypadku 'follow', śledzi dodawane linie.

    Args:
    - file: obiekt pliku do czytania.
    - lines: liczba linii do wyświetlenia.
    - follow: czy kontynuować śledzenie pliku po wypisaniu ostatnich linii.
    """
    try:
        if file.seekable():
            file.seek(0, 2)  # Przesunięcie na koniec pliku
            size = file.tell()
            buffer = 1024
            lines_found = []

            while size > 0 and len(lines_found) <= lines:
                # Decyduj, ile danych czytać
                to_read = min(buffer, size)
                size -= to_read
                file.seek(size, 0)

                # Czytaj i znajduj nowe linie
                chunk = file.read(to_read)
                lines_found = chunk.splitlines() + lines_found

                # Przerywa, jeśli znaleziono wystarczającą liczbę linii
                if len(lines_found) > lines:
                    lines_found = lines_found[-lines:]

            for line in lines_found:
                print(line)

        else:
            # Obsługa danych z wejścia standardowego, jeśli nie da się przewinąć
            lines_found = file.readlines()[-lines:]
            for line in lines_found:
                print(line, end='')

        if follow:
            # Śledzenie dodatkowych linii
            while True:
                line = file.readline()
                if line:
                    print(line, end='')
                else:
                    time.sleep(0.1)

    except KeyboardInterrupt:
        # Obsługa przerwania przez użytkownika (Ctrl+C)
        sys.exit()

def parse_args():
    parser = argparse.ArgumentParser(description="Uproszczony program 'tail'.")
    parser.add_argument('filepath', nargs='?', type=str, help="Ścieżka do pliku.")
    parser.add_argument('--lines', '-n', type=int, default=10, help="Liczba ostatnich linii do wyświetlenia.")
    parser.add_argument('--follow', '-f', action='store_true', help="Śledź dodatkowe linie dodawane do pliku.")
    return parser.parse_args()

if __name__ == '__main__':
    args = parse_args()

    if args.filepath:
        # Otwórz plik, jeśli podano ścieżkę
        with open(args.filepath, 'r') as input_file:
            tail(input_file, args.lines, args.follow)
    else:
        # W przeciwnym razie czytaj z wejścia standardowego
        tail(sys.stdin, args.lines, args.follow)
