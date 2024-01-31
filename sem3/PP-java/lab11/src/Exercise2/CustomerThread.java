package Exercise2;
import java.util.Random;
import java.util.concurrent.TimeUnit;
class CustomerThread extends Thread {
    private final Random random = new Random();
    private final BankAccount bankAccount;
    private final int simulationTimeInSeconds;
    public CustomerThread(BankAccount bankAccount, int simulationTimeInSeconds) {
        this.bankAccount = bankAccount;
        this.simulationTimeInSeconds = simulationTimeInSeconds;
    }

    @Override
    public void run() {
        long endTime = System.currentTimeMillis() + TimeUnit.SECONDS.toMillis(simulationTimeInSeconds);
        while (System.currentTimeMillis() < endTime) {
            int nextOperation = random.nextInt(3);
            int amount = random.nextInt(1, 500);

            if (nextOperation == 0) {
                bankAccount.deposit(amount);
            }
            else if (nextOperation == 1) {
                bankAccount.withdraw(amount);
            }
            else {
                BankAccount targetAccount = bankAccount.getBank().getRandomAccount(); //tylko przelewy wewnątrz-bankowe
                bankAccount.transfer(targetAccount, amount);
            }

            try {
                Thread.sleep(random.nextInt(100));
            }
            catch (InterruptedException e) {
                throw new RuntimeException(e);
            }
        }
    }
}
