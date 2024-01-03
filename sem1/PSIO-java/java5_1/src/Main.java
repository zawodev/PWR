import javax.lang.model.type.ArrayType;
import java.util.Arrays;
import java.util.Random;
import java.io.*;

public class Main {
    public static Random rand = new Random();
    public static void BubbleSort(int[] T){
        boolean sorted = true;
        for (int i = 0; i<T.length - 1; i++){
            for (int j = 0; j<T.length - i - 1; j++){
                if(T[j]>T[j+1]){
                    int tmp = T[j];
                    T[j] = T[j+1];
                    T[j+1] = tmp;
                    sorted = false;
                }
            }
            if(sorted) break;
        }
    }
    public static void Randomize(int []T, int bound){
        for(int i = 0; i<T.length; i++){
            T[i] = rand.nextInt(bound);
        }
    }
    public static void main(String[] args) {
        int []T = new int[10];
        System.out.println(Arrays.toString(T));
        for(int i = 0; i<10; i++){
            T[i] = 0;
        }
        System.out.println(Arrays.toString(T));
        Randomize(T, 10);
        System.out.println(Arrays.toString(T));
        //Arrays.sort(T);
        BubbleSort(T);
        System.out.println(Arrays.toString(T));
    }
}