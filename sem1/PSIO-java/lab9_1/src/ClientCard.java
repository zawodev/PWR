public abstract class ClientCard {

    private int num;
    private String surname;

    public ClientCard() {

    }

    public ClientCard(int num, String surname) {
        this.num = num;
        this.surname = surname;
    }
    public String toString(){
        return "Surname: " + surname + ", Num: " + num;
    }
    abstract double Discount();
}
