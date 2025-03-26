#!/usr/bin/env python3
"""
main.py

Program, który – w zależności od formatu drugiej zmiennej (zawierającej średnik lub nie) – wykonuje:
    - Zadanie 1: wyszukiwanie najkrótszych połączeń między dwoma przystankami A i B,
      przy czym kryterium optymalizacji może być czas lub liczba przesiadek.
    - Zadanie 2: wyszukiwanie najkrótszej trasy odwiedzającej listę przystanków L (TSP)
      przy zachowaniu warunku powrotu do przystanku A, z funkcją kosztu opartą na czasie lub liczbie przesiadek.
Wyniki (harmonogram przejazdu) wypisywane są na standardowe wyjście, a na stderr – wartość funkcji kosztu
oraz czas obliczeń (od wczytania danych do uzyskania rozwiązania).

Na każdym etapie używany jest logger wypisujący informację o postępie obliczeń wraz z czasem (sekundy od startu).
"""

import sys
import csv
import time
import math
import logging
from collections import defaultdict, deque
from heapq import heappush, heappop
import random

# =============================================================================
# logger.py - moduł pomocniczy do logowania postępu
# =============================================================================

class Logger:
    def __init__(self):
        self.start_time = time.time()
        logging.basicConfig(level=logging.INFO, format="%(message)s")
        self.logger = logging.getLogger("JourneyPlanner")

    def log(self, message: str):
        elapsed = time.time() - self.start_time
        self.logger.info(f"[{elapsed:.2f} s] {message}")

# =============================================================================
# graph.py - moduł reprezentujący graf i wczytujący dane
# =============================================================================

class Connection:
    def __init__(self, connection_id, company, line, departure_time, arrival_time,
                 start_stop, end_stop, start_lat, start_lon, end_lat, end_lon):
        # Konwersja czasu przy pomocy zmodyfikowanej metody
        self.departure_time = self._time_to_seconds(departure_time)
        self.arrival_time = self._time_to_seconds(arrival_time)
        # Jeśli czas przyjazdu jest mniejszy niż odjazdu, to oznacza, że trzeba czekać do następnego dnia.
        if self.arrival_time < self.departure_time:
            self.arrival_time += 86400  # 24 godziny
        self.connection_id = connection_id
        self.company = company
        self.line = line
        self.start_stop = start_stop
        self.end_stop = end_stop
        self.start_lat = float(start_lat)
        self.start_lon = float(start_lon)
        self.end_lat = float(end_lat)
        self.end_lon = float(end_lon)
        # Obliczamy czas trwania przejazdu
        self.duration = self.arrival_time - self.departure_time

    @staticmethod
    def _time_to_seconds(t: str) -> int:
        """
        Zamienia czas w formacie HH:MM:SS na sekundy.
        Jeśli godzina jest >= 24 (np. "24:13:00"), traktujemy to jako czas następnego dnia.
        """
        parts = t.strip().split(":")
        if len(parts) != 3:
            raise ValueError("Niepoprawny format czasu")
        h, m, s = map(int, parts)
        day_offset = h // 24
        h = h % 24
        seconds = day_offset * 86400 + h * 3600 + m * 60 + s
        return seconds

    def __repr__(self):
        return f"<Conn {self.line} {self.start_stop}->{self.end_stop} dep:{self.departure_time} arr:{self.arrival_time}>"

class Graph:
    def __init__(self, csv_file: str, logger: Logger):
        self.edges = defaultdict(list)  # klucz: start_stop, wartość: lista Connection
        self.stops_coordinates = {}  # współrzędne przystanków
        self.logger = logger
        self.load_data(csv_file)

    def load_data(self, csv_file: str):
        self.logger.log("Wczytywanie danych z pliku CSV")
        with open(csv_file, newline='', encoding="utf-8") as f:
            reader = csv.DictReader(f)
            for row in reader:
                try:
                    conn = Connection(
                        connection_id=row["id"],
                        company=row["company"],
                        line=row["line"],
                        departure_time=row["departure_time"],
                        arrival_time=row["arrival_time"],
                        start_stop=row["start_stop"],
                        end_stop=row["end_stop"],
                        start_lat=row["start_stop_lat"],
                        start_lon=row["start_stop_lon"],
                        end_lat=row["end_stop_lat"],
                        end_lon=row["end_stop_lon"]
                    )
                except Exception as e:
                    self.logger.log(f"Błąd przy przetwarzaniu wiersza: {row} - {e}")
                    continue
                self.edges[conn.start_stop].append(conn)
                # Zapisujemy współrzędne przystanków
                if conn.start_stop not in self.stops_coordinates:
                    self.stops_coordinates[conn.start_stop] = (conn.start_lat, conn.start_lon)
                if conn.end_stop not in self.stops_coordinates:
                    self.stops_coordinates[conn.end_stop] = (conn.end_lat, conn.end_lon)
        self.logger.log("Dane wczytane poprawnie")

    def get_neighbors(self, stop: str):
        return self.edges.get(stop, [])

    def distance_between_stops(self, stop1: str, stop2: str) -> float:
        """
        Obliczamy euklidesową odległość (w przybliżeniu) między dwoma przystankami.
        """
        if stop1 not in self.stops_coordinates or stop2 not in self.stops_coordinates:
            return float('inf')
        lat1, lon1 = self.stops_coordinates[stop1]
        lat2, lon2 = self.stops_coordinates[stop2]
        return math.sqrt((lat1 - lat2) ** 2 + (lon1 - lon2) ** 2)

