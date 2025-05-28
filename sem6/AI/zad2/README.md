# Clobber AI

This project implements the Clobber board game (default 5x6, up to 10x10) with support for:
- Human vs Computer (pvc) and Computer vs Computer (cvc)
- Two AI agents: random and smart (minimax w/ alpha-beta)
- Configurable heuristics (4 different strategies)
- CLI/GUI options for board size, mode, agent types, heuristic choice, search depth, and live board logging

## Usage

```bash
python main.py [--rows 5] [--cols 6] [--mode pvc] \
               [--agent1 smart --h1 material --d1 4] \
               [--agent2 random --h2 none --d2 1] \
               [--verbose]
