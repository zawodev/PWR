import java.util.Arrays;

public class Client extends Person{
    private int depositAmount;
    private Deposit[] deposits;
    @Override
    public double Calculate(){
        int tSum = 0;
        for (int i = 0; i < depositAmount; i++){tSum += deposits[i].getAmount();}
        return tSum;
    }
    public Client (){
        super();
        deposits = null;
        depositAmount = 0;
    }
    public Client (String surname, String pesel, int depositAmount){
        super(surname, pesel);
        this.depositAmount = depositAmount;
        deposits = new Deposit[depositAmount];
        for(int i = 0; i< depositAmount; i++){
            deposits[i] = new Deposit(i+1, rand.nextDouble(500, 10000), false);
        }
    }
/*
    public int getDepositAmount() {
        return depositAmount;
    }

    public void setDepositAmount(int depositAmount) {
        this.depositAmount = depositAmount;
    }

    public Deposit[] getDeposits() {
        return deposits;
    }

    public void setDeposits(Deposit[] deposits) {
        this.deposits = deposits;
    }
*/
    @Override
    public String toString(){
        return "Client: " + getSurname() + ", Pesel: " + getPesel() + ", [deposits=" + Arrays.toString(deposits) + "]";
    }
    public void ShowDeposits(){
        for(int i = 0; i< depositAmount; i++){
            System.out.println(deposits[i].toString());
        }
    }
}
