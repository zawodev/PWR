import java.util.Random;

public abstract class Person {
    public static Random rand = new Random();
    private String surname;
    private String pesel;

    public Person(){
        surname = "";
        pesel = "";
    }
    public Person(String surname, String pesel){
        this.pesel = pesel;
        this.surname = surname;
    }
    public abstract String toString();
    //return surname + ", " + pesel;
    public abstract double Calculate();

    public String getSurname() {
        return surname;
    }

    public void setSurname(String surname) {
        this.surname = surname;
    }

    public String getPesel() {
        return pesel;
    }

    public void setPesel(String pesel) {
        this.pesel = pesel;
    }
}
