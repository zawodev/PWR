import java.util.AbstractList;

public class Main {
    //static OneWayLinkedList<Integer> myList = new OneWayLinkedList();
    //static OneWayCyclicLinkedList<Integer> myList = new OneWayCyclicLinkedList();
    //static TwoWayLinkedList<Integer> myList = new TwoWayLinkedList();
    static TwoWayCyclicLinkedList<Integer> myList = new TwoWayCyclicLinkedList();
    static TwoWayCyclicLinkedList<Student> myStudentList = new TwoWayCyclicLinkedList();
    public static void TestStudent(){
        myStudentList.add(new Student(0, "Adam", "B","IST"));
        myStudentList.add(new Student(10, "Karol", "C", "ABC"));
        myStudentList.add(new Student(5, "Damian", "A","XYZ"));

        System.out.println(myStudentList);
        myStudentList.sort();
        System.out.println(myStudentList);
    }
    public static void TestInteger(){
        System.out.println(myList.isEmpty());

        myList.add(1);
        myList.add(2);
        myList.add(3);

        System.out.println(myList.isEmpty());

        for (int i : myList){
            System.out.print(i + "; ");
        }

        System.out.println("\n" + myList);

        myList.add(0, 4);
        myList.add(1, 5);

        System.out.println(myList);

        myList.remove((Integer) 2);

        System.out.println(myList);

        myList.remove(1);

        System.out.println(myList);

        myList.add(7);
        myList.add(5);
        myList.add(9);
        myList.add(0);

        System.out.println(myList);

        myList.sort();

        System.out.println(myList);
        System.out.println(myList.contains(8));
        System.out.println(myList.contains(3));

        myList.clear();

        System.out.println(myList);
    }
    public static void main(String[] args) {
        //TestStudent();
        TestInteger();
    }
}