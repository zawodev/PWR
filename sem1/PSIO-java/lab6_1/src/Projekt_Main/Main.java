package Projekt_Main;

import Konto.Konto;
import Konto.Waluta;
import Osoba.Osoba;

import java.util.Random;
import java.util.Scanner;

public class Main {
    //static Scanner in = new Scanner(System.in);
    static Random rand = new Random();
    public static void DisplayAccount(Konto K){
        System.out.println(K.getStan());
    }
    public static void DisplayAllAccounts(Konto []K){
        for(int i = 0; i<K.length; i++){
            DisplayAccount(K[i]);
        }
        System.out.println("");
    }

    public static void main(String[] args) {
        int n = 10;
        Konto[] Bank = new Konto[n];
        for(int i = 0; i<Bank.length; i++) {
            Bank[i] = new Konto(i, new Waluta(rand.nextInt(1, 5)));
        }
        DisplayAllAccounts(Bank);
        Bank[2].activate();
        Bank[4].activate();
        Bank[5].activate();
        Bank[7].activate();
        DisplayAllAccounts(Bank);
        Bank[7].deactivate();
        DisplayAllAccounts(Bank);
    }
}