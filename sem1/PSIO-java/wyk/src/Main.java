import javax.swing.*;
import java.awt.*;
import java.io.*;
import java.util.Scanner;
public class Main {
    /*public static void Wypelnij(int [][]T){
        for (int i = 0; i<T.length; i++){
            for (int j = 0; j<T[i].length; j++){
                T[i][j] = 3;
            }
        }
    }
    public static void Wypisz(int [][]T){
        for (int i = 0; i<T.length; i++){
            for (int j = 0; j<T[i].length; j++){
                System.out.print(T[i][j]);
                System.out.print(" ");
            }
            System.out.print("\n");
        }
    }
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        int [][]T = new int[10][4];
        T[6][2] = 2;
        Wypelnij(T);
        Wypisz(T);
        int a = 3;
        System.out.println(a);
        try{
            BufferedReader bf = new BufferedReader(new FileReader("file.txt"));
            a = Integer.parseInt(bf.readLine());
            String s = bf.readLine();
        }
        catch (Exception e){

        }
        try{
            BufferedWriter bw = new BufferedWriter(new FileWriter("file.txt"));
            bw.write("" + a);
            bw.newLine();
            bw.write("dowolny strng");
            bw.newLine();
        }
        catch (Exception e){

        }
    }*/
    //class Kot extends Kotowane implements ZwierzakDomowy{}
    //24.11 WYKŁAD

    //in.hasNext();
    //in.nextLine();
    //Scanner in = new Scanner(new BufferedReader(new FileReader(plik)));

/*
* try(bufferedreadrr breader = new bufferedreader(..){
* }
* catch(Exception e){ //FileNotFoundException e // IOException e
* }
* finally{
* }
*how to parse string java
* string.split("!@#%&^*]");
*
* Thread.sleep(10);
*
*
*implements Serializable
*
*
*
* */
//08.12.2022

    /*public static void LoadFile() throws FileNotFoundException{
        File file = new File("name.txt");

        FileReader reader = new FileReader(plik);

    }*/
    /*public static void main (String[] args) throws FileNotFoundException{
    LoadFile();
    }

    }*/
    /*
    * try{
    * catch (e1 najogólniejszy bo pierwszy
    * catch (e2 mniej ogolny
    * catch (e3 jeszcze mniej
    * catch (e4 itd...
    * finally{
    *
    * if(a>4) throw new IllegalArgumentException("niepoprawna wartosc a");
    *   try{
    * cos cos cos...
    * throw
    * cos cos cos
    * }
    * catch()
    *
    *
    * class myexception extends Exception (bedzie na kolosie 2)
    *   public myexception (String s)
    *       super(s);
    *
    * @ovverrdie
    * public void printstacktrace(){
    *   super.printstacktrace
    *   system.out.errorprint(cosocos)
    *
    * @override
    *  get message
    * retrun super.getmessage()+"Ssdsda"
    *
    * if(a>10) throw new myxception("blllal")
    *
    * ob = null;
    * assert (ob!=null) "obiekt nie istnieje" + ob;
    *
    *  */
    public static void LLL(){

    }
    public static void main(String[] args) {
        JFrame ramka = new JFrame();
        JButton przycisk = new JButton("fdfd");
        ramka.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        ramka.getContentPane().add(przycisk);
        ramka.setSize(300, 300);
        ramka.setVisible(true);

        ramka.getContentPane().add(BorderLayout.SOUTH, przycisk); //NORTH, EAST, WEST, CENTER
        FlowLayout f;

        JPanel J = new JPanel();
        J.setLayout(new BoxLayout(J, BoxLayout.Y_AXIS));
        ramka.pack();
        ramka.setResizable(false);

        //przycisk.addActionListener(LLL);
        //class BUtonreakcja implements ActionListener //klasa w klasie
        //void actionPerformed(ActionEvene evnjnt)
        przycisk.setText("Sdsadsad");
        //if(event.getsource)
    }
}