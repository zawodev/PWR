import java.util.Scanner;
public class Main {
    public static double S(int n, double x){
        if(x<-2){
            return Math.exp(x);
        }
        else if(x>0){
            double il = 1;
            long sil = 1;
            for(int i=1; i<=n; i++){
                sil*=i;
                il*=(x+i)/sil;
            }
            return il;
        }
        else{
            return 0.8;
        }
    }
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);

        System.out.printf("%s", "N: ");
        int n = in.nextInt();
        System.out.printf("%s", "X: ");
        double x = in.nextDouble();

        System.out.printf("%f%n", S(n, x));
    }
}