package Exercise1;

import java.util.Random;
import java.util.concurrent.TimeUnit;
import java.util.concurrent.locks.Lock;
import java.util.concurrent.locks.ReentrantLock;

public class Exercise1 {
    private static int globalVariable = 0;
    private static final int threadCount = 16;
    private static final long runTimeInSeconds = 3;
    private static final Lock lock = new ReentrantLock();

    public static void main(String[] args) {
        Thread[] threads = new Thread[threadCount];
        Random random = new Random();
        System.out.println("initial value: " + globalVariable);
        for (int i = 0; i < threadCount; i++) {
            threads[i] = new Thread(() -> {
                long endTimeMillis = System.currentTimeMillis() + TimeUnit.SECONDS.toMillis(runTimeInSeconds);
                while (System.currentTimeMillis() < endTimeMillis) {
                    try {
                        lock.lock();
                        if (random.nextBoolean()) globalVariable++;
                        else globalVariable--;
                    }
                    catch (Exception e) {
                        throw new RuntimeException(e);
                    }
                    finally {
                        lock.unlock();
                    }

                    try {
                        Thread.sleep(random.nextInt(10));
                    }
                    catch (InterruptedException e) {
                        throw new RuntimeException(e);
                    }
                }
            });
            threads[i].start();
        }

        try {
            for (Thread thread : threads) {
                thread.join();
            }
        }
        catch (InterruptedException e) {
            throw new RuntimeException(e);
        }

        System.out.println("final value: " + globalVariable);
    }
}
