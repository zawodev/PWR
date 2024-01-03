package Osoba;

import Konto.Konto;

public class Osoba {

    public static void activateAccount(Konto konto){
        konto.setActive(true);
    }
    public static void deactivateAccount(Konto konto){
        konto.setActive(false);
    }
}
