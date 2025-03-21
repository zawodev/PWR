import heapq
import time
import math
from core.transit_graph import TransitGraph
from utils.geometry import haversine

class PathFinder:
    def __init__(self, graph: TransitGraph, avg_speed_kmh: float = 20.0):
        self.graph = graph
        # średnia prędkość w km/s, przydatna do heurystyki A*
        self.avg_speed = avg_speed_kmh / 3600.0

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
        """
        Wyszukiwanie najkrótszej ścieżki wg czasu przy użyciu algorytmu Dijkstry.
        """
        start = time.time()
        counter = 0
        # Struktura: (koszt, counter, current_time, stop, current_line, path)
        heap = [(0, counter, start_time, start_stop, None, [])]
        visited = dict()  # (stop, current_line): cost

        while heap:
            cost, _, current_time, stop, current_line, path = heapq.heappop(heap)
            if (stop, current_line) in visited and visited[(stop, current_line)] <= cost:
                continue
            visited[(stop, current_line)] = cost
            if stop == target_stop:
                comp_time = time.time() - start
                return path, cost, comp_time

            for conn in self.graph.get_connections_from(stop, current_time):
                wait = conn.departure_time - current_time
                travel = conn.arrival_time - conn.departure_time
                new_cost = cost + wait + travel
                counter += 1
                heapq.heappush(heap, (new_cost, counter, conn.arrival_time, conn.end_stop, conn.line, path + [conn]))
        comp_time = time.time() - start
        return None, float('inf'), comp_time

    def a_star_time(self, start_stop: str, target_stop: str, start_time: int):
        """
        Wyszukiwanie A* wg minimalizacji czasu.
        """
        start = time.time()
        counter = 0
        h = self.heuristic_time(start_stop, target_stop)
        # Struktura: (f, counter, g, current_time, stop, current_line, path)
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

            for conn in self.graph.get_connections_from(stop, current_time):
                wait = conn.departure_time - current_time
                travel = conn.arrival_time - conn.departure_time
                new_g = g + wait + travel
                new_h = self.heuristic_time(conn.end_stop, target_stop)
                counter += 1
                heapq.heappush(heap, (new_g + new_h, counter, new_g, conn.arrival_time, conn.end_stop, conn.line, path + [conn]))
        comp_time = time.time() - start
        return None, float('inf'), comp_time

    def a_star_transfers(self, start_stop: str, target_stop: str, start_time: int):
        """
        Wyszukiwanie A* wg minimalizacji liczby przesiadek.
        Pierwszy kurs nie liczy się jako przesiadka – heurystyka ustawiona na 0.
        """
        start = time.time()
        counter = 0
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

            for conn in self.graph.get_connections_from(stop, current_time):
                transfer_cost = 0
                if current_line is not None and conn.line != current_line:
                    transfer_cost = 1
                new_g = g + transfer_cost
                counter += 1
                heapq.heappush(heap, (new_g, counter, new_g, conn.arrival_time, conn.end_stop, conn.line, path + [conn]))
        comp_time = time.time() - start
        return None, float('inf'), comp_time

    def optimized_a_star(self, start_stop: str, target_stop: str, start_time: int, mode='time'):
        """
        Ulepszona wersja A* wykorzystująca odpowiednią heurystykę zależnie od trybu.
        Parametr mode: 'time' lub 'transfers'.
        """
        start = time.time()
        counter = 0
        h = self.heuristic_time(start_stop, target_stop) if mode == 'time' else 0
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

            for conn in self.graph.get_connections_from(stop, current_time):
                counter += 1
                if mode == 'time':
                    wait = conn.departure_time - current_time
                    travel = conn.arrival_time - conn.departure_time
                    new_g = g + wait + travel
                    new_h = self.heuristic_time(conn.end_stop, target_stop)
                else:
                    transfer_cost = 0
                    if current_line is not None and conn.line != current_line:
                        transfer_cost = 1
                    new_g = g + transfer_cost
                    new_h = 0
                new_f = new_g + new_h
                heapq.heappush(heap, (new_f, counter, new_g, conn.arrival_time, conn.end_stop, conn.line, path + [conn]))
        comp_time = time.time() - start
        return None, float('inf'), comp_time
