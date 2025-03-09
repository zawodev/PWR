import csv

class Graph:
    def __init__(self, filename):
        self.adjacency_list = {}
        self.load_from_csv(filename)

    def load_from_csv(self, filename):
        with open(filename, newline='', encoding='utf-8') as file:
            reader = csv.reader(file)
            for row in reader:
                start_stop, end_stop = row[5], row[6]
                self.add_edge(start_stop, end_stop)

    def add_edge(self, u, v):
        if u not in self.adjacency_list:
            self.adjacency_list[u] = []
        if v not in self.adjacency_list:
            self.adjacency_list[v] = []
        self.adjacency_list[u].append(v)
        self.adjacency_list[v].append(u)

    def remove_edge(self, u, v):
        if u in self.adjacency_list and v in self.adjacency_list[u]:
            self.adjacency_list[u].remove(v)
        if v in self.adjacency_list and u in self.adjacency_list[v]:
            self.adjacency_list[v].remove(u)

    def __str__(self):
        return str(self.adjacency_list)
