package Wielomian;

public class Wielomian {
    /**
     * <h1>Hermite :)</h1>
     * Hermite Wielomian Wielomian Hermit
     * @author zawo
     * @param x pierwszy parametr funkcji
     * @param n drugi parametr funkcji
     * @return int
     */
    public static int Hermite(int x, int n){
        int __h = 1;
        int _h = 2*x;
        int h = 0;
        for (int i = 2; i<=n; i++){
            h = 2*x*_h - 2*(i-1)*__h;
            __h = _h;
            _h = h;
        }
        switch (n){
            case 0:
                return __h;
            case 1:
                return _h;
            default:
                return h;
        }
    }
}
