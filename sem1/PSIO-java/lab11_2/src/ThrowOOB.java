public class ThrowOOB {
    static int[] T = {1, 2, 5, 7};

    public static int thrower() throws IndexOutOfBoundsException {
        return T[4];
    }

    public static void main(String[] args) {
        long time = System.nanoTime();
        int count = 0;
        for (int i = 0; i < 100; i++) {
            try {
                int t = thrower();
            } catch (IndexOutOfBoundsException exception) {
                count++;
            }
        }
        time -= System.nanoTime();
        System.out.println(count);
        System.out.println(-time);
    }
}

