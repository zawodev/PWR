import csv
from collections import defaultdict
from utils.time_utils import time_to_seconds

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
    def __init__(self, csv_path: str):
        self.connections_by_stop = defaultdict(list)
        self.stops_coords = dict()  # dla heurystyki A* (współrzędne przystanków)
        self._load_csv(csv_path)

    def _load_csv(self, csv_path: str):
        with open(csv_path, newline='', encoding='utf-8') as csvfile:
            reader = csv.DictReader(csvfile)
            for row in reader:
                conn = Connection(row)
                self.connections_by_stop[conn.start_stop].append(conn)
                # Zapisujemy współrzędne – zakładamy stałość lokalizacji
                self.stops_coords[conn.start_stop] = (conn.start_stop_lat, conn.start_stop_lon)
                self.stops_coords[conn.end_stop] = (conn.end_stop_lat, conn.end_stop_lon)
        # Sortujemy połączenia wg oryginalnego czasu odjazdu
        for stop in self.connections_by_stop:
            self.connections_by_stop[stop].sort(key=lambda c: c.departure_time)

    def get_connections_from(self, stop: str, current_time: int):
        """
        Zwraca listę połączeń z danego przystanku, 
        przeliczając efektywny czas odjazdu/ przyjazdu z uwzględnieniem, że rozkład się powtarza codziennie.
        Jeśli oryginalny czas połączenia (departure_time) jest mniejszy niż (current_time % 86400),
        to traktujemy to jako połączenie następnego dnia (dodajemy 86400 sekund).
        """
        result = []
        for conn in self.connections_by_stop.get(stop, []):
            eff_dep = conn.departure_time
            eff_arr = conn.arrival_time
            # Przeliczenie modulo bieżącego dnia
            current_day_time = current_time % 86400
            if eff_dep < current_day_time:
                eff_dep += 86400
                eff_arr += 86400
            # Jeśli efektywny czas odjazdu jest nadal mniejszy niż current_time, to dodajemy kolejny dzień
            if eff_dep < current_time:
                eff_dep += 86400
                eff_arr += 86400
            if eff_dep >= current_time:
                result.append((conn, eff_dep, eff_arr))
        return result
