import time
import re
from colorama import init, Fore, Style
init(autoreset=True)

def timing(func):
    """Decorator to measure execution time and node count."""
    def wrapper(*args, **kwargs):
        start = time.time()
        result = func(*args, **kwargs)
        elapsed = time.time() - start
        result.stats['time'] = elapsed
        return result
    return wrapper

def notation_to_index(move: str, rows: int, cols: int):
    m = re.fullmatch(r'([a-j])([0-9])([a-j])([0-9])', move)
    if not m:
        raise ValueError(f"Niepoprawna notacja ruchu: '{move}'")
    col_map = {chr(ord('a')+i): i for i in range(cols)}

    c1 = col_map[m.group(1)]
    r1 = int(m.group(2))
    c2 = col_map[m.group(3)]
    r2 = int(m.group(4))

    # w naszym wewnętrznym boardzie r=0 u góry, więc:
    r1i = rows - 1 - r1
    r2i = rows - 1 - r2

    if not (0 <= r1i < rows and 0 <= r2i < rows):
        raise ValueError(f"Wiersz poza zakresem: '{move}'")
    return (r1i, c1), (r2i, c2)

def print_board_colored(state):
    rows, cols = state.rows, state.cols

    # Nagłówek kolumn
    col_labels = ' ' + ' ' + ' '.join(chr(ord('a') + c) for c in range(cols))
    print(Fore.GREEN + col_labels)

    for display_row in range(rows):
        # numer wiersza (tylko jedna spacja po nim)
        row_label = f"{display_row}"
        line = [Fore.GREEN + row_label + '']
        for c in range(cols):
            cell = state.board[display_row][c]
            if cell == 'B':
                line.append(Fore.RED + 'B')
            elif cell == 'W':
                line.append(Fore.BLUE + 'W')
            else:
                line.append(Fore.WHITE + '_')
        print(' '.join(line) + Style.RESET_ALL)

def announce_turn(state):
    if state.current == 'B':
        print(Fore.RED + "Ruch gracza 1 (B) >> " + Style.RESET_ALL)
    else:
        print(Fore.BLUE + "Ruch gracza 2 (W) >> " + Style.RESET_ALL)

def announce_winner(winner):
    if winner == 'B':
        print(Fore.RED + "Wygrał gracz 1 (B)!" + Style.RESET_ALL)
    else:
        print(Fore.BLUE + "Wygrał gracz 2 (W)!" + Style.RESET_ALL)