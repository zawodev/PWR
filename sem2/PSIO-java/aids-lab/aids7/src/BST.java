import java.util.Comparator;
import java.util.LinkedList;
import java.util.NoSuchElementException;

public class BST<T> extends Tree<T> {
    public BST(Comparator<T> comparator) {
        super(comparator);
    }
    public T find(T elem){
        Node<T> node = search(elem);
        return node == null ? null : node.getData();
    }
    private Node search(T elem){
        Node<T> node = root;
        int cmp = 0;
        while(node != null && (cmp = comparator.compare(elem, node.getData())) != 0){
            node = cmp < 0 ? node.getLeft() : node.getRight();
        }
        return node;
    }
    public T getMin(){
        if (root == null) throw new NoSuchElementException();
        Node<T> node = getMin(root);
        return node.getData();
    }
    private Node getMin(Node node){
        assert node != null : "Node is null";
        while (node.getLeft() != null)
            node = node.getLeft();
        return node;
    }
    public T getMax(){
        if (root == null) throw new NoSuchElementException();
        Node<T> node = getMax(root);
        return node.getData();
    }
    private Node getMax(Node node){
        assert node != null : "Node is null";
        while (node.getRight() != null)
            node = node.getRight();
        return node;
    }

    public T successor(T elem){
        Node<T> succNode = successorNode(root, elem);
        return succNode == null ? null : succNode.getData();
    }
    private Node<T> successorNode(Node<T> node, T elem){
        assert node != null : "Node is null";
        int cmp = comparator.compare(elem, node.getData());
        if(cmp == 0){
            if(node.getRight() != null){
                return getMin(node.getRight());
            }
            else return null;
        } else if (cmp < 0) {
           Node retNode = successorNode(node.getLeft(), elem);
           return retNode == null ? null : retNode;
        } else{
            return successorNode(node.getRight(), elem);
        }
    }

    public void insert(T elem){
        root = insert(root, elem);
    }
    private Node<T> insert(Node<T> node, T elem) {
        if (node == null) node = new Node(elem);
        else {
            int cmp = comparator.compare(elem, node.getData());
            if (cmp < 0)
                node.setLeft(insert(node.getLeft(), elem));
            else if (cmp > 0)
                node.setRight(insert(node.getRight(), elem));
            else
                throw new DuplicateElementException(elem.toString());
        }
        return node;
    }
    public void remove(T elem){
        root = remove(root, elem);
    }
    private Node<T> remove(Node<T> node, T elem) {
        if(node == null) throw new NoSuchElementException();
        else {
            int cmp = comparator.compare(elem, node.getData());
            if(cmp < 0)
                node.setLeft(remove(node.getLeft(), elem));
            else if(cmp > 0)
                node.setRight(remove(node.getRight(), elem));
            else if(node.getLeft() != null && node.getRight() != null)
                node.setRight(detachMin(node, node.getRight()));
            else
                node = (node.getLeft() != null) ? node.getLeft() : node.getRight();
        }
        return node;
    }
    private Node detachMin(Node del, Node node) {
        if(node.getLeft() != null) node.setLeft(detachMin(del, node.getLeft()));
        else {
            del.setData(node.getData());
            node = node.getRight();
        }
        return node;
    }
    /*

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
            line.append("X");
            //System.out.print(" ");
        }
        else {
            line.append(removed.getData());
            //System.out.print(removed.getData());
        }
    }

    */
}
