import java.util.Iterator;
import java.util.ListIterator;

public class OneWayLinkedListWithSentinel<E> extends AbstractList<E> {

    //Node<E> head = null, tail = null;
    Node<E> sentinel = null;

<<<<<<< Updated upstream
    public OneWayLinkedListWithSentinel() {
        sentinel = new Node<>(null);
        sentinel.setNext(sentinel);
        //sentinel.setPrev(sentinel);
    }
    public boolean isEmpty() {
        return sentinel.getNext() == sentinel;}
=======
    public void add(E data) {
        Node<E> node = new Node<>(data, null);
        if (head == null) head = tail = node;
        else {
            tail.setNext(node);
            tail = node;
        }
    }

    public OneWayLinkedListWithSentinel() {

    }



    @Override
>>>>>>> Stashed changes
    public void clear() {
        sentinel.setNext(sentinel);
        //sentinel.setPrev(sentinel);
    }
    public boolean contains(E value) {
        return indexOf(value) != -1;}
    public E get(int index) {
        if(index < 0 || index >= size()) return null;
        Node<E> current = getNode(index);
        return current.getData();
    }
    public E set(int index, E value) {
        if(index < 0 || index >= size()) return null;
        Node<E> current = getNode(index);
        E currentData = current.getData();
        current.setData(value);
        return currentData;
    }
    public boolean add(E data) {
        Node<E> newNode = new Node<E>(data);
        Node<E> lastNode = sentinel;
        while(lastNode.getNext() != null){
            lastNode = lastNode.getNext();
        }
        lastNode.setNext(newNode);
        return true;
    }
    public boolean add(int index, E data) {
        Node<E> newNode = new Node<E>(data);
        if(index == 0) sentinel.insertAfter(newNode);
        else{
            Node<E> elem = this.getNode(index-1);
            elem.insertAfter(newNode);
        }
        return true;
    }
    private Node<E> getNode(int index){
        if (index < 0 || index >= size()) return null; //throw new outofbounderrorr
        Node<E> current = sentinel.getNext();
        int counter = 0;
        while (current != sentinel && counter < index) {
            counter++;
            current = current.getNext();
        }
        if (current == sentinel)
            return null;//throw new IndexOutOfBoundsException();
        return current;
    }
    private Node<E> getNode(E value){
        Node<E> current = sentinel.getNext();
        while(current != null && !value.equals(current.getData())){
            current = current.getNext();}
        return current;
    }
    public int indexOf(E data) {
        Node<E> current = sentinel.getNext();
        int counter = 0;
        while(current != sentinel && !current.getData().equals(data)){
            counter++;
            current=current.getNext();
        }
        if(current == sentinel)
            return -1;
        return counter;
    }
    public E remove(int index) {
        if(index == 0){
            sentinel.setNext(getNode(1));
            return getNode(0).getData();
        }
        Node<E> current = getNode(index-1);
        if(current.getNext() == null){
            throw new IndexOutOfBoundsException();
        }
        current.setNext(current.getNext().getNext());
        return current.getNext().getData();
    }
    public boolean remove(E data) {
        int index = indexOf(data);
        if(index < 0 || index >= size()) return false;
        remove(indexOf(data));
        return true;
    }
    public int size() {
        Node<E> current = sentinel.getNext();
        int counter = 0;
        while(current != sentinel){
            counter++;
            current = current.getNext();}
        return counter;
    }

    public Node<E> getSentinel(){return sentinel;}
    @Override
    public Iterator<E> iterator() {
        return null;
    }
    /*private class TWCIterator implements Iterator<E>{
        Node<E> _current=sentinel;
        public boolean hasNext() {
            return _current.getNext()!=sentinel;}
        public E next() {
            _current=_current.getNext();
            return _current.getData();}
    }
    public ListIterator<E> listIterator() {
        return new TWCListIterator();}
    private class TWCListIterator implements ListIterator<E>{
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

    */
}
