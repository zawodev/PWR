import java.util.Iterator;
import java.util.NoSuchElementException;
import java.util.function.Predicate;

public class Main {
    public static void main(String[] args) {
        System.out.println("Hello world!");
    }
    public class ArrayIterator <E> implements Iterator<E> {
        private final E[] array;
        private int i = 0;
        public ArrayIterator(E[] array){
            this.array = array;
        }
        @Override
        public boolean hasNext() {
            return i<array.length;
        }

        @Override
        public E next() {
            if(i >= array.length){
                throw new NoSuchElementException();
            }
            return array[i++];
        }
    }
    public class FilterIterator<T> implements Iterator<T>{
        private Iterator <T> iterator;
        private Predicate<T> predicate;
        private T nextElem;
        private boolean hasNext = true;

        public FilterIterator (Iterator<T> iterator, Predicate<T> predicate){
            super();
            this.iterator = iterator;
            this.predicate = predicate;
            findNextValid();
        }
        private void findNextValid(){
            while(iterator.hasNext()){
                nextElem = iterator.next();
                if(predicate.test(nextElem)){ //bruh? //accept
                    return;
                }
            }
            nextElem = null;
            hasNext = false;
        }
        @Override
        public boolean hasNext(){
            return hasNext;
        }
        @Override
        public T next(){
            T nextVal = nextElem;
            findNextValid();
            return nextVal;
        }
    }
    public class Student{
        public double getOcena(){
            return 3.0;
        }
    }
    public class Studenci {
        private Student[]tablica = new Student[8];
        Predicate<Student> predicate = new NieZaliczyli();
        public void wysw_niezaliczonych(){
            ArrayIterator <Student> iter  = new ArrayIterator<>(tablica);
            Predicate<Student> predicate = Student -> Student.getOcena()<3.0;
            FilterIterator<Student> filterIterator = new FilterIterator<>(iter, predicate); //(iter, new Predicate())
            while(filterIterator.hasNext()){
                System.out.println(filterIterator.next());
            }
        }
    }
    class NieZaliczyli implements Predicate<Student>{

        @Override
        public boolean test(Student student) {
            return student.getOcena() < 3.0;
        }
    }
}