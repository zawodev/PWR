import java.util.Arrays;
import java.util.Random;

public class Main {
    public static Random rand = new Random();
    public static void BubbleSort(int[] T){
        for (int i = 0; i<T.length - 1; i++){
            for (int j = 0; j<T.length - i - 1; j++){
                if(T[j]>T[j+1]){
                    int tmp = T[j];
                    T[j] = T[j+1];
                    T[j+1] = tmp;
                }
            }
        }
    }
    public static void Randomize(int []T, int bound){
        for(int i = 0; i<T.length; i++){
            T[i] = rand.nextInt(bound);
        }
    }
    public static void main(String[] args) {
        int [][]T = new int[10][20];
        for (int i = 0; i<10; i++){System.out.println(Arrays.toString(T[i]));}
        for (int i = 0; i<10; i++) {
            Randomize(T[i], 10);
        }
        for (int i = 0; i<10; i++){System.out.println(Arrays.toString(T[i]));}
        for (int i = 0; i<10; i++){
            BubbleSort(T[i]);
        }
        for (int i = 0; i<10; i++){System.out.println(Arrays.toString(T[i]));}
    }
}