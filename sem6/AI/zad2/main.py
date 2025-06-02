import argparse
import sys

from clobber_app.game import GameState
from clobber_app.logger_config import setup_logger
from clobber_app.players import HumanPlayer, RandomAgent, MinimaxAgent
from clobber_app.utils import *

def parse_args():
    parser = argparse.ArgumentParser(description="Clobber Game")
    parser.add_argument("--rows", type=int, default=5, help="Number of rows (max 10)")
    parser.add_argument("--cols", type=int, default=6, help="Number of cols (max 10)")

    parser.add_argument("--agent1", choices=["human", "random", "smart"], default="random")
    parser.add_argument("--h1", choices=["opp_mobility", "mobility", "centrality", "combined"], default="combined")
    parser.add_argument("--d1", type=int, default=4)

    parser.add_argument("--agent2", choices=["human", "random", "smart"], default="smart")
    parser.add_argument("--h2", choices=["opp_mobility", "mobility", "centrality", "combined"], default="combined")
    parser.add_argument("--d2", type=int, default=4)

    parser.add_argument("--verbose", action="store_true", help="Enable debug logging")
    return parser.parse_args()

def interactive_args():
    print("No CLI arguments detected. Switching to interactive input mode.")
    rows = int(input("Enter number of rows (max 10) [5]: ") or 5)
    cols = int(input("Enter number of cols (max 10) [6]: ") or 6)

    agent1 = input("Agent1 type (human, random, smart) [random]: ") or "random"
    h1 = input("Agent1 heuristic (opp_mobility, mobility, centrality, combined) [combined]: ") or "combined"
    d1 = int(input("Agent1 search depth [4]: ") or 4)

    agent2 = input("Agent2 type (human, random, smart) [smart]: ") or "smart"
    h2 = input("Agent2 heuristic (opp_mobility, mobility, centrality, combined) [combined]: ") or "combined"
    d2 = int(input("Agent2 search depth [4]: ") or 4)

    verbose = input("Verbose output? (y/N) [N]: ").strip().lower().startswith('y') or False

    class Args:
        pass

    args = Args()
    args.rows = rows
    args.cols = cols
    args.agent1, args.h1, args.d1 = agent1, h1, d1
    args.agent2, args.h2, args.d2 = agent2, h2, d2
    args.verbose = verbose
    return args

def make_player(kind, name, heuristic, depth):
    if kind == "human":
        return HumanPlayer(name)
    if kind == "random":
        return RandomAgent(name)
    # smart
    return MinimaxAgent(name, heuristic, depth)

def main():
    if len(sys.argv) == 1:
        args = interactive_args()
    else:
        args = parse_args()

    logger = setup_logger(args.verbose)

    state = GameState(rows=args.rows, cols=args.cols)
    p1 = make_player(args.agent1, "P1", args.h1, args.d1)
    p2 = make_player(args.agent2, "P2", args.h2, args.d2)
    players = {"B": p1, "W": p2}

    rounds = 0
    while not state.is_terminal():
        if not state.get_legal_moves(state.current):
            break

        if args.verbose:
            print("\n" + Style.BRIGHT + "--------   Runda %d   ---------" % (rounds+1) + Style.RESET_ALL)
            print_board_colored(state)
            announce_turn(state)

        move = players[state.current].select_move(state)
        state.apply_move(move)
        rounds += 1

    # game finished
    print("\n" + Style.BRIGHT + "--------   Koniec gry   ---------" + Style.RESET_ALL)
    print_board_colored(state)
    winner = "W" if state.current == "B" else "B"
    announce_winner(winner)
    print(f"Liczba rund: {rounds}")

if __name__ == "__main__":
    main()
