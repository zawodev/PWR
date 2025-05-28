import math
from clobber_app.game import GameState

INF = float('inf')

def _terminal_value(state: GameState, player: str):
    opp = 'W' if player == 'B' else 'B'
    if state.current == player and state.is_terminal():
        return -INF
    if state.current == opp and state.is_terminal():
        return INF

    return None

def mobility(state: GameState, player: str):
    term = _terminal_value(state, player)
    if term is not None:
        return term

    num = state.count_attacked_enemy_pieces(player)
    if num == 0:
        return -INF  # no moves available, very bad situation (shouldnt be possible but just to be safe)

    if num % 2 == 1:
        return 1.0 / num

    return -(1.0 / num)

def opponent_mobility(state: GameState, player: str) -> float:
    term = _terminal_value(state, player)
    if term is not None:
        return term
    opp = 'W' if player == 'B' else 'B'
    num = state.count_attacked_enemy_pieces(opp)
    # im mniej ruchów ma przeciwnik, tym większy wynik
    return 1.0 / (1 + num)

def centrality(state: GameState, player: str) -> float:
    term = _terminal_value(state, player)
    if term is not None:
        return term

    rows, cols = state.rows, state.cols
    center_r = (rows - 1) / 2
    center_c = (cols - 1) / 2
    max_dist = math.hypot(center_r, center_c)

    def score_for(p_char: str) -> float:
        total = 0.0
        for r in range(rows):
            for c in range(cols):
                if state.board[r][c] == p_char:
                    d = math.hypot(r - center_r, c - center_c)
                    total += (max_dist - d) / max_dist
        return total

    me = score_for(player)
    opp = score_for('W' if player == 'B' else 'B')
    return me - opp

def combined(state: GameState, player: str) -> float:
    term = _terminal_value(state, player)
    if term is not None:
        return term

    return mobility(state, player) + opponent_mobility(state, player) + centrality(state, player)

HEURISTICS = {
    'mobility': mobility,
    'opp_mobility': opponent_mobility,
    'centrality': centrality,
    'combined': combined,
}
