import time
from core.pathfinder import PathFinder

class TabuSearchTSP:
    def __init__(self, graph, pathfinder: PathFinder, mode='t'):
        """
        mode: 't' lub 'time' – minimalizacja czasu,
              'p' lub 'transfers' – minimalizacja liczby przesiadek.
        """
        self.graph = graph
        self.pathfinder = pathfinder
        self.mode = mode.lower()

    def compute_cost_between(self, start, end, start_time):
        """Wyznacza koszt przejazdu pomiędzy dwoma przystankami."""
        if self.mode in ('t', 'time'):
            _, cost, _ = self.pathfinder.a_star_time(start, end, start_time)
        elif self.mode in ('p', 'transfers'):
            _, cost, _ = self.pathfinder.a_star_transfers(start, end, start_time)
        else:
            raise ValueError("Nieznany tryb optymalizacji")
        return cost

    def build_cost_matrix(self, stops: list, start_time: int):
        """
        Buduje macierz kosztów między zadanymi przystankami.
        Zakładamy, że opóźnienia (czasy oczekiwania) są pomijalne przy obliczaniu heurystyki TSP.
        """
        n = len(stops)
        cost_matrix = [[0] * n for _ in range(n)]
        for i in range(n):
            for j in range(n):
                if i == j:
                    cost_matrix[i][j] = 0
                else:
                    cost_matrix[i][j] = self.compute_cost_between(stops[i], stops[j], start_time)
        return cost_matrix

    def tour_cost(self, solution, cost_matrix):
        """Oblicza łączny koszt trasy przy danej permutacji – zakładamy trasę cykliczną."""
        total = 0
        n = len(solution)
        for i in range(n - 1):
            total += cost_matrix[solution[i]][solution[i + 1]]
        total += cost_matrix[solution[-1]][solution[0]]
        return total

    def get_neighbors(self, solution):
        """Generuje sąsiedztwo przez swap dwóch elementów (pomijamy start na pozycji 0)."""
        neighbors = []
        n = len(solution)
        for i in range(1, n):
            for j in range(i + 1, n):
                new_sol = solution[:]
                new_sol[i], new_sol[j] = new_sol[j], new_sol[i]
                neighbors.append(new_sol)
        return neighbors

    def solve(self, start_stop: str, stops_to_visit: list, start_time: int, max_iter=100, tabu_size=None):
        """
        Rozwiązuje problem TSP z zadanymi przystankami używając Tabu Search.
        Trasa: A -> lista przystanków -> A.
        """
        nodes = [start_stop] + stops_to_visit
        n = len(nodes)
        cost_matrix = self.build_cost_matrix(nodes, start_time)

        # Inicjalna permutacja – start na pozycji 0
        current_solution = list(range(n))
        best_solution = current_solution[:]
        best_cost = self.tour_cost(current_solution, cost_matrix)
        tabu_list = []
        if tabu_size is None:
            tabu_size = len(stops_to_visit)

        iter_no_improve = 0
        iter_total = 0
        start_iter = time.time()
        while iter_total < max_iter and iter_no_improve < max_iter // 2:
            neighbors = self.get_neighbors(current_solution)
            improved = False
            for sol in neighbors:
                move = sol  # reprezentacja ruchu – cała permutacja
                cost = self.tour_cost(sol, cost_matrix)
                if move not in tabu_list and cost < best_cost:
                    current_solution = sol
                    best_solution = sol
                    best_cost = cost
                    tabu_list.append(move)
                    if len(tabu_list) > tabu_size:
                        tabu_list.pop(0)
                    improved = True
                    break
            if not improved:
                iter_no_improve += 1
            else:
                iter_no_improve = 0
            iter_total += 1
        comp_time = time.time() - start_iter
        return best_solution, best_cost, comp_time, nodes, cost_matrix
