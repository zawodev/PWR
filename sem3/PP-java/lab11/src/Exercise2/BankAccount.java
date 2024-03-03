package Exercise2;

class BankAccount {
    private final Bank bank;
    private final int accountNumber;
    private int balance;
    public BankAccount(Bank bank, int accountNumber, int initialBalance) {
        this.bank = bank;
        this.accountNumber = accountNumber;
        this.balance = initialBalance;
    }

    public Bank getBank() {
        return bank;
    }
    public int getAccountNumber() {
        return accountNumber;
    }
    public int getBalance() {
        return balance;
    }
    public String getAccountNumberLeadingZeros() {
        return String.format("%0" + String.valueOf((bank.getMaxAccountNumber()) - 1).length() + "d", accountNumber);
    }

    public synchronized void deposit(int amount) {
        if (amount <= 0){
            return;
        }
        balance += amount;
        //System.out.println("wpłata na konto [" + accountNumber + "]: " + amount + "pln");
    }
    public synchronized void withdraw(int amount) {
        if (amount <= 0){
            return;
        }
        if (balance >= amount) {
            balance -= amount;
            //System.out.println("wypłata z konta [" + accountNumber + "]: " + amount + "pln");
        }
        else {
            //System.out.println("brak wystarczających środków do wypłaty z konta [" + accountNumber + "]");
        }
    }
    public synchronized void transfer(BankAccount targetAccount, int amount) {
        if (targetAccount == this) {
            //System.out.println("próba przelewu z konta [" + accountNumber + "] na to samo konto");
            return;
        }
        if (targetAccount == null) {
            //System.out.println("próba przelewu z konta [" + accountNumber + "] na nieistniejące konto");
            return;
        }
        if (amount <= 0){
            return;
        }

        if (balance >= amount) {
            withdraw(amount);
            targetAccount.deposit(amount);
            //System.out.println("przelew z konta [" + accountNumber + "] na konto [" + targetAccount.getAccountNumber() + "]: " + amount + "pln");
        }
        else {
            //System.out.println("brak wystarczających środków do przelewu z konta [" + accountNumber + "] na konto [" + targetAccount.getAccountNumber() + "]");
        }
    }
}
