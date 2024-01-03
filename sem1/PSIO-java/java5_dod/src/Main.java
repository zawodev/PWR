import java.util.Arrays;

public class Main {
    public static void BubbleSort(Student[] T){
        boolean sorted = true;
        for (int i = 0; i<T.length - 1; i++){
            for (int j = 0; j<T.length - i - 1; j++){
                if(T[j].GetPromile()>T[j+1].GetPromile()){
                    Student tmp = T[j];
                    T[j] = T[j+1];
                    T[j+1] = tmp;
                    sorted = false;
                }
            }
            if(sorted) break;
        }
    }
    public static void Wypisz(Student[] T){
        System.out.print("[ ");
        for (int i = 0; i<T.length; i++) {
            System.out.print(T[i].GetPromile());
            System.out.print(" ");
        }
        System.out.print("]\n");
        for (int i = 0; i<T.length; i++) {
            System.out.print(T[i].GetName());
            System.out.print(" ");
        }
        System.out.print("\n");
    }
    public static void main(String[] args) {
        Student[] T = new Student[10];
        T[0] = new Student("Grzegorz_Brzeczyszykiewicz", 34);
        for (int i = 1; i<T.length; i++) {
            T[i] = new Student();
        }
        Wypisz(T);
        BubbleSort(T);
        System.out.print("\n");
        Wypisz(T);
        //System.out.println(Arrays.toString(T));
    }
}