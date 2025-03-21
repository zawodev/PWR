import sys
from core.transit_graph import TransitGraph
from core.pathfinder import PathFinder
from core.tabu_search_tsp import TabuSearchTSP
from utils.time_utils import time_to_seconds
from utils.schedule import print_schedule

def main():
    # Ścieżka do pliku CSV – zmodyfikuj według potrzeb
    csv_path = "data/connection_graph.csv"
    graph = TransitGraph(csv_path)
    # Możemy podać próg dla przesiadki np. 300 sekund (5 minut)
    pathfinder = PathFinder(graph, transfer_threshold=300)

    # Wczytanie 4 linii wejścia
    input_lines = []
    for _ in range(4):
        input_lines.append(input().strip())

    if ";" in input_lines[1]:
        # Zadanie 2
        start_stop = input_lines[0]
        stops_to_visit = [s.strip() for s in input_lines[1].split(";") if s.strip()]
        criterion = input_lines[2].lower()  # 't' lub 'p'
        start_time = time_to_seconds(input_lines[3])
        tabu_solver = TabuSearchTSP(graph, pathfinder, mode=criterion)
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
                path, leg_cost, leg_comp_time = pathfinder.a_star_time(frm, to, current_time)
            elif criterion in ('p', 'transfers'):
                path, leg_cost, leg_comp_time = pathfinder.a_star_transfers(frm, to, current_time)
            else:
                sys.stdout.write("Nieznane kryterium.\n")
                return
            if path is None:
                sys.stdout.write(f"Nie znaleziono połączenia pomiędzy {frm} a {to}\n")
                return
            full_path.extend(path)
            total_leg_cost += leg_cost
            total_leg_comp_time += leg_comp_time
            current_time = path[-1].arrival_time  # aktualizacja czasu na koniec legu

        print_schedule(full_path)
        sys.stderr.write(f"Łączny koszt trasy: {total_leg_cost}\n")
        sys.stderr.write(f"Łączny czas obliczeń (legów): {total_leg_comp_time:.4f} s\n")
    else:
        # Zadanie 1
        start_stop = input_lines[0]
        target_stop = input_lines[1]
        criterion = input_lines[2].lower()
        start_time = time_to_seconds(input_lines[3])
        if criterion in ('t', 'time'):
            path, cost, comp_time = pathfinder.optimized_a_star(start_stop, target_stop, start_time, mode='time')
        else:
            path, cost, comp_time = pathfinder.optimized_a_star(start_stop, target_stop, start_time, mode='transfers')
        if path is None:
            sys.stdout.write("Nie znaleziono trasy.\n")
            return
        print_schedule(path)
        sys.stderr.write(f"Koszt trasy: {cost}\n")
        sys.stderr.write(f"Czas obliczeń: {comp_time:.4f} s\n")

if __name__ == "__main__":
    main()
