public class StringInstrument extends Instrument{
    private int ls;

    public StringInstrument(){
        super("Stradivarius");
        ls = 1;
    }
    public StringInstrument(String name, int a){
        super(name);
        ls = a;
    }
    public boolean isContrabass(){
        return getName() == "Contrabass";
    }
    @Override
    public void Play() {
        for(int i = 0; i<ls; i++){
            System.out.print(makeSound() + " ");
        }
        System.out.print("\n");
    }

    @Override
    public String toString() {
        return "String Instrument: " + getName() + ", ls: " + ls;
    }

    @Override
    public String makeSound() {
        return "Smyk smyk smyk";
    }
    @Override
    public int getCount(){
        return ls;
    }
}
