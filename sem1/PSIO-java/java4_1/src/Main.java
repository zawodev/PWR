import java.util.Random;
public class Main {
    public static Random rand = new Random();
    public static int maxNum = 0;
    public static int minNum = 0;

    public static int maxWiersz = 0;
    public static int minWiersz = 0;
    public static boolean init = true;
    public static void Randomize(int[][] T){
        for (int i = 0; i<5; i++){
            T[i] = new int[rand.nextInt(1,10)];
            maxWiersz = Math.max(maxWiersz, T[i].length);
            minWiersz = Math.min(minWiersz, T[i].length);
            for (int j = 0; j<T[i].length; j++){
                T[i][j] = rand.nextInt(10);
                if(init) {
                    maxNum = minNum = T[i][j];
                    init = false;
                }
                else {
                    maxNum = Math.max(maxNum, T[i][j]);
                    minNum = Math.min(minNum, T[i][j]);
                }
            }
        }
    }
    public static int GetMaxNum(){
        return maxNum;
    }
    public static int GetMaxWiersz(){
        return maxWiersz;
    }
    public static int GetMinNum(){
        return minNum;
    }
    public static int GetMinWiersz(){
        return minWiersz;
    }
    public static void Wypisz(int T[][]){
        for (int i = 0; i<5; i++){
            for (int j = 0; j<T[i].length; j++){
                System.out.printf("%d%s", T[i][j], " ");
            }
            System.out.print("\n");
        }
    }
    public static void main(String[] args) {
        int[][] T = new int[5][];
        Randomize(T);
        Wypisz(T);
        System.out.println(GetMaxNum());
        System.out.println(GetMinNum());
        System.out.println(GetMaxWiersz());
        System.out.println(GetMinWiersz());
    }
}