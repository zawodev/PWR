package Konto;

import Osoba.Osoba;

public class Konto {
    private int index;
    private Waluta waluta;
    private boolean isActive;
    public Konto(){
        isActive = false;
    }
    public Konto(int index, Waluta waluta) {
        isActive = false;
        this.index = index;
        this.waluta = waluta;
    }
    public void activate(){
        Osoba.activateAccount(this);
    }
    public void deactivate(){
        Osoba.deactivateAccount(this);
    }
    public boolean isActive() {
        return isActive;
    }
    public void setActive(boolean active) {
        isActive = active;
    }
    public int getIndex() {
        return index;
    }
    public void setIndex(int index) {
        this.index = index;
    }
    public Waluta getWaluta() {
        return waluta;
    }
    public void setWaluta(Waluta waluta) {
        this.waluta = waluta;
    }
    public String getStan(){
        return "Index: " + getIndex() + ", Waluta: " + getWaluta().getType() + ", IsActive: " + isActive();
    }
}
