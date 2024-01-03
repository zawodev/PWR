public class Edge implements Comparable<Edge> {
    public int id;
    public int weight;
    public Node srcNode;
    public Node endNode;

    public Edge(Node srcNode, Node endNode, int weight){
        this.srcNode = srcNode;
        this.endNode = endNode;
        this.weight = weight;
    }

    @Override
    public int compareTo(Edge edge) {
        if(this.srcNode == edge.srcNode && this.endNode == edge.endNode) return 0;
        else return 1;
    }
}
