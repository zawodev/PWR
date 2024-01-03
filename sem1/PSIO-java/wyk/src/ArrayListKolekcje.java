import java.util.ArrayList;
import java.util.Arrays;
import java.util.Comparator;
import java.util.List;

public class ArrayListKolekcje {
    public static ArrayList<Zwierze> Z = new ArrayList<>();
    public ZwierzeCompareWiek Comparator;//drugi comparator na string

    class ZwierzeCompareWiek implements Comparator<Zwierze>{
        public int compare(Zwierze zw1, Zwierze zw2){//dla intów
            if(zw1.getZwierzeWiek() < zw2.getZwierzeWiek()) return -1;
            if(zw1.getZwierzeWiek() > zw2.getZwierzeWiek()) return 1;
            return 0;
            /*
            if(zw1.getName().equals(zw2.getName())) && zw1.getZwierzeWiek() < zw2.getZwierzeWiek()) return -1;
            if(zw1.getName().equals(zw2.getName()) && zw1.getZwierzeWiek() > zw2.getZwierzeWiek()) return 1;
            return 0;

            */
        }
        /*dla stringów
        public int compare(Zwierze zw1, Zwierze zw2){
            return zw1.getZwierzeWiek().compareTo(zw1.getZwierzeWiek());
        }
        */
    }

    public static void main(String[] args){
        ArrayList<String> strings = new ArrayList<>(5);
        String s = strings.get(4);
        boolean b = strings.contains("mum");
        strings.remove(5);
        strings.remove("lel");

        //Collections.sort() //ogarnac wyklad

        GenericClass gc = new GenericClass("mum", 5);
    }
    public static <T> void GenericVoid(T[] tab){
        System.out.println(tab.getClass());
    }
    public <T extends Zwierze> void VoidSth(ArrayList<T> List){

    }
    public void VoidSth2(ArrayList<? extends Zwierze> List1, ArrayList<? extends Zwierze> List2){

    }
}
class GenericClass <T, S>{ //klasa generyczna
    private T elementT;
    private S elementS;
    public GenericClass(T elementT, S elementS){
        this.elementS = elementS;
        this.elementT = elementT;
    }
}
abstract class Zwierze implements Comparable<Zwierze>{
    int wiek;
    public int getZwierzeWiek(){
        return wiek;
    }
    @Override
    public int compareTo(Zwierze zw){
        //if(this.getZwierzeWiek() < zw.getZwierzeWiek()) return -1;
        //if(this.getZwierzeWiek() > zw.getZwierzeWiek()) return 1;
        return 0;
    }

}
class Pies extends Zwierze{

}
class Collections extends Object{//> super T czyli comparable cos musi byc typem conajmniej lub ponad T
    static <T extends Comparable <? super T> > void sort (List <T> list){ //extends to to samo co implements dla metod generycznych nie ma znaczenia dla kompilattora
        //ArrayList extends AbtractList implements List, więc można list jakos arraylist
    }
    static<T> void sort(List<T> list, Comparator<? super T> c){

    }
}
/*@SuppressWarnings("unused")
* @override
* public int hashCode(){
* return this.getImie().hashCode(); //imie generuje hashcode, mozna mieszac pewnie jakos z np wiekiem czy cos idk
*
* @override
* public boolean equals(Object obj){
* if(imie.equals(((Student)obj).imie)return true; //jezeli imie rozne to falsz, takie samo true
* return false;
*
*
*
*
*DOSLOWNIE DICTIONARY
* HashMap<String, Integer> HS = new HashMap<>();
* HS.put("a", 1);
* HS.get("a");
*
* */