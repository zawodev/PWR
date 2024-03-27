import java.util.ArrayList;
import java.util.List;

public class Dijkstra {
    private int shortestPathLength;
    public String getShortestPathLength(){
        if(shortestPathLength != Integer.MAX_VALUE) return Integer.toString(shortestPathLength);
        else return "NIE ISTNIEJE";
    }
    public List<Node> shortestPath;
    public void run(Graph graph, int startNodeID, int endNodeID){
        try {
            Node start = graph.nodes.get(startNodeID);
            Node end = graph.nodes.get(endNodeID);
            shortestPath = dijkstra(graph, start, end);
            shortestPathLength = end.dist;
        }
        catch (Exception e){
            //e.printStackTrace();
        }
    }
    private int minDistance(int dist[], Boolean sptSet[], int nodesCount) {
        int min = Integer.MAX_VALUE, min_index = -1;
        for (int v = 0; v < nodesCount; v++)
            if (sptSet[v] == false && dist[v] <= min) {
                min = dist[v];
                min_index = v;
            }
        return min_index;
    }
    private List<Node> dijkstra(Graph graph, Node start, Node end){
        int nodesCount = graph.nodes.size();
        int src = start.id;
        int fin = end.id;
        //List<Node> path = new ArrayList<>();

        int dist[] = new int[nodesCount];
        Boolean sptSet[] = new Boolean[nodesCount];

        for (int i = 0; i < nodesCount; i++) {
            dist[i] = Integer.MAX_VALUE;
            graph.nodes.get(i).dist = Integer.MAX_VALUE;
            graph.nodes.get(i).path = new ArrayList<>();
            sptSet[i] = false;
        }

        dist[src] = 0;
        graph.nodes.get(src).dist = 0;
        //graph.nodes.get(src).path.add(start);

        for (int i = 0; i < nodesCount - 1; i++) {
            int u = minDistance(dist, sptSet, nodesCount);
            //if(!sptSet[fin]) path.add(graph.nodes.get(u));

            sptSet[u] = true;

            for (int v = 0; v < nodesCount; v++) {
                int val = graph.nodes.get(u).getEdgeWeight(graph.nodes.get(v));
                if (!sptSet[v] && val != 0 && dist[u] != Integer.MAX_VALUE && dist[u] + val < dist[v]){
                    dist[v] = dist[u] + val;
                    graph.nodes.get(v).path = new ArrayList<>(graph.nodes.get(u).path);
                    graph.nodes.get(v).path.add(graph.nodes.get(u));
                    graph.nodes.get(v).dist = graph.nodes.get(u).dist + val;
                }
            }
        }
        //if(!sptSet[fin]) path.add(graph.nodes.get(fin));
        if(!end.path.contains(end)) end.path.add(end);
        return end.path;
    }
}