# =============================================================================
# algorithms.py - moduł implementujący algorytmy wyszukiwania tras
# =============================================================================

class JourneyPlanner:
    def __init__(self, graph: Graph, logger: Logger):
        self.graph = graph
        self.logger = logger
        self.counter = 0  # licznik dla heappush

    def _heappush(self, heap, item):
        """
        Własna metoda heappush, która dodaje element wraz z licznikiem.
        """
        self.counter += 1
        # item: tuple (priorytet, ...); dodajemy counter jako drugi element
        heappush(heap, (item[0], self.counter) + item[1:])

    # ------------------------
    # Zadanie 1 – wyszukiwanie trasy A->B
    # ------------------------

    def plan_route_dijkstra(self, start: str, goal: str, start_time: int) -> (list, float):
        """
        Algorytm Dijkstry optymalizujący czas przejazdu.
        Zwraca: (lista segmentów trasy, całkowity koszt)
        """
        self.logger.log("Uruchomiono Dijkstrę (optymalizacja czasu)")
        queue = []
        self._heappush(queue, (start_time, start, []))  # (aktualny czas, przystanek, lista segmentów)
        visited = {}

        while queue:
            current_time, _, current_stop, path = heappop(queue)
            if current_stop == goal:
                cost = current_time - start_time
                self.logger.log("Cel osiągnięty przez Dijkstrę")
                return path, cost
            if current_stop in visited and visited[current_stop] <= current_time:
                continue
            visited[current_stop] = current_time

            for conn in self.graph.get_neighbors(current_stop):
                if conn.departure_time >= current_time:
                    new_time = conn.arrival_time
                    new_path = path + [conn]
                    self._heappush(queue, (new_time, conn.end_stop, new_path))
        self.logger.log("Brak dostępnej trasy metodą Dijkstry")
        return None, float('inf')

    def plan_route_astar(self, start: str, goal: str, start_time: int, criterion: str) -> (list, float):
        """
        Algorytm A*:
            - criterion == 't': minimalizacja czasu (heurystyka oparta na odległości)
            - criterion == 'p': minimalizacja liczby przesiadek (heurystyka: 0)
        Zwraca: (lista segmentów trasy, całkowity koszt)
        """
        self.logger.log("Uruchomiono A*")
        open_set = []
        self._heappush(open_set, (0, start_time, start, []))  # (f_score, current_time, stop, path)
        visited = {}

        while open_set:
            f_score, _, current_time, current_stop, path = heappop(open_set)
            if current_stop == goal:
                cost = (current_time - start_time) if criterion == 't' else len(path)
                self.logger.log("Cel osiągnięty przez A*")
                return path, cost

            state = (current_stop, current_time)
            if state in visited:
                continue
            visited[state] = True

            for conn in self.graph.get_neighbors(current_stop):
                if conn.departure_time >= current_time:
                    new_time = conn.arrival_time
                    new_path = path + [conn]
                    if criterion == 't':
                        # Heurystyka: euklidesowa odległość * stała (np. 60)
                        h = self.graph.distance_between_stops(conn.end_stop, goal) * 60
                        g = new_time - start_time
                    elif criterion == 'p':
                        h = 0
                        g = len(new_path)
                    else:
                        h = 0
                        g = 0
                    f = g + h
                    self._heappush(open_set, (f, new_time, conn.end_stop, new_path))
        self.logger.log("Brak dostępnej trasy metodą A*")
        return None, float('inf')

    # ------------------------
    # Zadanie 2 – problem trasowania przez listę przystanków (TSP) z Tabu Search
    # ------------------------

    def plan_route_tabu(self, start: str, stops_list: list, start_time: int, criterion: str,
                        max_iter: int = 1000, tabu_tenure: int = 10) -> (list, float):
        """
        Rozwiązanie TSP z wykorzystaniem Tabu Search.
        Początkowe rozwiązanie to: [start] + stops_list + [start].
        Dla każdej pary przystanków wykorzystujemy metodę A*.
        Zwraca: (harmonogram trasy, koszt)
        """
        self.logger.log("Uruchomiono Tabu Search dla problemu TSP")
        nodes = stops_list.copy()
        current_solution = [start] + nodes + [start]
        best_solution = current_solution.copy()
        best_cost, best_schedule = self.evaluate_solution(best_solution, start_time, criterion)
        tabu_list = deque(maxlen=tabu_tenure)
        iter_count = 0

        while iter_count < max_iter:
            neighborhood = []
            for i in range(1, len(current_solution) - 2):
                for j in range(i+1, len(current_solution) - 1):
                    neighbor = current_solution.copy()
                    neighbor[i], neighbor[j] = neighbor[j], neighbor[i]
                    move = (i, j)
                    if move in tabu_list:
                        continue
                    cost, schedule = self.evaluate_solution(neighbor, start_time, criterion)
                    neighborhood.append((cost, neighbor, schedule, move))
            if not neighborhood:
                break
            neighborhood.sort(key=lambda x: x[0])
            best_neighbor_cost, best_neighbor, best_neighbor_schedule, best_move = neighborhood[0]
            if best_neighbor_cost < best_cost:
                best_cost = best_neighbor_cost
                best_solution = best_neighbor.copy()
                best_schedule = best_neighbor_schedule
            current_solution = best_neighbor
            tabu_list.append(best_move)
            iter_count += 1
            if iter_count % 50 == 0:
                self.logger.log(f"Tabu Search iteracja {iter_count} - najlepszy koszt: {best_cost:.2f}")
        self.logger.log("Tabu Search zakończony")
        return best_schedule, best_cost

    def evaluate_solution(self, route: list, start_time: int, criterion: str) -> (float, list):
        """
        Dla danej kolejności przystanków oblicza łączny koszt trasy oraz zbiera harmonogram.
        Łączy segmenty przy użyciu algorytmu A*.
        """
        total_cost = 0
        schedule = []
        current_time = start_time
        for i in range(len(route) - 1):
            segment_start = route[i]
            segment_end = route[i+1]
            path, cost = self.plan_route_astar(segment_start, segment_end, current_time, criterion)
            if path is None:
                return float('inf'), []
            current_time = path[-1].arrival_time
            total_cost += cost
            schedule.extend(path)
        return total_cost, schedule

    def format_schedule(self, schedule: list) -> str:
        """
        Zwraca sformatowany harmonogram przejazdu: nazwa linii, przystanek i godzina odjazdu oraz przystanek i godzina przyjazdu.
        """
        lines = []
        for conn in schedule:
            dep_time = self.seconds_to_time(conn.departure_time)
            arr_time = self.seconds_to_time(conn.arrival_time)
            lines.append(f"Linia {conn.line}: {conn.start_stop} o {dep_time} -> {conn.end_stop} o {arr_time}")
        return "\n".join(lines)

    @staticmethod
    def seconds_to_time(sec: int) -> str:
        h = sec // 3600
        m = (sec % 3600) // 60
        s = sec % 60
        return f"{h:02d}:{m:02d}:{s:02d}"

