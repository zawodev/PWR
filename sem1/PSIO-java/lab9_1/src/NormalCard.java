public class NormalCard extends ClientCard{
    public NormalCard() {
        super();
    }

    public NormalCard(int num, String surname) {
        super(num, surname);
    }

    @Override
    public double Discount(){
        return 0.0;
    }
}
