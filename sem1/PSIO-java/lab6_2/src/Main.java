import java.util.Random;

public class Main {
    static Random rand = new Random();
    public static void DisplayProduct(Produkt P){
        P.getStan();
    }
    public static void DisplayAll(Produkt[] T){
        for(int i = 0; i<T.length; i++){
            DisplayProduct(T[i]);
        }
    }
    public static Produkt FindLowestPrice(Produkt[] T){
        Produkt lowest = T[0];
        for(int i = 1; i<T.length; i++) {
            if(lowest.getCena() > T[i].getCena()){
                lowest = T[i];
            }
        }
        return lowest;
    }
    public static void main(String[] args) {
        int n = 10;
        Produkt[] Fabryka = new Produkt[n];
        for(int i = 0; i<Fabryka.length; i++){
            Fabryka[i] = new Produkt(rand.nextInt(1, 999), Math.round(rand.nextDouble(1, 99)*100+100)/100.0);
        }
        DisplayAll(Fabryka);
        System.out.println("");
        DisplayProduct(FindLowestPrice(Fabryka));
    }
}