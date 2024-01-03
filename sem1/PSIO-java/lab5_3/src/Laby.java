public class Main {
    public static void main(String[] args) {

        int n = 44;
        int c = 1;
        int [][]T = new int[n][];

        for(int i = 0; i<T.length; i++){
            T[i] = new int[i+1];
        }
        for(int i = 0; i<T.length; i++){
            for(int j = 0; j<T[i].length; j++){
                T[i][j] = c;
                System.out.printf("%3d\t", c);
                c++;
            }
            System.out.printf("%n");
        }
    }
}