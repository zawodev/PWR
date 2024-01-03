import java.util.AbstractList;
import java.util.Iterator;
import java.util.ListIterator;

public class TwoWayCyclicList<E extends Comparable<E>> extends AbstractList<E> {
    private class Node<E extends Comparable<E>> implements Comparable<Node<E>> {
        E data;
        Node<E> next;
        Node<E> prev;

        public Node(E data) {
            this.data = data;
        }
        public void setData(E data) {
            this.data = data;
        }
        public void setNext(Node<E> next) {
            this.next = next;
        }
        public E getData() {
            return data;
        }
        public Node<E> getNext() {
            return next;
        }
        public Node<E> getPrev() {return prev;}
        public void setPrev(Node<E> prev) {this.prev = prev;}
        public void insertAfter(Node<E> elem){
            elem.setNext(this.getNext());
            elem.setPrev(this);
            this.getNext().setPrev(elem);
            this.setNext(elem);
        }
        public void insertBefore(Node<E> elem){
            elem.setNext(this);
            elem.setPrev(this.getPrev());
            this.getPrev().setNext(elem);
            this.setPrev(elem);
        }

        public void remove(){
            this.getNext().setPrev(this.getPrev());
            this.getPrev().setNext(this.getNext());
        }

        @Override
        public int compareTo(Node<E> other) {
            return data.compareTo(other.data);
        }
    }
    Node sentinel = null;
    public TwoWayCyclicList(){
        sentinel = new Node(null);
        sentinel.setNext(sentinel);
        sentinel.setPrev(sentinel);
    }
    private Node getNode(int index){
        if(index < 0 || index >= size()) throw new IndexOutOfBoundsException();
        Node<E> node = sentinel.getNext();
        int counter = 0;
        while(node != sentinel && counter < index){
            counter++;
            node = node.getNext();
        }
        if(node == sentinel)
            throw new IndexOutOfBoundsException();
        return node;
    }
    private Node<E> getNode(E value){
        Node<E> node = sentinel.getNext();
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
    public boolean contains(Object value) {
        return indexOf((E)value) != -1;
    }
    public E get(int index) {
        if(index < 0 || index >= size()) return null;
        Node<E> node = getNode(index);
        return node.getData();
    }
    public E set(int index, E value) {
        Node<E> node = getNode(index);
        E nodeData = node.getData();
        node.setData(value);
        return nodeData;
    }
    public boolean add(E value) {
        Node<E> newNode = new Node<E>(value);
        sentinel.insertBefore(newNode);
        return true;
    }
    public void add(int index, E data) {
        Node<E> newNode = new Node<E>(data);
        if(index == 0) sentinel.insertAfter(newNode);
        else{
            Node<E> prevNode = getNode(index - 1);
            prevNode.insertAfter(newNode);
        }
    }
    public int indexOf(Object data) {
        Node<E> node = sentinel.getNext();
        int counter = 0;
        while(node != sentinel && !node.getData().equals((E)data)){
            counter++;
            node = node.getNext();
        }
        if(node == sentinel)
            return -1;
        return counter;
    }
    public E remove(int index) {
        try{
            Node<E> node = getNode(index);
            node.remove();
            return node.getData();
        }
        catch (IndexOutOfBoundsException e){
            e.printStackTrace();
        }
        return null;
    }
    public boolean remove(Object value) {
        try {
            Node<E> node = getNode((E)value);
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
        Node<E> node = sentinel.getNext();
        int counter = 0;
        while(node != sentinel){
            counter++;
            node = node.getNext();
        }
        return counter;
    }
    public void testNextIteration(){
        Node<E> node = sentinel.getNext();
        while(node != sentinel) {
            System.out.print(node.getData() + "; ");
            node = node.getNext();
        }
        System.out.println();
    }
    public void testPrevIteration(){
        Node<E> node = sentinel.getPrev();
        while(node != sentinel) {
            System.out.print(node.getData() + "; ");
            node = node.getPrev();
        }
        System.out.println();
    }
    public void sort(){
        Node<E> currentNode = sentinel.getNext();
        E data = currentNode.getData();
        while (currentNode != sentinel) {
            Node<E> node = currentNode.getNext();
            while (node != sentinel) {
                //System.out.println();
                if(node.getData().compareTo(currentNode.getData()) < 0){
                    data = currentNode.getData();
                    currentNode.setData(node.getData());
                    node.setData(data);
                }
                node = node.getNext();
            }
            currentNode = currentNode.getNext();
        }
    }

    public Iterator<E> iterator() {
        return new MyIterator();
    }
    private class MyIterator implements Iterator<E>{
        Node<E> currentNode = sentinel;
        public boolean hasNext() {
            return currentNode.getNext() != sentinel;}
        public E next() {
            currentNode = currentNode.getNext();
            return currentNode.getData();}
    }
    public ListIterator<E> listIterator() {
        return new MyListIterator();
    }
    private class MyListIterator implements ListIterator<E>{
        boolean wasNext=false;
        boolean wasPrevious=false;
        Node<E> _current=sentinel;
        public boolean hasNext() {
            return _current.getNext()!=sentinel;}
        public boolean hasPrevious() {
            return _current!=sentinel;}
        public int nextIndex() {
            throw new UnsupportedOperationException();}
        public int previousIndex() {
            throw new UnsupportedOperationException();}
        public E next() {
            wasNext=true;
            wasPrevious=false;
            _current=_current.getNext();
            return _current.getData();}
        public E previous() {
            wasNext=false;
            wasPrevious=true;
            E retValue=_current.getData();
            _current=_current.getPrev();
            return retValue;}
        public void remove() {
            if(wasNext){
                Node<E> curr=_current.getPrev();
                _current.remove();
                _current=curr;
                wasNext=false;}
            if(wasPrevious){
                _current.getNext().remove();
                wasPrevious=false;}}
        public void add(E data) {
            Node<E> newElem=new Node<E>(data);
            _current.insertAfter(newElem);
            _current=_current.getNext();}
        public void set(E data) {
            if(wasNext){
                _current.setData(data);
                wasNext=false;}
            if(wasPrevious){
                _current.getNext().setData(data);
                wasNext=false;
            }
        }
    }
}
