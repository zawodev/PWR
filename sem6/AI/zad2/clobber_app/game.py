from typing import List
from clobber_app.utils import notation_to_index, coords_to_notation

class GameState:
    def __init__(self, rows: int = 5, cols: int = 6):
        self.rows = rows
        self.cols = cols
        self.board = [[None]*cols for _ in range(rows)]
        self._init_board()
        self.current = 'B'  # 'B' = black (first), 'W' = white (second)

    def _init_board(self):
        for r in range(self.rows):
            for c in range(self.cols):
                self.board[r][c] = 'B' if (r+c) % 2 == 0 else 'W'

    def is_terminal(self) -> bool:
        return not self.get_legal_moves('B') and not self.get_legal_moves('W')

    def count_attacked_enemy_pieces(self, player: str) -> int:
        opp = 'W' if player == 'B' else 'B'
        dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        count = 0

        for r in range(self.rows):
            for c in range(self.cols):
                if self.board[r][c] == opp:
                    for dr, dc in dirs:
                        nr, nc = r+dr, c+dc
                        if 0 <= nr < self.rows and 0 <= nc < self.cols and self.board[nr][nc] == player:
                            count += 1
                            break
        return count

    def get_legal_moves(self, player: str) -> List[str]:
        moves = []
        opp = 'W' if player == 'B' else 'B'
        dirs = [(-1, 0), (1, 0), (0, -1), (0, 1)]
        for r in range(self.rows):
            for c in range(self.cols):
                if self.board[r][c] == player:
                    for dr, dc in dirs:
                        nr, nc = r+dr, c+dc
                        if 0 <= nr < self.rows and 0 <= nc < self.cols and self.board[nr][nc] == opp:
                            src = coords_to_notation(r, c)
                            dst = coords_to_notation(nr, nc)
                            moves.append(src + dst)
        return moves

    def apply_move(self, move: str):
        (r1, c1), (r2, c2) = notation_to_index(move, self.rows, self.cols)
        self.board[r2][c2] = self.current
        self.board[r1][c1] = '_'
        self.current = 'W' if self.current == 'B' else 'B'

    def __str__(self):
        lines = []
        for r in range(self.rows):
            row = []
            for c in range(self.cols):
                cell = self.board[r][c] or '_'
                row.append(cell)
            lines.append(' '.join(row))
        board_str = '\n'.join(lines)
        cols_lbl = '  ' + ' '.join(chr(ord('a')+c) for c in range(self.cols))
        rows_with_lbl = []
        for i, line in enumerate(lines):
            r_num = str(self.rows - 1 - i)
            rows_with_lbl.append(f"{r_num} {line}")
        return '\n'.join([cols_lbl] + rows_with_lbl)
