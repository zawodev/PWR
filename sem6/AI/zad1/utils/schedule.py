import sys
from utils.time_utils import seconds_to_time

def print_schedule(path):
    for conn in path:
        sys.stdout.write(
            f"Linia: {conn.line}, wsiadamy: {seconds_to_time(conn.departure_time)} na {conn.start_stop}, "
            f"wysiadamy: {seconds_to_time(conn.arrival_time)} na {conn.end_stop}\n"
        )
