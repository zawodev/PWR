package Labs2.SeriesGenerator;

import Labs2.SeriesIterator.Series;

public class IntSeriesGenerator implements SeriesGenerator<Integer>{
    @Override
    public Integer generate(int n) {
        return 2*n;
    }
}
