public class Main2 {
    static TwoWayLinkedListWithSentinel<Integer> integers = new TwoWayLinkedListWithSentinel<>();
    public static void PrintList(int index){
        System.out.println(integers.get(index) + ", size: " + integers.size() + ", isEmpty: " + integers.isEmpty());
    }
    public static void main(String args[]){
        //PrintList(0);
        integers.remove(0);
        integers.add(2);
        integers.add(4);
        integers.add(6);
        integers.add(8);
        integers.add(10);
        System.out.println();
        integers.testNextIteration();
        integers.testPrevIteration();

        System.out.println();
        integers.remove(1);

        integers.testNextIteration();
        integers.testPrevIteration();

        System.out.println();
        integers.remove((Integer)10);

        integers.testNextIteration();
        integers.testPrevIteration();
    }
}
