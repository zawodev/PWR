public class Deposit {
    private int num;
    private double amount;
    private boolean preDeadlined;

    public Deposit(){
        num = 0;
        amount = 0;
        preDeadlined = false;
    }
    public double getAmount() {
        return amount;
    }
    /*
    public int getNum() {
        return num;
    }

    public void setNum(int num) {
        this.num = num;
    }

    public void setAmount(double amount) {
        this.amount = amount;
    }

    public boolean isPreDeadlined() {
        return preDeadlined;
    }

    public void setPreDeadlined(boolean preDeadlined) {
        this.preDeadlined = preDeadlined;
    }
    */
    public Deposit(int num, double amount, boolean preDeadlined){
        this.num = num;
        this.amount = amount;
        this.preDeadlined = preDeadlined;
    }
    public String toString(){
        return "Num: " + num + ", Amount: " + amount + ", preDeadlined: " + preDeadlined;
    }
}
