import java.util.Random;
import java.util.Scanner;

public class Tab {
    public static int n = 1000;
    public static int []T = new int[n];

    public static void ShowArray(){
        for (int i = 0; i<n-1; i++){
            System.out.printf("%d%s", T[i], ", ");
        }
        System.out.printf("%d%n", T[n-1]);
    }
    public static int FindMin(){
        int answer = T[0];
        for (int i = 1; i<n; i++){
            answer = Math.min(T[i], answer);
        }
        System.out.printf("%s%d%n", "Min Value: ", answer);
        return answer;
    }
    public static void FindOddProduct(){
        int answer = 1;
        for (int i = 0; i<n; i++){
            if(T[i] % 2 == 1) answer *= T[i];
        }
        if(FindOddCount() == 0) System.out.printf("%s%n", "Nie ma nieparzystych");
        else System.out.printf("%s%d%n", "Odd Product: " , answer);
    }
    public static int FindOddCount(){
        int answer = 0;
        for (int i = 0; i<n; i++){
            if(T[i] % 2 == 1) answer++;
        }
        return answer;
    }
    public static void WriteOddCount(){
        int answer = FindOddCount();
        System.out.printf("%s%d%n", "Odd Count: " , answer);
    }
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        Random rand = new Random();
        n = in.nextInt();
        for (int i = 0; i<n; i++){
            T[i] = rand.nextInt(1024);
        }
        ShowArray();
        FindMin();
        FindOddProduct();
        WriteOddCount();
    }
}
