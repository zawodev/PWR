import java.util.Collections;
import java.util.Random;
import java.util.Scanner;

public class Main {
    public static void PrintMenu() {
        System.out.println("\nPolygons : ");
        System.out.println("1. Create Shape.Triangle");
        System.out.println("2. Create Shape.Rectangle");
        System.out.println("3. Print All Polygons");
        System.out.println("4. Create Comparators");
        System.out.println("5. Sort By Color");
        System.out.println("6. Sort By A");
        System.out.println("7. Sort By Color than A");
        System.out.println("8. Sort By Perimeter");
        System.out.println("9. Show Biggest Perimeter");
        System.out.println("0. Exit");
    }
    public static void main(String[] args){
        Scanner in = new Scanner(System.in);
        Polygons P = new Polygons();
        Random rand = new Random();
        PrintMenu();
        P.CreateTriangle("aaaaa", 5, 12, 13, true);
        P.CreateTriangle("bbbbb", 5, 12, 13, true);
        P.CreateTriangle("aaaaa", 3, 4, 5, true);

        while(in.hasNext()){
            int choice = in.nextInt();
            if(choice != 0){
                System.out.print("\n");
                String s = "";
                int a = 0;
                int b = 0;
                int c = 0;
                int d = 0;
                switch (choice){
                    case 1:
                        s = rand.ints(97, 123).limit(5).collect(StringBuilder::new, StringBuilder::appendCodePoint, StringBuilder::append).toString();
                        a = rand.nextInt(1, 10);
                        b = rand.nextInt(1, 10);
                        c = rand.nextInt(1, 10);
                        d = Math.max(a, Math.max(b, c));
                        P.CreateTriangle(s, a, b, c, 2*d > a+b+c);
                        System.out.println("New Shape.Triangle Created!");
                        break;
                    case 2:
                        s = rand.ints(97, 123).limit(5).collect(StringBuilder::new, StringBuilder::appendCodePoint, StringBuilder::append).toString();
                        a = rand.nextInt(1, 10);
                        b = rand.nextInt(1, 10);
                        P.CreateRect(s, a, b, a==b);
                        System.out.println("New Shape.Rectangle Created!");
                        break;
                    case 3:
                        P.ViewPolygons();
                        break;
                    case 4:
                        P.CreateComparators();
                        System.out.println("New Comparators Created!");
                        break;
                    case 5:
                        Collections.sort(P.getShapes(), P.getColorComparator());
                        System.out.println("Sorted!");
                        break;
                    case 6:
                        Collections.sort(P.getShapes(), P.getSideComparator());
                        System.out.println("Sorted!");
                        break;
                    case 7:
                        Collections.sort(P.getShapes(), P.getBothComparator());
                        System.out.println("Sorted!");
                        break;
                    case 8:
                        Collections.sort(P.getShapes());
                        System.out.println("Sorted!");
                        break;
                    case 9:
                        Collections.sort(P.getShapes());
                        P.ViewPolygon(P.getShapes().size()-1);
                        break;
                    default:
                        System.out.println("No such choice");
                        break;
                }
                PrintMenu();
            }
            else
                break;
        }
    }
}
