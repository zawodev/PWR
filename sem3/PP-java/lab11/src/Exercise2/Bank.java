package Exercise2;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.Map;
import java.util.Random;

class Bank {
    private final Map<Integer, BankAccount> accounts;
    private final Random random;
    private final int minAccountNumber; //inclusive
    private final int maxAccountNumber; //exclusive
    public Bank(int minAccountNumber, int maxAccountNumber) {
        accounts = new HashMap<>();
        random = new Random();
        this.minAccountNumber = minAccountNumber;
        this.maxAccountNumber = maxAccountNumber;
    }
    public void registerAccount(BankAccount account) {
        if (!accounts.containsKey(account.getAccountNumber()) && isAccountNumberInRange(account.getAccountNumber())) accounts.put(account.getAccountNumber(), account);
        else throw new IllegalArgumentException("invalid account number");
    }
    public int getMaxAccountNumber() {
        return maxAccountNumber;
    }
    public int generateRandomAccountNumber() {
        int randomAccountNumber = random.nextInt(minAccountNumber, maxAccountNumber);
        if(accounts.containsKey(randomAccountNumber)) randomAccountNumber = generateNextAccountNumber();

        return randomAccountNumber;
    }
    public int generateNextAccountNumber() {
        int nextAccountNumber = minAccountNumber;
        while (accounts.containsKey(nextAccountNumber) && isAccountNumberInRange(nextAccountNumber)) nextAccountNumber++;
        if (nextAccountNumber >= maxAccountNumber) throw new IllegalStateException("no more account numbers available");
        return nextAccountNumber;
    }
    public boolean isAccountNumberInRange(int accountNumber) {
        return accountNumber >= minAccountNumber && accountNumber < maxAccountNumber;
    }
    public BankAccount getRandomAccount() {
        ArrayList<BankAccount> accountsList = new ArrayList<>(accounts.values());
        return accountsList.get(random.nextInt(accountsList.size()));
    }
    public BankAccount getAccount(int accountNumber) {
        return accounts.getOrDefault(accountNumber, null);
    }
    public void printAccountBalances() {
        for (BankAccount account : accounts.values()) {
            System.out.println("Stan konta [" + account.getAccountNumberLeadingZeros() + "]: " + account.getBalance() + "pln");
        }
    }
    public void printAccountBalancesSum() {
        int sum = 0;
        for (BankAccount account : accounts.values()) {
            sum += account.getBalance();
        }
        System.out.println("Suma stanów kont: " + sum + "pln");
    }
}
