import argparse
import logging
import sys

from clobber_app.game import GameState
from clobber_app.logger_config import setup_logger
from clobber_app.players import HumanPlayer, RandomAgent, MinimaxAgent

def parse_args():
    parser = argparse.ArgumentParser(description="Clobber Game")
    parser.add_argument("--rows", type=int, default=5, help="Number of rows (max 10)")
    parser.add_argument("--cols", type=int, default=6, help="Number of cols (max 10)")
    parser.add_argument("--mode", choices=["pvc","cvc"], default="pvc")
    parser.add_argument("--agent1", choices=["human","random","smart"], default="human")
    parser.add_argument("--h1", choices=["material","mobility","combined"], default="material")
    parser.add_argument("--d1", type=int, default=3)
    parser.add_argument("--agent2", choices=["human","random","smart"], default="smart")
    parser.add_argument("--h2", choices=["material","mobility","combined"], default="combined")
    parser.add_argument("--d2", type=int, default=3)
    parser.add_argument("--no-color", action="store_true", help="Disable colored output")
    parser.add_argument("--verbose", action="store_true", help="Enable debug logging")
    return parser.parse_args()

def interactive_args():
    print("No CLI arguments detected. Switching to interactive input mode.")
    rows = int(input("Enter number of rows (max 10) [5]: ") or 5)
    cols = int(input("Enter number of cols (max 10) [6]: ") or 6)
    mode = input("Enter mode (pvc or cvc) [pvc]: ") or "pvc"

    agent1 = input("Agent1 type (human, random, smart) [human]: ") or "human"
    h1     = input("Agent1 heuristic (material, mobility, combined) [material]: ") or "material"
    d1     = int(input("Agent1 search depth [3]: ") or 3)

    agent2 = input("Agent2 type (human, random, smart) [smart]: ") or "smart"
    h2     = input("Agent2 heuristic (material, mobility, combined) [combined]: ") or "combined"
    d2     = int(input("Agent2 search depth [3]: ") or 3)

    verbose = input("Verbose output? (y/N): ").strip().lower().startswith('y')

    class Args: pass
    args = Args()
    args.rows = rows
    args.cols = cols
    args.mode = mode
    args.agent1, args.h1, args.d1 = agent1, h1, d1
    args.agent2, args.h2, args.d2 = agent2, h2, d2
    args.no_color, args.verbose = False, verbose
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
            print(f"\nRound {rounds+1} – player {state.current}")
            print(state)

        move = players[state.current].select_move(state)
        state.apply_move(move)
        rounds += 1

    print("\nFinal position:")
    print(state)
    winner = "W" if state.current == "B" else "B"
    print(f"\nRounds: {rounds}, Winner: {winner}")

if __name__ == "__main__":
    main()
