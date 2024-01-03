import java.util.Scanner;
public class Main {
    public static int Zad1(int n, int m){
        int s = 0;
        if(n%2 == 1) n++;
        for (int i = n; i<=m; i+=2) {
            s += i;
        }
        return s;
    }
    public static int Suma(int n){
        int s = 5*(n/2);
        if(n%2 == 1) s-=(n/2)*10+2;
        return s;
    }
    public static int Ilo(int n){
        int l = 1;
        for (int i = 0; i<n; i++){
            l*=3*i+2;
        }
        return l;
    }
    public static void El1(int n){
        System.out.printf("%s", "[");
        for(int i = 0;i<n;i++){
            if(i%2 == 0){
                System.out.printf("%s%d", "-", (i/2)*10+2);
            }
            else{
                System.out.printf("%d", (i/2)*10+7);
            }

            if(i<n-1) System.out.printf("%s", ", ");
        }
        System.out.printf("%s", "]\n");
    }
    public static void El2(int n){
        System.out.printf("%s", "[");
        for(int i = 0;i<n;i++){
            System.out.printf("%d", 3*i + 2);
            if(i<n-1) System.out.printf("%s", ", ");
        }
        System.out.printf("%s", "]\n");
    }
    public static double Zad2(int n){
        double d = (double)Suma(n)/Ilo(n);
        int s2 = Suma(n);
        int il = Ilo(n);
        System.out.printf("%d%s%d%n", s2, "/", il);
        return d;
    }
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);

        //zad1
        int n = in.nextInt();
        int m = in.nextInt();
        int s1 = Zad1(n, m);
        System.out.printf("%d%n", s1);

        //zad2
        n = in.nextInt();
        double d = Zad2(n);
        System.out.println(d);

        El1(n);
        El2(n);
    }
}