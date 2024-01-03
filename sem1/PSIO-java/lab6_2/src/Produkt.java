public class Produkt {
    private int kod;
    private double cena;

    public Produkt() {

    }

    public Produkt(int kod, double cena) {
        this.kod = kod;
        this.cena = cena;
    }

    public int getKod() {
        return kod;
    }

    public double getCena() {
        return cena;
    }

    public void setKod(int kod) {
        this.kod = kod;
    }

    public void setCena(double cena) {
        this.cena = cena;
    }
    public void getStan(){
        System.out.println("Kod: " + getKod() + ", Cena: " + getCena());
    }
}
