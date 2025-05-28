import math
import copy
from clobber_app.heuristics import HEURISTICS
from clobber_app.utils import timing

class SearchResult:
    def __init__(self, move=None, value=None, stats=None):
        self.move = move
        self.value = value
        self.stats = stats or {'nodes': 0, 'time': 0}

@timing
def minimax_decision(state, depth, player, heuristic_fn, alpha_beta=False):
    stats = {'nodes': 0}

    def max_value(s, d, alpha, beta):
        stats['nodes'] += 1
        if d == 0 or s.is_terminal():
            return heuristic_fn(s, player)
        v = -math.inf
        for m in s.get_legal_moves(s.current):
            s2 = copy.deepcopy(s)
            s2.apply_move(m)
            val = min_value(s2, d-1, alpha, beta)
            v = max(v, val)
            if alpha_beta:
                alpha = max(alpha, v)
                if alpha >= beta:
                    break
        return v

    def min_value(s, d, alpha, beta):
        stats['nodes'] += 1
        if d == 0 or s.is_terminal():
            return heuristic_fn(s, player)
        v = math.inf
        for m in s.get_legal_moves(s.current):
            s2 = copy.deepcopy(s)
            s2.apply_move(m)
            val = max_value(s2, d-1, alpha, beta)
            v = min(v, val)
            if alpha_beta:
                beta = min(beta, v)
                if beta <= alpha:
                    break
        return v

    best_val, best_move = -math.inf, None
    for m in state.get_legal_moves(player):
        s2 = copy.deepcopy(state)
        s2.apply_move(m)
        val = min_value(s2, depth-1, -math.inf, math.inf)
        if val > best_val:
            best_val, best_move = val, m

    return SearchResult(best_move, best_val, stats)
