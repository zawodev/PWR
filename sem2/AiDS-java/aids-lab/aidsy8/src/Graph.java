import java.awt.*;
import java.util.ArrayList;
import java.util.List;
import java.util.Random;

public class Graph {
    public boolean directed = true;
    private int currIndex;
    public List<Node> nodes;
    //public List<Edge> edges;
    public Graph(){
        currIndex = 0;
        nodes = new ArrayList<>();
        //edges = new ArrayList<>();
    }
    public Graph(int nodeCount, int maxWeight, boolean directed){
        currIndex = 0;
        nodes = new ArrayList<>();
        //edges = new ArrayList<>();

        this.directed = directed;
        //generateCoherentGraph(nodeCount, maxWeight);
    }
    public Graph(int nodeCount){
        currIndex = 0;
        nodes = new ArrayList<>();
        this.directed = false;

        //generateOnPlaneGraph(nodeCount);
    }
    public void generateCoherentGraph(int nodeCount, int maxWeight){
        Random random = new Random();
        for(int i = 0; i < nodeCount; i++){
            addNode("N" + i);
        }
        for(int i = 0; i < nodeCount; i++){
            for(int j = 0; j < nodeCount; j++){
                if(i != j) connect(i, j, random.nextInt(0, 2) * random.nextInt(0, maxWeight));
            }
        }
    }
    public void generateOnPlaneGraph(int nodeCount, int minPosX, int maxPosX, int minPosY, int maxPosY){
        Random random = new Random();
        for(int i = 0; i < nodeCount; i++){
            addNodeOnPlane("N" + i, random.nextInt(minPosX, maxPosX), random.nextInt(minPosY, maxPosY));
        }
        connectAll(nodeCount);
    }
    public void connectAll(int nodeCount){
        for(int i = 0; i < nodeCount; i++){
            for(int j = 0; j < nodeCount; j++){
                if(i != j) connectOnPlane(i, j);
            }
        }
    }
    public void addNode(String name){
        nodes.add(new Node(currIndex++, name));
    }
    public void addNodeOnPlane(String name, int x, int y){
        nodes.add(new Node(currIndex++, name, x, y));
    }
    public void connect(int id1, int id2, int weight){
        nodes.get(id1).connectTo(nodes.get(id2), weight);
        if(!directed) nodes.get(id2).connectTo(nodes.get(id1), weight);
    }
    public void setDirected(boolean state){
        directed = state;
        if(!directed) directedFix();
    }
    private void directedFix(){
        for(int i = 0; i < nodes.size(); i++){
            for(int j = 0; j < nodes.size(); j++){
                int weight = nodes.get(i).getEdgeWeight(nodes.get(j));
                if(weight != 0) connect(j, i, weight);
            }
        }
    }
    public void connectOnPlane(int id1, int id2) {
        int weight = calculateDistance(nodes.get(id1).pos, nodes.get(id2).pos);
        connect(id1, id2, weight);
    }
    public int calculateDistance(Point a, Point b){
        return (int)Math.sqrt(Math.pow(a.x - b.x, 2) + Math.pow(a.y - b.y, 2));
    }
    public String toString(){
        try {
            StringBuilder stringBuilder = new StringBuilder("[");
            for (int i = 0; i < nodes.size() - 1; i++) {
                stringBuilder.append(nodes.get(i) + ", ");
            }
            stringBuilder.append(nodes.get(nodes.size() - 1) + "]\n\t");

            for (int i = 0; i < nodes.size(); i++) {
                stringBuilder.append(nodes.get(i) + "\t");
            }
            stringBuilder.append("\n");
            for (int i = 0; i < nodes.size(); i++) {
                stringBuilder.append(nodes.get(i) + "\t");
                for (int j = 0; j < nodes.size(); j++) {
                    stringBuilder.append(nodes.get(i).getEdgeWeight(nodes.get(j)) + "\t");
                }
                stringBuilder.append("\n");
            }
            return stringBuilder.toString();
        }
        catch (Exception e){
            return "[]";
        }
    }

}
