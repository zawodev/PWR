public class BrassInstrument extends Instrument{
    private int lt;

    public BrassInstrument(){
        super("Golden Trumpet");
        lt = 1;
    }
    public BrassInstrument(String name, int a){
        super(name);
        lt = a;
    }

    @Override
    public void Play() {
        for(int i = 0; i<lt; i++){
            System.out.print(makeSound() + " ");
        }
        System.out.print("\n");
    }

    @Override
    public String toString() {
        return "Brass Instrument: " + getName() + ", lt: " + lt;
    }

    @Override
    public String makeSound() {
        return "Tra ta ta";
    }
    @Override
    public int getCount(){
        return lt;
    }
}
