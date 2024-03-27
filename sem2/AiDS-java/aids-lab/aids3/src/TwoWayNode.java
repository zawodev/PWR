public class TwoWayNode<E> {
    E data;
    TwoWayNode<E> next;
    TwoWayNode<E> prev;

    public TwoWayNode(E data) {
        this.data = data;
    }
    public void setData(E data) {
        this.data = data;
    }
    public void setNext(TwoWayNode<E> next) {
        this.next = next;
    }
    public E getData() {
        return data;
    }
    public TwoWayNode<E> getNext() {
        return next;
    }
    public TwoWayNode<E> getPrev() {return prev;}
    public void setPrev(TwoWayNode<E> prev) {this.prev = prev;}
    public void insertAfter(TwoWayNode<E> elem){
        elem.setNext(this.getNext());
        elem.setPrev(this);
        this.getNext().setPrev(elem);
        this.setNext(elem);
    }
    public void insertBefore(TwoWayNode<E> elem){
        elem.setNext(this);
        elem.setPrev(this.getPrev());
        this.getPrev().setNext(elem);
        this.setPrev(elem);
    }

    public void remove(){
        this.getNext().setPrev(this.getPrev());
        this.getPrev().setNext(this.getNext());
    }

}
