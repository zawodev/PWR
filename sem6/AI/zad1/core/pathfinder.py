import heapq
import time
import math
from core.transit_graph import TransitGraph
from utils.geometry import haversine
from logger import Logger

class PathFinder:
    def __init__(self, graph: TransitGraph, logger: Logger, avg_speed_kmh: float = 20.0, transfer_threshold: int = 300):
        self.graph = graph
        self.logger = logger
        self.avg_speed = avg_speed_kmh / 3600.0
        self.transfer_threshold = transfer_threshold

    def heuristic_time(self, current_stop: str, target_stop: str) -> float:
        if current_stop not in self.graph.stops_coords or target_stop not in self.graph.stops_coords:
            return 0
        lat1, lon1 = self.graph.stops_coords[current_stop]
        lat2, lon2 = self.graph.stops_coords[target_stop]
        distance = haversine(lat1, lon1, lat2, lon2)
        return distance / self.avg_speed

    def dijkstra_time(self, start_stop: str, target_stop: str, start_time: int):
        # (Można zostawić – jeżeli potrzebna; w przeciwnym razie można usunąć)
        start = time.time()
        counter = 0
        heap = [(0, counter, start_time, start_stop, None, [])]
        visited = {}
        while heap:
            cost, _, current_time, stop, current_line, path = heapq.heappop(heap)
            if (stop, current_line) in visited and visited[(stop, current_line)] <= cost:
                continue
            visited[(stop, current_line)] = cost
            if stop == target_stop:
                comp_time = time.time() - start
                return path, cost, comp_time
            for conn, eff_dep, eff_arr in self.graph.get_connections_from(stop, current_time):
                wait = eff_dep - current_time
                travel = eff_arr - eff_dep
                new_cost = cost + wait + travel
                counter += 1
                heapq.heappush(heap, (new_cost, counter, eff_arr, conn.end_stop, conn.line, path + [conn]))
        comp_time = time.time() - start
        return None, float('inf'), comp_time

    def optimized_a_star(self, start_stop: str, target_stop: str, start_time: int, mode='time'):
        """
        Algorytm A* działający w dwóch trybach:
         - mode 'time': optymalizacja czasu (koszt = czas przejazdu)
         - mode 'transfers': optymalizacja liczby przesiadek (koszt = liczba przesiadek * L + czas przyjazdu)
        """
        start = time.time()
        self.logger.log("Rozpoczęcie wyszukiwania trasy")
        counter = 0
        L = 1000000  # duża stała, która priorytetowo traktuje zmianę linii
        if mode in ('t', 'time'):
            h = self.heuristic_time(start_stop, target_stop)
        else:
            h = 0
        heap = [(h, counter, 0, start_time, start_stop, None, [])]
        visited = {}
        while heap:
            f, _, g, current_time, stop, current_line, path = heapq.heappop(heap)
            key = (stop, current_line)
            if key in visited and visited[key] <= g:
                continue
            visited[key] = g
            if stop == target_stop:
                comp_time = time.time() - start
                self.logger.log("Znaleziono trasę")
                return path, g, comp_time
            for conn, eff_dep, eff_arr in self.graph.get_connections_from(stop, current_time):
                counter += 1
                if mode in ('t', 'time'):
                    wait = eff_dep - current_time
                    travel = eff_arr - eff_dep
                    new_g = g + wait + travel
                    new_h = self.heuristic_time(conn.end_stop, target_stop)
                    new_f = new_g + new_h
                else:
                    wait = eff_dep - current_time
                    if current_line is None:
                        additional = 0
                    else:
                        if conn.line == current_line:
                            additional = 1 if wait > self.transfer_threshold else 0
                        else:
                            additional = 1
                    new_g = g + additional
                    new_f = new_g * L + eff_arr
                heapq.heappush(heap, (new_f, counter, new_g, eff_arr, conn.end_stop, conn.line, path + [conn]))
        comp_time = time.time() - start
        self.logger.log("Nie znaleziono trasy")
        return None, float('inf'), comp_time
