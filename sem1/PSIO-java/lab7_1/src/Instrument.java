public abstract class Instrument {
    private String name;

    public String getName() {
        return name;
    }
    public void setName(String name) {
        this.name = name;
    }
    public Instrument(){
        name = "";
    }
    public Instrument(String name){
        this.name = name;
    }
    public String toString(){
        return "Instrument name: " + name;
    }
    public abstract String makeSound();
    public abstract void Play();
    public abstract int getCount();
}
