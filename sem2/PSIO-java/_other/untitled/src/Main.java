public class Main {
    public static void main(String[] args) {
        System.out.println("Test dla f = 2*n, liczba elementów=10");
        Series series1 = new Series<>(10,new F1());
        series1.show();
        System.out.println();
        SeriesIterator seriesIterator1 = new SeriesIterator<>(series1);
        while(seriesIterator1.hasNext())
        {
            System.out.print(seriesIterator1.next()+"; ");
        }

        System.out.println("\n");

        System.out.println("Test dla f = a powtórzone n razy, liczba elementów=10");
        Series series2 = new Series<>(10,new F2());
        series2.show();
        System.out.println();
        SeriesIterator seriesIterator2 = new SeriesIterator<>(series2);
        while(seriesIterator2.hasNext())
        {
            System.out.print(seriesIterator2.next()+"; ");
        }

        System.out.println("\n");

        System.out.println("Test dla f = 2^n, liczba elementów=11");
        Series series3 = new Series<>(11,new F3());
        series3.show();
        System.out.println();
        SeriesIterator seriesIterator3 = new SeriesIterator<>(series3);
        while(seriesIterator3.hasNext())
        {
            System.out.print(seriesIterator3.next()+"; ");
        }

        System.out.println("\n");

        System.out.println("Test dla f = n^2, liczba elementów=11");
        Series series4 = new Series<>(11,new F4());
        series4.show();
        System.out.println();
        SeriesIterator seriesIterator4 = new SeriesIterator<>(series4);
        while(seriesIterator4.hasNext())
        {
            System.out.print(seriesIterator4.next()+"; ");
        }
    }
}