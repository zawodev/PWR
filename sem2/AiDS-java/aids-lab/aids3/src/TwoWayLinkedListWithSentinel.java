import java.util.Iterator;

public class TwoWayLinkedListWithSentinel<E> extends AbstractList<E> {
    TwoWayNode<E> sentinel = null;
    public TwoWayLinkedListWithSentinel(){
        sentinel = new TwoWayNode<>(null);
        sentinel.setNext(sentinel);
        sentinel.setPrev(sentinel);
    }
    private TwoWayNode<E> getNode(int index){
        if(index < 0 || index >= size()) throw new IndexOutOfBoundsException();
        TwoWayNode<E> node = sentinel.getNext();
        int counter = 0;
        while(node != sentinel && counter < index){
            counter++;
            node = node.getNext();
        }
        if(node == sentinel)
            throw new IndexOutOfBoundsException();
        return node;
    }
    private TwoWayNode<E> getNode(E value){
        TwoWayNode<E> node = sentinel.getNext();
        while(node != sentinel && !value.equals(node.getData())){
            node = node.getNext();}
        if(node == sentinel)
            return null;
        return node;
    }
    public boolean isEmpty() {
        return sentinel.getNext() == sentinel;
    }
    public void clear() {
        sentinel.setNext(sentinel);
        sentinel.setPrev(sentinel);
    }
    public boolean contains(E value) {
        return indexOf(value) != -1;
    }
    public E get(int index) {
        if(index < 0 || index >= size()) return null;
        TwoWayNode<E> node = getNode(index);
        return node.getData();
    }
    public E set(int index, E value) {
        TwoWayNode<E> node = getNode(index);
        E nodeData = node.getData();
        node.setData(value);
        return nodeData;
    }
    public boolean add(E value) {
        TwoWayNode<E> newNode = new TwoWayNode<E>(value);
        sentinel.insertBefore(newNode);
        return true;}
    public boolean add(int index, E data) {
        TwoWayNode<E> newNode = new TwoWayNode<E>(data);
        if(index == 0) sentinel.insertAfter(newNode);
        else{
            TwoWayNode<E> prevNode = getNode(index - 1);
            prevNode.insertAfter(newNode);
        }
        return true;
    }
    public int indexOf(E data) {
        TwoWayNode<E> node = sentinel.getNext();
        int counter = 0;
        while(node != sentinel && !node.getData().equals(data)){
            counter++;
            node = node.getNext();
        }
        if(node == sentinel)
            return -1;
        return counter;
    }
    public E remove(int index) {
        try{
            TwoWayNode<E> node = getNode(index);
            node.remove();
            return node.getData();
        }
        catch (IndexOutOfBoundsException e){
            e.printStackTrace();
        }
        return null;
    }
    public boolean remove(E value) {
        try {
            TwoWayNode<E> node = getNode(value);
            if (node == null) return false;
            node.remove();
            return true;
        }
        catch (IndexOutOfBoundsException e){
            e.printStackTrace();
        }
        return false;
    }
    public int size() {
        TwoWayNode<E> node = sentinel.getNext();
        int counter = 0;
        while(node != sentinel){
            counter++;
            node = node.getNext();
        }
        return counter;
    }
    public void testNextIteration(){
        TwoWayNode<E> node = sentinel.getNext();
        while(node != sentinel) {
            System.out.print(node.getData() + "; ");
            node = node.getNext();
        }
        System.out.println();
    }
    public void testPrevIteration(){
        TwoWayNode<E> node = sentinel.getPrev();
        while(node != sentinel) {
            System.out.print(node.getData() + "; ");
            node = node.getPrev();
        }
        System.out.println();
    }

    public Iterator<E> iterator() {
        return null;
    }
}
