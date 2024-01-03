public class Orchestra {
    public static Instrument[] instruments = new Instrument[20];
    public static int n = 10;

    public static void main(String[] args) {
        instruments[0] = new BrassInstrument("Trumpet", 1);
        instruments[1] = new BrassInstrument();
        instruments[2] = new BrassInstrument("Clarinet", 3);
        instruments[3] = new StringInstrument("Viola", 2);
        instruments[4] = new BrassInstrument("Trombone", 2);

        instruments[5] = new StringInstrument("Violin", 1);
        instruments[6] = new BrassInstrument("Tuba", 1);
        instruments[7] = new StringInstrument("Cello", 5);
        instruments[8] = new StringInstrument();
        instruments[9] = new StringInstrument("Contrabass", 4);

        //a
        for (int i = 0; i<n; i++){
            System.out.println(instruments[i].toString());
        }
        System.out.print("\n");
        //b
        for (int i = 0; i<n; i++){
            instruments[i].Play();
        }
        System.out.print("\n");
        //c
        int num = 0;
        Instrument maxIn = instruments[num];
        for (int i = 1; i<n; i++){
            if(maxIn.getCount() < instruments[i].getCount()){
                maxIn = instruments[i];
                num = i;
            }
        }
        System.out.println(maxIn.toString() + ", Index in Array: " + num + "\n");
        //d
        for (int i = 0; i<n; i++){
            if(instruments[i] instanceof BrassInstrument){
                System.out.println(instruments[i].toString());
            }
        }
        System.out.print("\n");
        //e
        for (int i = 0; i<n; i++){
            if(instruments[i] instanceof StringInstrument){
                System.out.println(instruments[i].toString());
            }
        }
        System.out.print("\n");
        //f
        num = 0;
        for (int i = 0; i<n; i++){
            if(instruments[i] instanceof StringInstrument && ((StringInstrument)instruments[i]).isContrabass()){
                num += instruments[i].getCount();
            }
        }
        /*
        for (int i = 0; i<n; i++){
            if(instruments[i].getName() == "Contrabass"){
                num += instruments[i].getCount();
            }
        }
        */
        System.out.println("Contrabass count: " + num);
    }
}
