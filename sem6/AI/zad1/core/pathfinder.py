import heapq
import time
import math
from core.transit_graph import TransitGraph
from utils.geometry import haversine

class PathFinder:
    def __init__(self, graph: TransitGraph, avg_speed_kmh: float = 20.0, transfer_threshold: int = 300):
        self.graph = graph
        # Średnia prędkość w km/s, przydatna do heurystyki A*
        self.avg_speed = avg_speed_kmh / 3600.0
        # Próg w sekundach – jeżeli czas oczekiwania przekracza ten próg, nawet ta sama linia liczy się jako przesiadka.
        self.transfer_threshold = transfer_threshold

    def heuristic_time(self, current_stop: str, target_stop: str) -> float:
        """
        Heurystyka A* dla minimalizacji czasu – dystans / prędkość.
        """
        if current_stop not in self.graph.stops_coords or target_stop not in self.graph.stops_coords:
            return 0
        lat1, lon1 = self.graph.stops_coords[current_stop]
        lat2, lon2 = self.graph.stops_coords[target_stop]
        distance = haversine(lat1, lon1, lat2, lon2)
        return distance / self.avg_speed

    def dijkstra_time(self, start_stop: str, target_stop: str, start_time: int):
        start = time.time()
        counter = 0
        # Elementy: (koszt, counter, current_time, stop, current_line, path)
        heap = [(0, counter, start_time, start_stop, None, [])]
        visited = dict()

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

    def a_star_time(self, start_stop: str, target_stop: str, start_time: int):
        start = time.time()
        counter = 0
        h = self.heuristic_time(start_stop, target_stop)
        # Elementy: (f, counter, g, current_time, stop, current_line, path)
        heap = [(h, counter, 0, start_time, start_stop, None, [])]
        visited = dict()

        while heap:
            f, _, g, current_time, stop, current_line, path = heapq.heappop(heap)
            if (stop, current_line) in visited and visited[(stop, current_line)] <= g:
                continue
            visited[(stop, current_line)] = g
            if stop == target_stop:
                comp_time = time.time() - start
                return path, g, comp_time

            for conn, eff_dep, eff_arr in self.graph.get_connections_from(stop, current_time):
                wait = eff_dep - current_time
                travel = eff_arr - eff_dep
                new_g = g + wait + travel
                new_h = self.heuristic_time(conn.end_stop, target_stop)
                counter += 1
                heapq.heappush(heap, (new_g + new_h, counter, new_g, eff_arr, conn.end_stop, conn.line, path + [conn]))
        comp_time = time.time() - start
        return None, float('inf'), comp_time

    def a_star_transfers(self, start_stop: str, target_stop: str, start_time: int):
        start = time.time()
        counter = 0
        # Elementy: (f, counter, g, current_time, stop, current_line, path)
        heap = [(0, counter, 0, start_time, start_stop, None, [])]
        visited = dict()

        while heap:
            f, _, g, current_time, stop, current_line, path = heapq.heappop(heap)
            if (stop, current_line) in visited and visited[(stop, current_line)] <= g:
                continue
            visited[(stop, current_line)] = g
            if stop == target_stop:
                comp_time = time.time() - start
                return path, g, comp_time

            for conn, eff_dep, eff_arr in self.graph.get_connections_from(stop, current_time):
                wait = eff_dep - current_time
                # Jeśli jedziemy już jakąś linią...
                if current_line is not None:
                    # Jeżeli to ta sama linia, ale czas oczekiwania przekracza próg,
                    # uznajemy to za przesiadkę
                    if conn.line == current_line:
                        transfer_cost = 1 if wait > self.transfer_threshold else 0
                    else:
                        transfer_cost = 1
                else:
                    transfer_cost = 0
                new_g = g + transfer_cost
                counter += 1
                heapq.heappush(heap, (new_g, counter, new_g, eff_arr, conn.end_stop, conn.line, path + [conn]))
        comp_time = time.time() - start
        return None, float('inf'), comp_time

    def optimized_a_star(self, start_stop: str, target_stop: str, start_time: int, mode='time'):
        start = time.time()
        counter = 0
        if mode in ('t', 'time'):
            h = self.heuristic_time(start_stop, target_stop)
        else:
            h = 0
        heap = [(h, counter, 0, start_time, start_stop, None, [])]
        visited = dict()

        while heap:
            f, _, g, current_time, stop, current_line, path = heapq.heappop(heap)
            key = (stop, current_line)
            if key in visited and visited[key] <= g:
                continue
            visited[key] = g
            if stop == target_stop:
                comp_time = time.time() - start
                return path, g, comp_time

            for conn, eff_dep, eff_arr in self.graph.get_connections_from(stop, current_time):
                counter += 1
                if mode in ('t', 'time'):
                    wait = eff_dep - current_time
                    travel = eff_arr - eff_dep
                    new_g = g + wait + travel
                    new_h = self.heuristic_time(conn.end_stop, target_stop)
                else:
                    wait = eff_dep - current_time
                    if current_line is not None:
                        if conn.line == current_line:
                            new_transfer = 1 if wait > self.transfer_threshold else 0
                        else:
                            new_transfer = 1
                    else:
                        new_transfer = 0
                    new_g = g + new_transfer
                    new_h = 0
                new_f = new_g + new_h
                heapq.heappush(heap, (new_f, counter, new_g, eff_arr, conn.end_stop, conn.line, path + [conn]))
        comp_time = time.time() - start
        return None, float('inf'), comp_time
