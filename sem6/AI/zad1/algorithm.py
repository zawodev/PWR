from graph import Graph

class DirectRouteAlgorithm:
    def __init__(self, start_stop, end_stop, opt_val, start_time):
        self.graph = Graph("data/connection_graph.csv")
        self.start_stop = start_stop
        self.end_stop = end_stop
        self.opt_val = opt_val
        self.start_time = start_time

    def run(self):
        pass
    
class LoopRouteAlgorithm:
    def __init__(self, start_stop, stops, opt_val, start_time):
        self.graph = Graph("data/connection_graph.csv")
        self.start_stop = start_stop
        self.stops = stops
        self.opt_val = opt_val
        self.start_time = start_time

    def run(self):
        pass
