package Exercise2;

public class BankSimulationApp {
    public static void main(String[] args) throws InterruptedException {
        int numAccounts = 10;
        int simulationTimeInSeconds = 1;

        Bank bank = new Bank(0, 1000000);
        CustomerThread[] customers = new CustomerThread[numAccounts];

        for (int i = 0; i < numAccounts; i++) {
            BankAccount account = new BankAccount(bank, bank.generateRandomAccountNumber(),1000);

            customers[i] = new CustomerThread(account, simulationTimeInSeconds);
            bank.registerAccount(account);
        }

        for (int i = 0; i < numAccounts; i++) {
            customers[i].start();
        }

        for (CustomerThread customer : customers) {
            customer.join();
        }

        bank.printAccountBalances();
        bank.printAccountBalancesSum();
    }
}