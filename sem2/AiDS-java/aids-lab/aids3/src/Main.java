public class Main {
    static OneWayLinkedListWithSentinel<Integer> integers = new OneWayLinkedListWithSentinel<>();
    public static void PrintList(int index){
        System.out.println(integers.get(index) + ", size: " + integers.size() + ", isEmpty: " + integers.isEmpty());
    }
    public static void main(String args[]){

        PrintList(0);
        System.out.println();

        integers.add(0, 2);

        PrintList(0);
        System.out.println();

        integers.add(1, 8);

        PrintList(0);
        PrintList(1);
        System.out.println();

        integers.add(2, 6);

        PrintList(0);
        PrintList(1);
        PrintList(2);
        System.out.println();

        integers.remove(1);
        //integers.remove((Integer)8);

        PrintList(0);
        PrintList(1);
        System.out.println();


    }
}
