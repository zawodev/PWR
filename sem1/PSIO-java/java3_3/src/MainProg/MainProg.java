package MainProg;

import Biblioteka.Biblioteka;

import java.math.BigDecimal;
import java.math.RoundingMode;
import java.util.Scanner;

public class MainProg {
    public static void main(String[] args) {
        Scanner in = new Scanner(System.in);
        double x = in.nextDouble();
        int n = in.nextInt();

        System.out.printf("%s%n", "Sin(x): " + BigDecimal.valueOf(Biblioteka.Sin(x)).setScale(n, RoundingMode.HALF_UP));
        System.out.printf("%s%n", "Cos(x): " + BigDecimal.valueOf(Biblioteka.Cos(x)).setScale(n, RoundingMode.HALF_UP));
        System.out.printf("%s%n", "Exp(x): " + BigDecimal.valueOf(Biblioteka.Exp(x)).setScale(n, RoundingMode.HALF_UP));
    }
}