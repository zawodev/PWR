import java.sql.Array;

public class Series<E> {
    private E array[];
    private SeriesGenerator seriesGenerator;

    public Series(int hm, SeriesGenerator sg)
    {
        seriesGenerator = sg;
        array = (E[]) new Object[hm];
        for(int i = 0; i < hm; i++)
        {
            array[i]= (E) sg.generate(i);
        }
    }

    public void show()
    {
        for(E e:array)
        {
            System.out.print(e+"; ");
        }
    }

    public E getArray()
    {
        return (E) array;
    }
}
