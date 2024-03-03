public class F3 implements SeriesGenerator<Integer>{
    @Override
    public Integer generate(int n) {
        return (int) Math.pow(2,n);
    }
}
