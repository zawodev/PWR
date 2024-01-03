package Labs2;

import Labs2.SeriesGenerator.IntSeriesGenerator;
import Labs2.SeriesGenerator.StringSeriesGenerator;
import Labs2.SeriesIterator.Series;

public class Main  {
    public static void main(String[] args) {
        int n = 5;

        Series<Integer> intSeries = new Series<>(n, new IntSeriesGenerator());
        Series<String> stringSeries = new Series<>(n, new StringSeriesGenerator());

        for(Integer i : intSeries){
            System.out.print(i + " ");
        }
        System.out.println();
        for(String s : stringSeries){
            System.out.print(s + " ");
        }
    }
}
