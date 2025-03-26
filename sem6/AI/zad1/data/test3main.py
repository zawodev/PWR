import sys
import time
import math
import heapq
import csv
import bisect
import logging
from collections import defaultdict

# ================================
# Utils - konwersje czasu i formatowanie harmonogramu
# ================================
def time_to_seconds(time_str: str) -> int:
    parts = time_str.split(':')
    parts = [int(p) for p in parts]
    if len(parts) == 2:
        hours, minutes = parts
        seconds = 0
    else:
        hours, minutes, seconds = parts
    return hours * 3600 + minutes * 60 + seconds

def seconds_to_time(seconds: int) -> str:
    seconds = seconds % 86400
    h = seconds // 3600
    m = (seconds % 3600) // 60
    s = seconds % 60
    return f"{h:02d}:{m:02d}:{s:02d}"

def print_schedule(path):
    for conn in path:
        print(conn)

# ================================
# Logger
# ================================

class Logger:
    def __init__(self):
        self.start_time = time.time()
        logging.basicConfig(level=logging.INFO, format="%(message)s")
        self.logger = logging.getLogger("JourneyPlanner")

    def log(self, message: str):
        elapsed = time.time() - self.start_time
        self.logger.info(f"[{elapsed:.2f} s] {message}")


# ================================
# Utils - geometry (wzór Haversine)
# ================================
def haversine(lat1, lon1, lat2, lon2):
    R = 6371  # km
    phi1 = math.radians(lat1)
    phi2 = math.radians(lat2)
    dphi = math.radians(lat2 - lat1)
    dlambda = math.radians(lon2 - lon1)
    a = math.sin(dphi / 2)**2 + math.cos(phi1)*math.cos(phi2)*math.sin(dlambda / 2)**2
    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
    return R * c

# ================================
# Model - Connection, TransitGraph
# ================================
class Connection:
    def __init__(self, row):
        self.id = row['id']
        self.company = row['company']
        self.line = row['line']
        self.departure_time = time_to_seconds(row['departure_time'])
        self.arrival_time = time_to_seconds(row['arrival_time'])
        self.start_stop = row['start_stop'].lower()
        self.end_stop = row['end_stop'].lower()
        self.start_stop_lat = float(row['start_stop_lat'])
        self.start_stop_lon = float(row['start_stop_lon'])
        self.end_stop_lat = float(row['end_stop_lat'])
        self.end_stop_lon = float(row['end_stop_lon'])

    def __repr__(self):
        return (f"Connection({self.line}: {self.start_stop} ({seconds_to_time(self.departure_time)}) -> "
                f"{self.end_stop} ({seconds_to_time(self.arrival_time)}))")

