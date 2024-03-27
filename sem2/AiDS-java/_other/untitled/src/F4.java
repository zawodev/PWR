public class F4 implements SeriesGenerator<Integer>{
    @Override
    public Integer generate(int n) {
        return (int) Math.pow(n,2);
    }
}
