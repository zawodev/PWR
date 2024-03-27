import java.util.ArrayList;
import java.util.Comparator;

public class CycleFinder {
    private ArrayList<Pair> _cycles = new ArrayList<>();
    private ArrayList<Pair> cycles = new ArrayList<>();
    public void run(Graph graph){
        _cycles = new ArrayList<>();
        cycles = new ArrayList<>();
        boolean visited[];
        ArrayList<Node> path;

        for (int i = 0; i < graph.nodes.size(); i++) {
            //visited = new boolean[graph.nodes.size()];
            //dfs(graph, new ArrayList<>(), i, visited);
            //visited = new boolean[graph.nodes.size()];
            //dfs2(graph, new ArrayList<>(), i, visited);
            for (int j = 0; j < graph.nodes.size(); j++) {
                visited = new boolean[graph.nodes.size()];
                path = new ArrayList<>();
                path.add(graph.nodes.get(i));
                visited[i] = true;
                int weight = graph.nodes.get(i).getEdgeWeight(graph.nodes.get(j));
                if (weight != 0 && j != i) dfs(graph, path, j, visited);

                visited = new boolean[graph.nodes.size()];
                path = new ArrayList<>();
                path.add(graph.nodes.get(i));
                visited[i] = true;
                weight = graph.nodes.get(i).getEdgeWeight(graph.nodes.get(j));
                if (weight != 0 && j != i) dfs2(graph, path, j, visited);
            }
        }

        display();
    }
    public String display(){
        StringBuilder stringBuilder = new StringBuilder("\nIlość cykli: ");
        stringBuilder.append(cycles.size() + "\n");
        cycles.sort(Comparator.comparingInt(o -> -o.sum));
        for (int i = 0; i < cycles.size(); i++) {
            stringBuilder.append(cycles.get(i).nodes + ", " + cycles.get(i).sum + "\n");
        }
        return stringBuilder.toString();
    }
    private void dfs(Graph graph, ArrayList<Node> path, int v, boolean visited[]) {
        //System.out.println("N" + v);
        path.add(graph.nodes.get(v));
        visited[v] = true;
        for (int i = 0; i < graph.nodes.size(); i++) {
            int weight = graph.nodes.get(v).getEdgeWeight(graph.nodes.get(i));
            if (weight != 0 && v != i) {
                if (!visited[i]) {
                    dfs(graph, new ArrayList<>(path), i, visited);
                }
                else {
                    ArrayList<Node> path2 = new ArrayList<>(path);
                    path2.sort(Comparator.comparingInt(o -> o.id));

                    path.add(graph.nodes.get(i));
                    if(path.size() > 3 && path.get(0).id == i && !contains(_cycles, path2)) {
                        _cycles.add(new Pair(new ArrayList<>(path2), 0));
                        cycles.add(new Pair(new ArrayList<>(path), pathLength(path)));
                        //visited[i] = false;
                    }
                    //System.out.println(v + " - " + i);
                    //System.out.println(path);

                    path.remove(path.size() - 1);
                }
            }
        }
    }
    private boolean contains(ArrayList<Pair> cycles, ArrayList<Node> path){
        for (int i = 0; i < cycles.size(); i++) {
            if(cycles.get(i).nodes.size() == path.size()) {
                boolean same = true;
                for (int j = 0; j < path.size(); j++) {
                    if (cycles.get(i).nodes.get(j) != path.get(j)) same = false;
                }
                if (same) return true;
            }
        }
        return false;
    }
    private int pathLength(ArrayList<Node> path){
        int sum = 0;
        for (int i = 0; i < path.size(); i++) {
            sum += path.get(i).getEdgeWeight(path.get((i + 1) % path.size()));
        }
        return sum;
    }
    private void dfs2(Graph graph, ArrayList<Node> path, int v, boolean visited[]) {
        //System.out.println("N" + v);
        path.add(graph.nodes.get(v));
        visited[v] = true;
        for (int i = graph.nodes.size() - 1; i >= 0; i--) {
            int weight = graph.nodes.get(v).getEdgeWeight(graph.nodes.get(i));
            if (weight != 0 && v != i) {
                if (!visited[i]) {
                    dfs(graph, new ArrayList<>(path), i, visited);
                }
                else {
                    ArrayList<Node> path2 = new ArrayList<>(path);
                    path2.sort(Comparator.comparingInt(o -> o.id));

                    path.add(graph.nodes.get(i));
                    if(path.size() > 3 && path.get(0).id == i && !_cycles.contains(new Pair(new ArrayList<>(path2), 0))) {
                        _cycles.add(new Pair(new ArrayList<>(path2), 0));
                        cycles.add(new Pair(new ArrayList<>(path), pathLength(path)));
                        //visited[i] = false;
                    }
                    //System.out.println(v + " - " + i);
                    //System.out.println(path);

                    path.remove(path.size() - 1);
                }
            }
        }
    }
    /*
    private boolean isPathRepeated(ArrayList<Node> path){
        boolean visited[] = new boolean[100];

        for (int i = 0; i < path.size(); i++) {
            visited[path.get(i).id] = true;
        }
        for (int i = 0; i < _cycles.size(); i++) {
            ArrayList<Node> path2 = _cycles.get(i);
            boolean visited2[] = new boolean[100];
            for (int j = 0; j < path2.size(); j++) {
                visited2[path2.get(j).id] = true;
            }

            for (int j = 0; j < 100; j++) {
                if(visited[j] != visited2[j]){
                    return true;
                }
            }
        }
        return false;
    }
    */
}
