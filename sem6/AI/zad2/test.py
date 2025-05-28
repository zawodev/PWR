import math

def centrality(player: str):

    board = [
        ['W', '_', '_', '_', '_', 'W'],
        ['_', '_', '_', '_', '_', '_'],
        ['_', '_', '_', 'B', '_', '_'],
        ['_', '_', '_', '_', '_', '_'],
        ['_', '_', '_', '_', '_', '_'],
        ['W', '_', '_', 'B', '_', 'W'],
    ]
    rows, cols = 6, 6
    center_r = (rows - 1) / 2
    center_c = (cols - 1) / 2
    max_dist = math.hypot(center_r, center_c)

    def score_for(p_char: str) -> float:
        total = 0.0
        for r in range(rows):
            for c in range(cols):
                if board[r][c] == p_char:
                    d = math.hypot(r - center_r, c - center_c)
                    total += (max_dist - d) / max_dist
        return total

    me = score_for(player)
    opp = score_for('W' if player == 'B' else 'B')
    print(me)
    print(opp)

centrality('B')
