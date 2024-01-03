public class StudentCard extends ClientCard{
    public StudentCard() {
        super();
    }

    public StudentCard(int num, String surname) {
        super(num, surname);
    }

    @Override
    public double Discount(){
         return 10.0;
    }
}
