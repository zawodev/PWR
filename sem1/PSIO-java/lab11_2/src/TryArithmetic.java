public class TryArithmetic {
    public static void main(String[] args) {
         long time = System.nanoTime();
         int count = 0;
         for(int i = 0; i < 100; i++) {
             try {
                 int t = 6/0;
             }
             catch (ArithmeticException exception) {
                 count++;
             }
         }
         time -= System.nanoTime();
         System.out.println(count);
         System.out.println(-time);
    }
}
