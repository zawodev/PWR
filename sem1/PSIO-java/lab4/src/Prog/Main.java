package Prog;

import java.util.Scanner;
import Wielomian.Wielomian;

public class Main {
    public static void Zad1_Wyswietl(){
        System.out.printf("%s%n", "[K] Kula");
        System.out.printf("%s%n", "[P] Prostopadloscian");
        System.out.printf("%s%n", "[S] Stop");
    }
    public static double AreaK(double a){
        return 4*Math.PI*a*a;
    }
    public static double VolumeK(double a){
        return (4.0/3.0)*Math.PI*a*a*a;
    }
    public static double AreaP(double a, double b, double c){
        return 2.0*(a*b + a*c + b*c);
    }
    public static double VolumeP(double a, double b, double c){
        return a*b*c;
    }
    public static boolean Zad1_Oblicz(String s){
        switch (s){
            case "K":
                System.out.printf("%s%f%n", "Pole Kuli wynosi: ", AreaK(10.0));
                System.out.printf("%s%f%n", "Objetosc Kuli wynosi: ", VolumeK(10.0));
                break;
            case "P":
                System.out.printf("%s%f%n", "Pole Prostopadloscianu wynosi: ", AreaP(10.0, 12.0, 15.0));
                System.out.printf("%s%f%n", "Objetosc Prostopadloscianu wynosi: ", VolumeP(10.0, 12.0, 15.0));
                break;
            case "S":
                System.out.printf("%s%n", "Program stopped.");
                return false;
            default:
                System.out.printf("%s%n", "Not a valid input. Try again.");
        }
        return true;
    }
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);

        //zad 1
        String s;
        do {
            Zad1_Wyswietl();
            s = in.nextLine();
        }
        while (Zad1_Oblicz(s));

        //zad2
        Wielomian wielomian = new Wielomian();

        System.out.printf("%n%s", "X: ");
        int x = in.nextInt();
        System.out.printf("%s", "N: ");
        int n = in.nextInt();

        int h = wielomian.Hermite(x, n);
        System.out.printf("%d%n", h);

        //zad3
    }
}