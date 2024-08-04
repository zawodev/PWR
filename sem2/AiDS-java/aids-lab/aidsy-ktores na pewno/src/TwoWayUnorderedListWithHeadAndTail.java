import java.util.Iterator;
import java.util.ListIterator;
import java.util.NoSuchElementException;


public class TwoWayUnorderedListWithHeadAndTail<E> implements IList<E>{
	
	private class Element{
		public Element(E e) {
			this.object = e;
		}
		public Element(E e, Element next, Element prev) {
			this.object = e;
			this.next = next;
			this.prev = prev;
		}
		E object;
		Element next=null;
		Element prev=null;
	}
	
	Element head;
	Element tail;
	// can be realization with the field size or without
	private int lastElementIdx;
	
	private class InnerIterator implements Iterator<E>{
		private Element e;
		private int idx;
		public InnerIterator() {
			e = head;
			idx = -1;
		}
		@Override
		public boolean hasNext() {
			return e != null && idx < size();
		}

		@Override
		public E next() {
			Element nextElement = e.next;
			E object = e.object;

			this.e = nextElement;
			return object;
		}
	}
	
	private class InnerListIterator implements ListIterator<E>{
		Element p;
		private int idx;
		public InnerListIterator(){
			p=head;
		}
		@Override
		public boolean hasNext() {
			return p != null && p.next != null && idx < size();
		}

		@Override
		public boolean hasPrevious() {
			return p != null;
		}

		@Override
		public E next() {
			Element nextElement = p.next;
			E object = p.object;
			idx += 1;
			this.p = nextElement;
			return object;
		}


		@Override
		public E previous() {
			Element previousElement = p.prev;
			E object = p.object;
			idx -=1;
			this.p = previousElement;
			return object;
		}

		@Override
		public int nextIndex() {
			throw new UnsupportedOperationException();
		}
		@Override
		public int previousIndex() {
			throw new UnsupportedOperationException();
		}

		@Override
		public void remove() {
			throw new UnsupportedOperationException();
			
		}
		@Override
		public void add(E e) {
			throw new UnsupportedOperationException();

		}
		@Override
		public void set(E e) {
			p.object = e;
		}
	}
	private void initializeList(){
		head = null;
		tail = null;
		lastElementIdx = -1;
	}
	public TwoWayUnorderedListWithHeadAndTail() {
		// make a head and a tail
		initializeList();
	}
	
	@Override
	public boolean add(E e) {
		if (head == null){
			head = new Element(e);
			this.lastElementIdx += 1;
			return true;
		}
		Element previousElement = head;
		while (previousElement.next != null){
			previousElement = previousElement.next;
		}

		Element newElement = new Element(e, null, previousElement);
		previousElement.next = newElement;
		tail = newElement;
		this.lastElementIdx +=1;
		return true;
	}

	@Override
	public void add(int index, E element) throws NoSuchElementException {
		if (index > this.size()) throw new NoSuchElementException();
		if (head == null) {
			add(element);
			return;
		}
		Element previousElement = head;
		for (int i = 1; i < index; i++) {
			if (previousElement.next == null) break;
			previousElement = previousElement.next;
		}
		previousElement.next = new Element(element, previousElement.next, previousElement);
		this.lastElementIdx += 1;
	}

	@Override
	public void clear() {
		initializeList();
	}

	@Override
	public boolean contains(E element) {
		for (E e : this) {
			if (element.equals(e)) return true;
		}
		return false;
	}

	@Override
	public E get(int index) throws NoSuchElementException{
		Element element = head;
		if (index < 0 || index > lastElementIdx || head == null) throw new NoSuchElementException();
		for (int i = 0; i < index;i++){
			element = element.next;
		}
		if (element == null) throw new NoSuchElementException();
		return element.object;
	}

	@Override
	public E set(int index, E element) throws NoSuchElementException {
		if (index > lastElementIdx || index < 0) throw new NoSuchElementException();
		if (head == null) throw new NoSuchElementException();
		Element toBeChanged = head;
		for (int i = 0; i < index;i++){
			toBeChanged = toBeChanged.next;
		}
		E oldObject = toBeChanged.object;
		toBeChanged.object = element;
		return oldObject;
	}

	@Override
	public int indexOf(E element) {
		int idx = 0;
		for (E e : this) {
			if (element.equals(e)) return idx;
			idx+=1;
		}
		return -1;
	}

	@Override
	public boolean isEmpty() {
		return lastElementIdx == -1;
	}

	@Override
	public Iterator<E> iterator() {
		return new InnerIterator();
	}

	@Override
	public ListIterator<E> listIterator() {
		throw new UnsupportedOperationException();
	}

	@Override
	public E remove(int index) throws NoSuchElementException{
		if (index > lastElementIdx || index < 0) throw new NoSuchElementException();
		if (index == 6)
			System.out.println("asdfsad");
		if (index == 0) {
			if (head == null) throw new NoSuchElementException();
			lastElementIdx -= 1;
			Element previousElement = head;
			head = head.next;
			if (head != null) head.prev = null;
			return previousElement.object;
		};
		lastElementIdx -= 1;
		if (index == lastElementIdx){
			Element previousElement = tail;
			tail = tail.prev;
			if (tail != null) tail.next = null;
			return previousElement.object;
		}
		Element toBeRemoved = head;
		for (int i = 0; i < index-1;i++){
			toBeRemoved = toBeRemoved.next;
		}
		Element previousElement = toBeRemoved.prev;
		Element nextElement = toBeRemoved.next;

		previousElement.next = nextElement;
		if (nextElement != null) nextElement.prev = previousElement;
		return toBeRemoved.object;
	}

	@Override
	public boolean remove(E e) {
		int requestedElementIdx = indexOf(e);
		if (requestedElementIdx == -1) return false;
		try{
			remove(requestedElementIdx);
		} catch(NoSuchElementException ex) {
			return false;
		}
		return true;
	}

	@Override
	public int size() {
		return this.lastElementIdx + 1;
	}
	public String toStringReverse() {
		ListIterator<E> iter=new InnerListIterator();
		while(iter.hasNext())
			iter.next();
		StringBuilder retStr = new StringBuilder();

		while (iter.hasPrevious()) {
			retStr.append("\n").append(iter.previous().toString());
		}
		return retStr.toString();
	}

	public void add(TwoWayUnorderedListWithHeadAndTail<E> other) {
		Element thisLastElement = tail;
		if (tail == null) thisLastElement = head;
		if (other.head == null && other.tail == null) return;
		if (thisLastElement == null) {
			head = other.head;
		} else {
			thisLastElement.next = other.head;
		}
		other.head.prev = thisLastElement;
		this.tail = other.tail;

		this.lastElementIdx += other.size();
		other.initializeList();
	}
	public void removeEvenIdx(){
		Element previousElement = head;
		if (previousElement == null) return;
		int length = size();
		Element nextElement;
		head = head.next;
		for(int i = 0; i < length; i+=2){
			nextElement = previousElement.next;
			if (previousElement.prev != null){
				previousElement.prev.next = nextElement;
			}
			if (nextElement != null){
				nextElement.prev = previousElement.prev;
				previousElement = nextElement.next;
			}
			this.lastElementIdx-=1;
		}
	}
}

