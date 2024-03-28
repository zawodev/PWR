import java.util.EmptyStackException;

public interface IStack<T> {
    boolean isEmpty() throws EmptyStackException;
    boolean isFull() throws FullStackException;
    T pop();
    void push (T elem);
    int size();
    T top() throws EmptyStackException;
}
