public class SeniorCard extends ClientCard{
    public SeniorCard() {
        super();
    }

    public SeniorCard(int num, String surname) {
        super(num, surname);
    }

    @Override
    public double Discount(){
        return 15.0;
    }
}
