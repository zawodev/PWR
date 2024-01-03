import java.awt.*;
import java.util.ArrayList;

public class Node {
    public Node(int id, String name){
        //if(name == "") name = "N" + id;
        this.id = id;
        this.name = name;
        this.pos = new Point(0, 0);
        outEdges = new ArrayList<>();
        inEdges = new ArrayList<>();
        path = new ArrayList<>();
    }
    public Node(int id, String name, int x, int y){
        //if(name == "") name = "N" + id;
        this.id = id;
        this.name = name;
        this.pos = new Point(x, y);
        outEdges = new ArrayList<>();
        inEdges = new ArrayList<>();
        path = new ArrayList<>();
    }
    public void connectTo(Node node, int weight){
        Edge edge = new Edge(this, node, weight);

        for (Edge _edge : outEdges){
            if(_edge.compareTo(edge) == 0){
                outEdges.remove(_edge);
                break;
            }
        }
        for (Edge _edge : inEdges){
            if(_edge.compareTo(edge) == 0){
                inEdges.remove(_edge);
                break;
            }
        }

        //if(inEdges.contains(edge)) inEdges.remove(edge);

        this.outEdges.add(edge);
        node.inEdges.add(edge);
    }
    public int getLongestDist(){
        int score = 0;
        for(Edge edge : outEdges){
            if(edge.weight > score && edge.weight != 0) score = edge.weight;
        }
        return score;
    }
    public Node getFurthestNode(){
        Node node = null;
        int score = 0;
        for(Edge edge : outEdges){
            if(edge.weight > score && edge.weight != 0) {
                score = edge.weight;
                node = edge.endNode;
            }
        }
        return node;
    }
    public int getEdgeWeight(Node node){
        for(Edge edge : outEdges){
            if(edge.endNode == node) return edge.weight;
        }
        return 0;
    }
    public String toString(){
        return name;
    }
    public int id;
    public Point pos;
    public String name;
    public ArrayList<Node> path;
    public int dist;
    public ArrayList<Edge> outEdges;
    public ArrayList<Edge> inEdges;

}
