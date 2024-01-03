public class Converter {
    private static final double converter = 1.8;
    public static double FtoC(double x){
        return Round((x-32)/converter);
    }
    public static double CtoF(double x){
        return Round(x*converter+32);
    }
    public static double Round(double x){
        return Math.round(x*100.0)/100.0;
    }
}
