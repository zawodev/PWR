import java.util.Random;
import java.util.Scanner;

public class Main {
    public static Rectangle CreateRect(double a, double b, double c, double d){
        Point A = new Point(a, b);
        Point B = new Point(c, d);
        return new Rectangle(A, B);
    }
    public static void PrintR(Rectangle R, int k){
        if(R != null) {
            System.out.print("\nProstokat nr. ");
            System.out.print(k);
            System.out.println("\nA: ");
            System.out.print(R.A.GetX());
            System.out.print(", ");
            System.out.println(R.A.GetY());

            System.out.println("B: ");
            System.out.print(R.B.GetX());
            System.out.print(", ");
            System.out.println(R.B.GetY());

            System.out.println("Pole: ");
            System.out.println(R.Area());
            System.out.println("Obwod: ");
            System.out.println(R.Circumference());
            System.out.println("Przekatna: ");
            System.out.println(R.Diagonal());
            System.out.println("\n");
        }
        else{
            System.out.println("R wynosi null\n");
        }
    }
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        Random rand = new Random();
        int tabSize = 10;
        Rectangle[] T = new Rectangle[tabSize];

        for (int i = 0; i<tabSize; i++) {
            T[i] = null;
        }
        for (int i = 0; i<tabSize; i++) {
            double a = rand.nextInt(10);
            double b = rand.nextInt(10);
            double c = rand.nextInt(10);
            double d = rand.nextInt(10);
            if(a!=c && b!=d) {
                T[i] = CreateRect(a, b, c, d);
            }
            else System.out.println("Niepoprawne Dane. Taki prostokat nie istnieje.");
        }
        for (int i = 0; i<tabSize; i++) {
            PrintR(T[i], i);
        }
    }
    //Arrays.ToString(i)
}
