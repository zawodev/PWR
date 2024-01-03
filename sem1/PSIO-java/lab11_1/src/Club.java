import Coach.Coach;
import Coach.CoachMichniewicz;
import Coach.CoachScaloni;
import Goalkeeper.JumpPractice;
import Goalkeeper.LagaPractice;

import java.io.*;
import java.util.Scanner;

public class Club {
    public static void PrintMenu() {
        System.out.println("\nShop Menu : ");
        System.out.println("1. Hire Czesław Michniewicz");
        System.out.println("2. Train All Players");
        System.out.println("3. Hire Lionel Scaloni");
        System.out.println("4. Show Progress");
        System.out.println("5. Change Goalkeepers Strategy to Laga");
        System.out.println("6. Change Goalkeepers Strategy to Jump");
        System.out.println("7. Serialize");
        System.out.println("8. Read Serialized Files");
        System.out.println("0. Exit");
    }
    public static void main(String[] args){
        Scanner in = new Scanner(System.in);
        Coach coach = null;

        PrintMenu();
        while(in.hasNext()){
            int choice = in.nextInt();
            if(choice != 0){
                System.out.print("\n");
                switch (choice){
                    case 1:
                        coach = new CoachMichniewicz();
                        System.out.println("Zatrudniono Trenera Michniewicza!");
                        break;
                    case 2:
                        if(coach != null) {
                            coach.trainGK();
                            coach.trainST();
                            System.out.println("Trening zakończony sukcesem!");
                        }
                        else System.out.println("Brak zatrudnionego trenera!");
                        break;
                    case 3:
                        coach = new CoachScaloni();
                        System.out.println("Zatrudniono Trenera Scaloniego!");
                        break;
                    case 4:
                        if(coach != null) {
                            System.out.println(coach.ShowInfo());
                        }
                        else System.out.println("Brak zatrudnionego trenera!");
                        break;
                    case 5:
                        if(coach!=null) {
                            coach.setAlgorytmInfoGK(new LagaPractice());
                            System.out.println("Strategia została zmieniona na Lagę!");
                        }
                        else System.out.println("Brak zatrudnionego trenera!");
                        break;
                    case 6:
                        if(coach!=null) {
                            coach.setAlgorytmInfoGK(new JumpPractice());
                            System.out.println("Strategia została zmieniona na Skok!");
                        }
                        else System.out.println("Brak zatrudnionego trenera!");
                        break;
                    case 7:
                        try(ObjectOutputStream so = new ObjectOutputStream(new FileOutputStream("coachdata.ser"))){
                            so.writeObject(coach);
                            System.out.println("File saved successfully!");
                        }
                        catch (IOException e){
                            e.printStackTrace();
                        }
                        break;
                    case 8:
                        try(ObjectInputStream is = new ObjectInputStream(new FileInputStream("coachdata.ser"))){
                            coach = (Coach) is.readObject();
                            System.out.println("File loaded successfully!");
                        }
                        catch (IOException | ClassNotFoundException e){
                            e.printStackTrace();
                        }
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
