package Labs2.SeriesGenerator;

import Labs2.SeriesIterator.Series;

public class StringSeriesGenerator implements SeriesGenerator<String>{
    @Override
    public String generate(int n) {
        String temp = "a";
        for(int i = 0; i < n; i++){
            temp += "a";
        }
        return temp;
    }
}
