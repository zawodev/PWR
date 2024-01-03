public class Transaction {
    static int transactionNum;
    private double amount;
    ClientCard card;

    public Transaction(ClientCard card, double amount) {
        this.card = card;
        this.amount = amount;
    }

    public Transaction() {

    }

    public String toString(){
        return card.toString() + ", Normal Amount: " + amount + ", Amount After Discount: " + Math.round(AmountAfterDiscount()*100.0)/100.0;
    }
    public double AmountAfterDiscount(){
        return amount * (1 - (card.Discount() / 100.0));
    }
}
