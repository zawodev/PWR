import java.util.Iterator;
import java.util.NoSuchElementException;

public class SeriesIterator<E> implements Iterator<E> {
    private E array[];
    private int pos = 0;

    public SeriesIterator(Series series)
    {
        array = (E[]) series.getArray();
    }

    @Override
    public boolean hasNext() {
        return pos < array.length;
    }

    @Override
    public E next() throws NoSuchElementException {
        if(hasNext())
        {
            return array[pos++];
        }
        else
        {
            throw new NoSuchElementException();
        }
    }
}
