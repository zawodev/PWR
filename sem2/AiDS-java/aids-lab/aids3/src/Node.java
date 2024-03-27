public class Node<E> {
    E data;
    Node<E> next;
    //Node<E> prev;
    public Node(E data, Node<E> next) {
        this.data = data;
        this.next = next;
    }
    public Node() {

    }
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
    //public Node<E> getPrev() {return prev;}
    //public void setPrev(Node<E> prev) {this.prev = prev;}
    public void insertAfter(Node<E> elem){
        elem.setNext(this.getNext());
        //elem.setPrev(this);
        //this.getNext().setPrev(elem);
        this.setNext(elem);
    }
    /*public void insertBefore(Node<E> elem){
        elem.setNext(this);
        //elem.setPrev(this.getPrev());
        this.getPrev().setNext(elem);
        //this.setPrev(elem);
    }*/
    /*
    public void remove(){
        this.getNext().setPrev(this.getPrev());
        this.getPrev().setNext(this.getNext());
    }
    */
}
