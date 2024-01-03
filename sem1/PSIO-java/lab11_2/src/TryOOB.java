public class TryOOB {
    static int[] T = {1, 2, 5, 6};
    public static void main(String[] args) {
        long time = System.nanoTime();
        int count = 0;
        for (int i = 0; i<100; i++) {
            try {
                int t = T[4];
            }
            catch(IndexOutOfBoundsException exception) {
                count++;
            }
        }
        time -= System.nanoTime();
        System.out.println(count);
        System.out.println(-time);
    }
}
