import java.util.Comparator;
import java.util.LinkedList;

public abstract class Tree<T> {
    public Node<T> root;
    public final Comparator<T> comparator;
    public Tree(Comparator<T> comparator){
        this.comparator = comparator;
        root = null;
    }


    T find(T elem){
        return null;
    }
    void insert(T elem){

    }
    void remove(T elem){

    }

    public <R> void inOrderWalk(IExecutor<T, R> executor){
        inOrderWalk(root, executor);
    }
    private <R> void inOrderWalk(Node<T> node, IExecutor<T, R> executor){
        if (node != null){
            inOrderWalk(node.getLeft(), executor);
            executor.execute(node.getData());
            inOrderWalk(node.getRight(), executor);
        }
    }
    public String getTreeToString(){
        return getTreeToString(root);
    }
    public int heightOfTree(Node<T> root) {
        if (root == null) return 0;
        return 1 + Math.max(heightOfTree(root.getLeft()), heightOfTree(root.getRight()));
    }
    private String getTreeToString(Node<T> root){
        StringBuffer line = new StringBuffer();
        LinkedList<Node> treeLevel = new LinkedList<Node>();
        treeLevel.add(root);
        LinkedList<Node> temp = new LinkedList<Node>();
        int counter = 0;
        int height = heightOfTree(root) - 1;
        double numberOfElements = (Math.pow(2, (height + 1)) - 1);
        while (counter <= height) {
            Node removed = treeLevel.removeFirst();
            if (temp.isEmpty())
                printSpace(line, numberOfElements / Math.pow(2, counter + 1), removed);
            else
                printSpace(line, numberOfElements / Math.pow(2, counter), removed);

            if (removed == null) {
                temp.add(null);
                temp.add(null);
            }
            else {
                temp.add(removed.getLeft());
                temp.add(removed.getRight());
            }

            if (treeLevel.isEmpty()) {
                line.append("\n");
                //System.out.println("");
                //System.out.println("");
                treeLevel = temp;
                temp = new LinkedList<>();
                counter++;
            }
        }
        return line.toString();
    }
    private void printSpace(StringBuffer line, double n, Node removed) {
        for (; n > 0; n--) {
            line.append("\t");
            //System.out.print("\t");
        }
        if (removed == null) {
            line.append(" ");
            //System.out.print(" ");
        }
        else {
            line.append(removed.getData());
            if(this.getClass() == RBT.class) line.append(removed.isRed() ? "[R]" : "[B]");
            //System.out.print(removed.getData());
        }
    }
}
