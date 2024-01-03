public class ThrowArithmetic {
    static int count = 0;

    public static int do_the_forbidden() throws ArithmeticException {
        return 6 / 0;
    }
    public static void main(String[] args) {
        long time = System.nanoTime();
        for(int i = 0 ; i < 1000 ; i++) {
            try {
                int t = do_the_forbidden();
            } catch (ArithmeticException exception) {
                count++;
            }
        }
        time -= System.nanoTime();
        System.out.println(count);
        System.out.println(-time);
    }

}