class TransitGraph:
    def __init__(self, csv_path: str, logger: Logger):
        self.logger = logger
        self.connections_by_stop = defaultdict(list)
        self.edges_by_pair = defaultdict(list)
        self.nodes = defaultdict(set)
        self.stops_coords = {}
        self._load_csv(csv_path)

    def _load_csv(self, csv_path: str):
        self.logger.log("Wczytywanie danych z pliku CSV")
        with open(csv_path, newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                conn = Connection(row)
                self.connections_by_stop[conn.start_stop].append(conn)
                self.edges_by_pair[(conn.start_stop, conn.end_stop)].append(conn)
                self.nodes[conn.start_stop].add(conn.end_stop)
                self.stops_coords[conn.start_stop] = (conn.start_stop_lat, conn.start_stop_lon)
                self.stops_coords[conn.end_stop] = (conn.end_stop_lat, conn.end_stop_lon)
        self.logger.log("Sortowanie połączeń")
        for stop, conns in self.connections_by_stop.items():
            conns.sort(key=lambda c: c.departure_time)
        for key, conns in self.edges_by_pair.items():
            conns.sort(key=lambda c: c.departure_time)
        self.logger.log("Dane wczytane poprawnie")

    def get_best_connection(self, start_stop: str, end_stop: str, current_time: int):
        if (start_stop, end_stop) not in self.edges_by_pair:
            return None
        conns = self.edges_by_pair[(start_stop, end_stop)]
        dep_times = [c.departure_time for c in conns]
        current_day_time = current_time % 86400
        idx = bisect.bisect_left(dep_times, current_day_time)
        if idx < len(conns):
            conn = conns[idx]
            eff_dep = conn.departure_time if conn.departure_time >= current_day_time else conn.departure_time + 86400
            eff_arr = conn.arrival_time if conn.arrival_time >= current_day_time else conn.arrival_time + 86400
            if eff_dep < current_time:
                eff_dep += 86400
                eff_arr += 86400
            if eff_dep >= current_time:
                return conn, eff_dep, eff_arr
        if conns:
            conn = conns[0]
            eff_dep = conn.departure_time + 86400
            eff_arr = conn.arrival_time + 86400
            if eff_dep >= current_time:
                return conn, eff_dep, eff_arr
        return None

# ================================
# PathFinder - wyszukiwanie trasy
# ================================
class PathFinder:
    def __init__(self, graph: TransitGraph, logger: Logger, avg_speed_kmh: float = 20.0, transfer_threshold: int = 300):
        self.graph = graph
        self.logger = logger
        self.avg_speed = avg_speed_kmh / 3600.0  # km/s
        self.transfer_threshold = transfer_threshold

    def heuristic_time(self, current_stop: str, target_stop: str) -> float:
        if current_stop not in self.graph.stops_coords or target_stop not in self.graph.stops_coords:
            return 0
        lat1, lon1 = self.graph.stops_coords[current_stop]
        lat2, lon2 = self.graph.stops_coords[target_stop]
        distance = haversine(lat1, lon1, lat2, lon2)
        return distance / self.avg_speed

    def optimized_a_star(self, start_stop: str, target_stop: str, start_time: int, mode='time'):
        start = time.time()
        self.logger.log("Rozpoczęcie wyszukiwania trasy (A*)")
        counter = 0
        L = 1000000  # stała dla trybu transfers
        initial_h = self.heuristic_time(start_stop, target_stop) if mode in ('t', 'time') else 0
        heap = [(initial_h, counter, 0, start_time, start_stop, None, [])]
        visited = {}
        while heap:
            f, _, g, current_time, stop, current_line, path = heapq.heappop(heap)
            key = (stop, current_line)
            if key in visited and visited[key] <= g:
                continue
            visited[key] = g
            if stop == target_stop:
                comp_time = time.time() - start
                self.logger.log("Znaleziono trasę (A*)")
                return path, g, comp_time
            if stop not in self.graph.nodes:
                continue
            for neighbor in self.graph.nodes[stop]:
                res = self.graph.get_best_connection(stop, neighbor, current_time)
                if res is None:
                    continue
                conn, eff_dep, eff_arr = res
                counter += 1
                if mode in ('t', 'time'):
                    wait = eff_dep - current_time
                    travel = eff_arr - eff_dep
                    new_g = g + wait + travel
                    new_h = self.heuristic_time(neighbor, target_stop)
                    new_f = new_g + new_h
                else:
                    wait = eff_dep - current_time
                    additional = 0 if current_line is None else (1 if (conn.line != current_line or wait > self.transfer_threshold) else 0)
                    new_g = g + additional
                    new_f = new_g * L + eff_arr
                heapq.heappush(heap, (new_f, counter, new_g, eff_arr, neighbor, conn.line, path + [conn]))
        comp_time = time.time() - start
        self.logger.log("Nie znaleziono trasy (A*)")
        return None, float('inf'), comp_time

# ================================
# Tabu Search TSP
# ================================
class TabuSearchTSP:
    def __init__(self, graph: TransitGraph, logger: Logger, pathfinder: PathFinder, mode='t'):
        self.graph = graph
        self.logger = logger
        self.pathfinder = pathfinder
        self.mode = mode.lower()
        self.cost_cache = {}

    def compute_cost_between(self, start, end, start_time):
        key = (start, end, self.mode, start_time)
        if key in self.cost_cache:
            return self.cost_cache[key]
        if self.mode in ('t', 'time'):
            _, cost, _ = self.pathfinder.optimized_a_star(start, end, start_time, mode='time')
        elif self.mode in ('p', 'transfers'):
            _, cost, _ = self.pathfinder.optimized_a_star(start, end, start_time, mode='transfers')
        else:
            raise ValueError("Nieznany tryb optymalizacji")
        self.cost_cache[key] = cost
        return cost

    def build_cost_matrix(self, stops: list, start_time: int):
        self.logger.log("Budowanie macierzy kosztów")
        n = len(stops)
        cost_matrix = [[0] * n for _ in range(n)]
        for i in range(n):
            for j in range(n):
                if i == j:
                    cost_matrix[i][j] = 0
                else:
                    cost_matrix[i][j] = self.compute_cost_between(stops[i], stops[j], start_time)
        self.logger.log("Macierz kosztów zbudowana")
        return cost_matrix

    def tour_cost(self, solution, cost_matrix):
        total = 0
        n = len(solution)
        for i in range(n - 1):
            total += cost_matrix[solution[i]][solution[i + 1]]
        total += cost_matrix[solution[-1]][solution[0]]
        return total

    def get_neighbors(self, solution):
        neighbors = []
        n = len(solution)
        for i in range(1, n):
            for j in range(i + 1, n):
                new_sol = solution[:]
                new_sol[i], new_sol[j] = new_sol[j], new_sol[i]
                neighbors.append(tuple(new_sol))
        return neighbors

    def solve(self, start_stop: str, stops_to_visit: list, start_time: int, max_iter=100, tabu_size=None):
        self.logger.log("Rozpoczęcie rozwiązania problemu TSP")
        nodes = [start_stop] + stops_to_visit
        n = len(nodes)
        cost_matrix = self.build_cost_matrix(nodes, start_time)
        current_solution = tuple(range(n))
        best_solution = current_solution
        best_cost = self.tour_cost(current_solution, cost_matrix)
        tabu_list = []
        if tabu_size is None:
            tabu_size = len(stops_to_visit)
        iter_no_improve = 0
        iter_total = 0
        start_iter = time.time()
        while iter_total < max_iter and iter_no_improve < max_iter // 2:
            neighbors = self.get_neighbors(list(current_solution))
            improved = False
            for sol in neighbors:
                if sol in tabu_list:
                    continue
                cost = self.tour_cost(sol, cost_matrix)
                if cost < best_cost:
                    current_solution = sol
                    best_solution = sol
                    best_cost = cost
                    tabu_list.append(sol)
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
        self.logger.log("Problem TSP rozwiązany")
        return best_solution, best_cost, comp_time, nodes, cost_matrix

# ================================
# Główna funkcja
# ================================
def main():
    csv_path = "connection_graph.csv"
    logger = Logger()
    graph = TransitGraph(csv_path, logger)
    pathfinder = PathFinder(graph, logger, transfer_threshold=300)

    logger.log("Wpisz dane wejściowe: (1) start_stop, (2) target_stops lub pojedynczy target, (3) criterion, (4) start_time")
    input_lines = [input().strip() for _ in range(4)]
    start_total = time.time()  # pomiar czasu od końca wpisywania danych

    leg_summaries = []  # lista podsumowań dla poszczególnych segmentów

    if ";" in input_lines[1]:
        # Tryb TSP
        start_stop = input_lines[0].lower()
        stops_to_visit = [s.strip().lower() for s in input_lines[1].split(";") if s.strip()]
        criterion = input_lines[2].lower()  # 't' lub 'p'
        start_time = time_to_seconds(input_lines[3])
        tabu_solver = TabuSearchTSP(graph, logger, pathfinder, mode=criterion)
        best_solution, tsp_cost, tsp_comp_time, nodes, cost_matrix = tabu_solver.solve(start_stop, stops_to_visit, start_time)

        full_path = []
        total_leg_cost = 0
        total_leg_comp_time = 0
        current_time = start_time
        num_legs = len(best_solution)
        for i in range(num_legs):
            from_index = best_solution[i]
            to_index = best_solution[(i + 1) % num_legs]
            frm = nodes[from_index]
            to = nodes[to_index]
            if criterion in ('t', 'time'):
                path, leg_cost, leg_comp_time = pathfinder.optimized_a_star(frm, to, current_time, mode='time')
            else:
                path, leg_cost, leg_comp_time = pathfinder.optimized_a_star(frm, to, current_time, mode='transfers')
            if path is None:
                sys.stdout.write(f"Nie znaleziono połączenia pomiędzy {frm} a {to}\n")
                return
            full_path.extend(path)
            total_leg_cost += leg_cost
            total_leg_comp_time += leg_comp_time

            # Zapisujemy podsumowanie dla tego segmentu:
            boarding_stop = frm
            alighting_stop = to
            departure_time = seconds_to_time(path[0].departure_time)
            arrival_time = seconds_to_time(path[-1].arrival_time)
            leg_line = path[0].line
            leg_summaries.append((leg_line, boarding_stop, departure_time, alighting_stop, arrival_time))

            current_time = path[-1].arrival_time

        # Wyświetlenie szczegółowego harmonogramu:
        print("Szczegółowy harmonogram trasy:")
        for summary in leg_summaries:
            line, board, dep_time, alight, arr_time = summary
            print(f"Linia {line}: wsiedzenie na {board} o {dep_time} -> wysiedzenie na {alight} o {arr_time}")
        print("\nSzczegółowe połączenia:")
        print_schedule(full_path)

        logger.log(f"Łączny koszt trasy: {total_leg_cost}")
        logger.log(f"Łączny czas obliczeń (A* dla segmentów): {total_leg_comp_time:.4f} s")
    else:
        # Tryb pojedynczego zapytania
        start_stop = input_lines[0].lower()
        target_stop = input_lines[1].lower()
        criterion = input_lines[2].lower()
        start_time = time_to_seconds(input_lines[3])
        if criterion in ('t', 'time'):
            path, cost, comp_time = pathfinder.optimized_a_star(start_stop, target_stop, start_time, mode='time')
        else:
            path, cost, comp_time = pathfinder.optimized_a_star(start_stop, target_stop, start_time, mode='transfers')
        if path is None:
            sys.stdout.write("Nie znaleziono trasy.\n")
            return
        print("Szczegółowe połączenia:")
        print_schedule(path)
        logger.log(f"Koszt trasy: {cost}")
        logger.log(f"Czas obliczeń (A*): {comp_time:.4f} s")

    end_total = time.time()
    total_elapsed = end_total - start_total
    logger.log(f"Łączny czas obliczeń od końca wprowadzania danych do wyświetlenia wyników: {total_elapsed:.4f} s")

if __name__ == "__main__":
    main()
