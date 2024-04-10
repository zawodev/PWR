import sys
import time
import argparse


def tail(file, lines=10, follow=False):
    lines = file.readlines()[-lines:]
    for line in lines:
        print(line, end='')

    if follow:
        try:
            while True:
                line = file.readline()
                if line:
                    print(line, end='')
                else:
                    time.sleep(1)
        except KeyboardInterrupt:
            sys.exit()


def parse_args():
    parser = argparse.ArgumentParser(description="własna uproszczona wersja uniksowego prorgamu tail")
    parser.add_argument('filepath', nargs='?', type=str, help="ścieżka do pliku")
    parser.add_argument('--lines', '-n', type=int, default=10, help="liczba ostatnich linii do wyświetlenia")
    parser.add_argument('--follow', '-f', action='store_true', help="śledź dodatkowe linie dodawane do pliku")
    return parser.parse_args()


if __name__ == '__main__':
    args = parse_args()

    if args.filepath: # otwórz plik, jeśli podano ścieżkę
        with open(args.filepath, 'r') as input_file:
            tail(input_file, args.lines, args.follow)
    else: # w przeciwnym razie czytaj z wejścia standardowego
        tail(sys.stdin, args.lines, args.follow)