# =============================================================================
# main.py - logika główna
# =============================================================================

def main():
    logger = Logger()
    start_program = time.time()

    # Wczytujemy graf z pliku CSV
    graph = Graph("connection_graph.csv", logger)
    planner = JourneyPlanner(graph, logger)

    # Odczyt wejścia: 4 linie
    logger.log("Odczyt wejścia")
    start_stop = input("Podaj przystanek początkowy A: ").strip()
    second_var = input("Podaj przystanek końcowy B lub listę przystanków oddzielonych średnikiem: ").strip()
    criterion = input("Podaj kryterium optymalizacyjne ('t' dla czasu, 'p' dla przesiadek): ").strip().lower()
    start_time_str = input("Podaj czas pojawienia się na przystanku (HH:MM:SS): ").strip()
    h, m, s = map(int, start_time_str.split(":"))
    start_time_sec = (h // 24) * 86400 + (h % 24) * 3600 + m * 60 + s

    # Wybór wariantu na podstawie formatu drugiej zmiennej
    if ";" in second_var:
        stops_list = [stop.strip() for stop in second_var.split(";")]
        logger.log("Uruchamianie zadania 2: TSP przez listę przystanków")
        schedule, cost = planner.plan_route_tabu(start_stop, stops_list, start_time_sec, criterion)
    else:
        goal_stop = second_var
        logger.log("Uruchamianie zadania 1: trasa z A do B")
        schedule, cost = planner.plan_route_astar(start_stop, goal_stop, start_time_sec, criterion)

    if schedule is not None:
        output = planner.format_schedule(schedule)
        print(output)
    else:
        print("Nie znaleziono trasy", file=sys.stderr)

    computation_time = time.time() - start_program
    print(f"Koszt rozwiązania: {cost}", file=sys.stderr)
    print(f"Czas obliczeń: {computation_time:.2f} s", file=sys.stderr)
    logger.log("Program zakończony")

if __name__ == "__main__":
    main()
