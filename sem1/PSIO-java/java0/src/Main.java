import java.util.Arrays;
import java.util.Scanner;

public class Main {

    public static void wait(int ms) {
        try { Thread.sleep(ms);}
        catch(InterruptedException ex) { Thread.currentThread().interrupt();}
    }

    public static long Fib(long a, long b){
        return a+b;
    }

    public static void Donut(){
        int k;
        double A = 0, B = 0, i, j;
        double[] z = new double[1760];
        char[] b = new char[1760];
        System.out.print("\u001b[2J");
        for (; ; ) {
            Arrays.fill(b, 0, 1760, ' ');
            Arrays.fill(z, 0, 1760, 0);
            for (j = 0; 6.28 > j; j += 0.07)
                for (i = 0; 6.28 > i; i += 0.02) {
                    double c = Math.sin(i),
                            d = Math.cos(j),
                            e = Math.sin(A),
                            f = Math.sin(j),
                            g = Math.cos(A),
                            h = d + 2,
                            D = 1 / (c * h * e + f * g + 5),
                            l = Math.cos(i),
                            m = Math.cos(B),
                            n = Math.sin(B),
                            t = c * h * g - f * e;
                    int x = (int) (40 + 30 * D * (l * h * m - t * n)),
                            y = (int) (12 + 15 * D * (l * h * n + t * m)),
                            o = x + 80 * y,
                            N = (int) (8 * ((f * e - c * d * g) * m - c * d * e - f * g - l * d * n));
                    if (22 > y && y > 0 && x > 0 && 80 > x && D > z[o]) {
                        z[o] = D;
                        b[o] = new char[]{'.', ',', '-', '~', ':', ';', '=', '!', '*', '#', '$', '@'}[Math.max(N, 0)];
                    }
                }
            //System.out.print("\u001b[H");
            System.out.print("\033[H\033[2J");
            System.out.flush();
            wait(1000);

            for (k = 0; 1761 > k; k++)
                System.out.print(k % 80 > 0 ? b[k] : 10);
            A += 0.04;
            B += 0.02;
        }
    }

    public static void main(String[] args) {
        System.out.println("Hello world!");
        Scanner in = new Scanner(System.in);
        int n = in.nextInt();
        long a1 = 0;
        long a2 = 1;
        System.out.printf("%s", "0 1 ");

        for (int i=0; i<n; i++){
            long tmp = Fib(a1, a2);
            a1 = a2;
            a2 = tmp;
            System.out.printf("%s", tmp + " ");
        }
        float b1 = a1;
        float b2 = a2;
        float fi = b2/b1;
        System.out.printf("%n%f", fi);

        //podziel program na funkcje
        //nie powielaj kodu
        //poprawna struktura kodu nie zakłada użycia instrukcji skoku, goto oraz unika instrukcji typu break, continue
        //minimalizuj użycie zmiennych
        //zadbaj o czytelność kodu(wciecia, komentarze, przejscie na nastepna linie)



    }
}