import java.util.AbstractList;
import java.util.Iterator;
import java.util.ListIterator;

public class TwoWayLinkedList<E extends Comparable<E>> extends AbstractList<E> {
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
    Node headSentinel = null;
    Node tailSentinel = null;
    public TwoWayLinkedList(){
        headSentinel = new Node(null);
        tailSentinel = new Node(null);
        headSentinel.setNext(tailSentinel);
        headSentinel.setPrev(null);
        tailSentinel.setNext(null);
        tailSentinel.setPrev(headSentinel);
    }
    private Node<E> getNode(int index){
        if(index < 0 || index >= size()) throw new IndexOutOfBoundsException();
        Node<E> node = headSentinel.getNext();
        int counter = 0;
        while(node != tailSentinel && counter < index){
            counter++;
            node = node.getNext();
        }
        if(node == tailSentinel)
            throw new IndexOutOfBoundsException();
        return node;
    }
    private Node<E> getNode(E value){
        Node<E> node = headSentinel.getNext();
        while(node != tailSentinel && !value.equals(node.getData())){
            node = node.getNext();}
        if(node == tailSentinel)
            return null;
        return node;
    }
    public boolean isEmpty() {
        return headSentinel.getNext() == tailSentinel;
    }
    public void clear() {
        headSentinel.setNext(tailSentinel);
        headSentinel.setPrev(null);
        tailSentinel.setNext(null);
        tailSentinel.setPrev(headSentinel);
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
        tailSentinel.insertBefore(newNode);
        return true;
    }
    public void add(int index, E data) {
        Node<E> newNode = new Node<E>(data);
        if(index == 0) headSentinel.insertAfter(newNode);
        else{
            Node<E> prevNode = getNode(index - 1);
            prevNode.insertAfter(newNode);
        }
    }
    public int indexOf(Object data) {
        Node<E> node = headSentinel.getNext();
        int counter = 0;
        while(node != tailSentinel && !node.getData().equals((E)data)){
            counter++;
            node = node.getNext();
        }
        if(node == tailSentinel)
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
        Node<E> node = headSentinel.getNext();
        int counter = 0;
        while(node != tailSentinel){
            counter++;
            node = node.getNext();
        }
        return counter;
    }
    public void sort(){
        Node<E> currentNode = headSentinel.getNext();
        E data = currentNode.getData();
        while (currentNode != tailSentinel) {
            Node<E> node = currentNode.getNext();
            while (node != tailSentinel) {
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
        Node<E> currentNode = headSentinel;
        public boolean hasNext() {
            return currentNode.getNext() != tailSentinel;
        }
        public E next() {
            currentNode = currentNode.getNext();
            return currentNode.getData();
        }
    }
    public ListIterator<E> listIterator() {
        return new MyListIterator();
    }
    private class MyListIterator implements ListIterator<E>{
        boolean wasNext = false;
        boolean wasPrevious = false;
        Node<E> currentNode = headSentinel;
        public boolean hasNext() {
            return currentNode.getNext() != tailSentinel;
        }
        public boolean hasPrevious() {
            return currentNode != headSentinel;
        }
        public int nextIndex() {
            throw new UnsupportedOperationException();
        }
        public int previousIndex() {
            throw new UnsupportedOperationException();
        }
        public E next() {
            wasNext = true;
            wasPrevious = false;
            currentNode = currentNode.getNext();
            return currentNode.getData();
        }
        public E previous() {
            wasNext = false;
            wasPrevious = true;
            E retValue = currentNode.getData();
            currentNode = currentNode.getPrev();
            return retValue;}
        public void remove() {
            if(wasNext){
                Node<E> currentNode = this.currentNode.getPrev();
                this.currentNode.remove();
                this.currentNode = currentNode;
                wasNext = false;
            }
            if(wasPrevious){
                currentNode.getNext().remove();
                wasPrevious = false;
            }
        }
        public void add(E data) {
            Node<E> newNode = new Node<E>(data);
            currentNode.insertAfter(newNode);
            currentNode = currentNode.getNext();
        }
        public void set(E data) {
            if(wasNext){
                currentNode.setData(data);
                wasNext = false;
            }
            if(wasPrevious){
                currentNode.getNext().setData(data);
                wasNext = false;
            }
        }
    }
}
