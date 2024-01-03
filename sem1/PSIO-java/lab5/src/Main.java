import java.util.Scanner;

public class Main {
    public static void main(String[] args) {
        //Scanner in = new Scanner(System.in);
        //int n = in.nextInt();

        Roslina r1 = new Roslina();
        Roslina r2 = new Roslina();
        r1.Pokaz();
        r1.Rosnij();
        r1.Rosnij();
        r1.Pokaz();
        r1.RosnijDuzo(4);
        r1.Pokaz();

        Zwierzak z = new Zwierzak();
        z.Zjedz(r1, 2);
        r1.Pokaz();
        z.Zjedz(r1, 8);
        r1.Pokaz();
        z.Zjedz(r1, 3);
        r1.Pokaz();
        r1.Rosnij();

        r1.Pokaz();
        r2.Pokaz();
    }
}
