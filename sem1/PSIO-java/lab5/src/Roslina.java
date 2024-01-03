public class Roslina {
    public int dlugosc;
    public Roslina(){
        dlugosc = 1;
    }
    public void Rosnij(){
        if(dlugosc>0)dlugosc++;
    }
    public void RosnijDuzo(int n){
        if(dlugosc>0)dlugosc+=n;
        //if(dlugosc<0)dlugosc=0;
    }
    public void MalejDuzo(int n){
        if (dlugosc >= n) dlugosc-=n; //return true
        else dlugosc = 0; //return false
    }
    public void Pokaz(){
        System.out.printf("%s%d%n", "Length: ", dlugosc);
    }
}