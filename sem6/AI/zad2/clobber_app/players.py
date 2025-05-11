import random
import logging
from clobber_app.search import minimax_decision
from clobber_app.heuristics import HEURISTICS

class Player:
    def __init__(self, name: str): self.name = name
    def select_move(self, state): raise NotImplementedError

class HumanPlayer(Player):
    def select_move(self, state):
        moves = state.get_legal_moves(state.current)
        return input(f"{moves}\nChoose move: ")

class RandomAgent(Player):
    def select_move(self, state):
        return random.choice(state.get_legal_moves(state.current))

class MinimaxAgent(Player):
    def __init__(self, name: str, heuristic: str, depth: int, alpha_beta: bool = True):
        super().__init__(name)
        self.heur_fn = HEURISTICS[heuristic]
        self.depth = depth
        self.alpha_beta = alpha_beta
        self.logger = logging.getLogger('clobber')

    def select_move(self, state):
        result = minimax_decision(
            state, self.depth, state.current,
            self.heur_fn, alpha_beta=self.alpha_beta
        )
        self.logger.info(f"{self.name} nodes={result.stats['nodes']} time={result.stats['time']:.3f}s")
        return result.move
