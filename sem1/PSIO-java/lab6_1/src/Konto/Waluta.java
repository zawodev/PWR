package Konto;

public class Waluta {
    private int type;

    public Waluta(int type) {
        this.type = type;
    }
    public Waluta() {
        type = 1;
    }

    public void setType(int type) {
        this.type = type;
    }

    public int getType() {
        return type;
    }
}
