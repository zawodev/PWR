from typing import Callable

def material_count(state, player: str) -> int:
    own = sum(row.count(player) for row in state.board)
    opp = sum(row.count('W' if player=='B' else 'B') for row in state.board)
    return own - opp

def mobility(state, player: str) -> int:
    opp = 'W' if player=='B' else 'B'
    return len(state.get_legal_moves(player)) - len(state.get_legal_moves(opp))

def combined(state, player: str) -> float:
    return material_count(state, player) + 0.5 * mobility(state, player)

HEURISTICS = {
    'material': material_count,
    'mobility': mobility,
    'combined': combined,
}
