import java.io.BufferedWriter;
import java.io.FileWriter;
import java.util.Scanner;

public class Shop {
    public static void PrintMenu() {
        System.out.println("\nShop Menu : ");
        System.out.println("1. Add Example Transactions");
        System.out.println("2. Show All Transactions");
        System.out.println("3. Add Transaction");
        System.out.println("4. SeniorCard Count");
        System.out.println("5. StudentCard Most Amount");
        System.out.println("6. Save To File");
        System.out.println("0. Exit");
    }
    public static void GenerateTestClients(){
        C[0] = new NormalCard(0, "Adamczyk");
        C[1] = new StudentCard(1, "Brudzewski");
        C[2] = new SeniorCard(2, "Cegła");

        C[3] = new NormalCard(3, "Daniluk");
        C[4] = new StudentCard(4, "Epsilon");
        C[5] = new SeniorCard(5, "Florczak");

        C[6] = new StudentCard(6, "Gierczak");
        C[7] = new StudentCard(7, "Hojny");
        C[8] = new StudentCard(8, "Igła");
    }
    public static void AddExampleTransactions(){
        AddTransaction(C[0], 15.97);
        AddTransaction(C[1], 13.00);
        AddTransaction(C[2], 52.01);

        AddTransaction(C[3], 84.18);
        AddTransaction(C[4], 22.02);
        AddTransaction(C[5], 92.44);

        AddTransaction(C[6], 76.23);
        AddTransaction(C[7], 11.11);
        AddTransaction(C[8], 65.23);

        System.out.println("Success!");
    }
    public static void ShowAllTransactions(){
        for(int i = 0; i<Transaction.transactionNum; i++){
            System.out.println(T[i].toString());
        }
    }
    public static void AddTransaction(ClientCard card, double amount){
        T[Transaction.transactionNum++] = new Transaction(card, amount);
        System.out.println("Success!");
    }
    public static int SeniorCardCount(){
        int counter = 0;
        for(int i = 0; i<Transaction.transactionNum; i++){
            if(T[i].card instanceof SeniorCard){
                counter++;
            }
        }
        return counter;
    }
    public static void ShowStudentCardMostAmount(){
        StudentCard studentCard = null;
        double amount = 0.0;
        for(int i = 0; i<Transaction.transactionNum; i++){
            if(T[i].card instanceof StudentCard && T[i].AmountAfterDiscount() > amount){
                amount = T[i].AmountAfterDiscount();
                studentCard = (StudentCard)T[i].card;
            }
        }
        System.out.println(studentCard + ", Amount: " + amount);
    }
    public static void SaveToFile(){
        try {
            BufferedWriter bw = new BufferedWriter(new FileWriter("zad6.txt"));
            for(int i = 0; i<Transaction.transactionNum; i++){
                if(T[i].card instanceof StudentCard){
                    bw.write(T[i].toString());
                    bw.newLine();
                }
            }
            bw.close();
            System.out.println("Success!");
        }
        catch (Exception e){
            e.printStackTrace();
        }
    }
    static Scanner in = new Scanner(System.in);
    static Transaction[] T = new Transaction[100];
    static ClientCard[] C = new ClientCard[10];
    public static void main(String[] args){
        PrintMenu();
        GenerateTestClients();
        while(in.hasNext()){
            int choice = in.nextInt();
            if(choice != 0){
                System.out.print("\n");
                switch (choice){
                    case 1:
                        AddExampleTransactions();
                        break;
                    case 2:
                        ShowAllTransactions();
                        break;
                    case 3:
                        AddTransaction(C[7], 17.99);
                        break;
                    case 4:
                        System.out.println("SeniorCardCount: " + SeniorCardCount());
                        break;
                    case 5:
                        ShowStudentCardMostAmount();
                        break;
                    case 6:
                        SaveToFile();
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
