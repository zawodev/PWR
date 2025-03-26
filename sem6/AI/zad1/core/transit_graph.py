import csv
from collections import defaultdict
from utils.time_utils import time_to_seconds
from logger import Logger

import bisect

class Connection:
    def __init__(self, row):
        self.id = row['id']
        self.company = row['company']
        self.line = row['line']
        self.departure_time = time_to_seconds(row['departure_time'])
        self.arrival_time = time_to_seconds(row['arrival_time'])
        self.start_stop = row['start_stop']
        self.end_stop = row['end_stop']
        self.start_stop_lat = float(row['start_stop_lat'])
        self.start_stop_lon = float(row['start_stop_lon'])
        self.end_stop_lat = float(row['end_stop_lat'])
        self.end_stop_lon = float(row['end_stop_lon'])

    def __repr__(self):
        from utils.time_utils import seconds_to_time
        return (f"Connection({self.line}: {self.start_stop} ({seconds_to_time(self.departure_time)}) -> "
                f"{self.end_stop} ({seconds_to_time(self.arrival_time)}))")

class TransitGraph:
    def __init__(self, csv_path: str, logger: Logger):
        self.logger = logger
        self.connections_by_stop = defaultdict(list)
        self.stops_coords = {}
        self._load_csv(csv_path)

    def _load_csv(self, csv_path: str):
        self.logger.log("Wczytywanie danych z pliku CSV")
        with open(csv_path, newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                conn = Connection(row)
                self.connections_by_stop[conn.start_stop].append(conn)
                self.stops_coords[conn.start_stop] = (conn.start_stop_lat, conn.start_stop_lon)
                self.stops_coords[conn.end_stop] = (conn.end_stop_lat, conn.end_stop_lon)
        # Sortujemy połączenia wg oryginalnego czasu odjazdu
        self.logger.log("Sortowanie połączeń")
        for stop, conns in self.connections_by_stop.items():
            conns.sort(key=lambda c: c.departure_time)
            # Dla szybkiego wyszukiwania zapamiętujemy też listę czasów
            self.connections_by_stop[stop] = (conns, [c.departure_time for c in conns])
        self.logger.log("Dane wczytane poprawnie")

    def get_connections_from(self, stop: str, current_time: int):
        """
        Zwraca listę połączeń z przystanku 'stop', przy czym uwzględniamy, że rozkład się powtarza codziennie.
        Używamy wyszukiwania binarnego dla szybszego odnalezienia pierwszego połączenia po current_time.
        Zwracamy listę krotek: (connection, effective_departure_time, effective_arrival_time)
        """
        result = []
        if stop not in self.connections_by_stop:
            return result
        conns, dep_times = self.connections_by_stop[stop]
        # Obliczamy czas w bieżącym dniu
        current_day_time = current_time % 86400
        # Znajdujemy indeks pierwszego połączenia z departure_time >= current_day_time
        idx = bisect.bisect_left(dep_times, current_day_time)
        # Przetwarzamy połączenia od idx do końca – te z bieżącego dnia
        for c in conns[idx:]:
            eff_dep = c.departure_time if c.departure_time >= current_day_time else c.departure_time + 86400
            eff_arr = c.arrival_time if c.arrival_time >= current_day_time else c.arrival_time + 86400
            if eff_dep < current_time:
                eff_dep += 86400
                eff_arr += 86400
            if eff_dep >= current_time:
                result.append((c, eff_dep, eff_arr))
        # Dodajemy również połączenia z początku dnia (następny dzień)
        for c in conns[:idx]:
            eff_dep = c.departure_time + 86400
            eff_arr = c.arrival_time + 86400
            if eff_dep >= current_time:
                result.append((c, eff_dep, eff_arr))
        return result
