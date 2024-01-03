import java.util.Scanner;
import java.util.Arrays;
import java.util.Random;

public class Main {
    public static void wait(int ms) {
        try { Thread.sleep(ms);}
        catch(InterruptedException ex) { Thread.currentThread().interrupt();}
    }
    public static int Fib1(int a, int b){

        return a+b;
    }
    public static boolean[] Fib2(boolean[] t, int n){
        int a1 = 0;
        int a2 = 1;
        int tmp = 1;
        t[0] = true;

        while(tmp < n){
            tmp = Fib1(a1, a2);
            a1 = a2;
            a2 = tmp;
            t[a1] = true;
        }
        return t;
    }
    public static int Zad1(int a, int b, int c){
        if(a>b){
            if(a>c)return a;
            else return c;
        }
        else if (b>c) {
            return b;
        }
        else return c;
    }
    public static void Zad2(int n, int m){
        boolean t[] = new boolean[n+2];
        Fib2(t, n);
        for (int i = 1; i<=n; i++){
            for (int j = 1; j<=n; j++){
                if(t[j] || t[Math.max(0, j-i)] || t[Math.min(n, j+i)]){
                    System.out.print("*");
                }
                else{
                    System.out.print(" ");
                }
            }
            System.out.print("\n");
        }
    }
    public static void Zad2_1(int n, int m){
        int t[] = new int[n+3];
        for (int i = 0; i<=n; i++){t[i] = Math.random() > 0.5f ? 1 : 0;}

        for (int i = 1; i<=m; i++){
            for (int j = 1; j<=n; j++){
                if(t[j] == 1){
                    System.out.print("*");
                }
                else{
                    System.out.print(" ");
                }
            }
            int t2[] = new int[n+3];
            for (int j = 1; j<=n; j++) {
                int tmp = t[j] + t[j-1] + t[j+1] + t[j+2];
                if(j != 1) tmp += t[j-2];

                if(tmp == 2 || tmp == 3) t2[j] = 1;
                else t2[j] = 0;
            }
            for (int j = 0; j<=n; j++) t[j] = t2[j];
            System.out.print("\n");
        }
    }

    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);

        //zad 1
        int a = in.nextInt();
        int b = in.nextInt();
        int c = in.nextInt();
        int x = Zad1(a, b, c);
        System.out.printf("%d%s", x, "\n");

        //zad2
        int n = in.nextInt();
        int m = in.nextInt();
        Zad2_1(n, m);
    }
}