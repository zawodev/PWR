import java.util.Random;

public class Student {
    public static Random rand = new Random();
    private String name;
    private int wiek;
    private int wiedza;
    private int budzet;
    private int promile;
    public int GetPromile(){
        return promile;
    }
    public void SetPromile(int newVal){
        promile = newVal;
    }
    public String GetName(){
        return name;
    }
    public Student(){
        name = "";
        for(int i = 0; i<rand.nextInt(3,10); i++){
            name +=(char)(rand.nextInt('a','z'+1));}
        promile = rand.nextInt(1,99);
    }
    public Student(String name, int promile){
        this.name = name;
        this.promile = promile;
    }
}
