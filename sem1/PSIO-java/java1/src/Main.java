//import java.util.Objects;
import java.util.Scanner;

public class Main {

    public static boolean isOverflow(Number a, Number b){
        if (a.longValue() == 0 || b.longValue() == 0) return false;
        long result = a.longValue() * b.longValue();
        return a.longValue() != result / b.longValue();
    }
    public static Long[] SquareEquation(int a, int b, int c){
        int delta = (int) Math.sqrt(b*b-4*a*c); //tylko dla calkowitych bo wyniki w doublach chyba mijaja sie z celem, lepiej by bylo zamienic na np 5 pierwiastkow z 3 niz wyniki typu 5*1,732...
        long x1 = -1;
        long x2 = -1;
        if(delta >= 0){
            x1 = (-b+delta)/(2L * a);
            x2 = (-b-delta)/(2L * a);
        }
        return new Long[]{x1, x2};
    }
    public static float FindEpowerX(float x){
        float _e = 1;
        long k = 1;
        long _k = 1;
        float x_k = 1;

        while (!(isOverflow(_k, k) || isOverflow(x_k, x))) {
            _k *= k;
            x_k *= x;
            float dif = x_k / _k;
            _e += dif;
            k+=1;
            /*System.out.printf("%s%f%s","dif: ", dif, "\n");
            System.out.printf("%s%f%s","x: ", x, "\n");
            System.out.printf("%s%f%s","x_k: ", x_k, "\n");
            System.out.printf("%s%f%s","e: ", _e, "\n");
            System.out.printf("%s%d%s","k: ", k, "\n");
            System.out.printf("%s%d%s","_k: ", _k, "\n\n");*/
        }
        return _e;
    }

    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);

        //zad1
        //int a = in.nextInt();
        //int b = in.nextInt();
        //int c = in.nextInt();

        //System.out.printf("%s%d%s", "Max: ", Math.max(a, Math.max(b,c)), "\n");
        
        //zad 2
        //Long[] l = SquareEquation(a, b, c);
        //System.out.printf("%s%d%s%d%s","X1: ", l[0], ", X2: ", l[1], "\n");

        //zad 3
        float x = in.nextFloat(); // float moze byc ciekawszy
        float _e = FindEpowerX(x);
        System.out.printf("%s%f%s","e: ", _e, "\n");

        //zad 4

        //sprawdz czy karta jest poprawna, jej numer oraz czy nie zostala oznaczona jako skradziona
        //sprawdz poprawnosc banknotu
        // - sprawdz luminant i naklejke jednoczesnie + numer serii porownac z baza danych czy juz moze nie ma
        //sprawdz poprawnosc hasla
        //pokaz stan konta jesli poprawne wszystko powyzej, przerwij jesli ktorekolwiek nie
        //jesli nie ma zadnych blokad na koncie oraz suma do wyplacenia <= suma na koncie => wypłać

        //zad 5

        //3 5 7 4 2 6 1

    }
}