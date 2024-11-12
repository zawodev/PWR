using System;

class Program {
    static void Main(string[] args) {
        Console.WriteLine("Podaj współczynniki równania kwadratowego ax^2 + bx + c = 0");

        Console.Write("Podaj a: ");
        double a = double.Parse(Console.ReadLine());

        Console.Write("Podaj b: ");
        double b = double.Parse(Console.ReadLine());

        Console.Write("Podaj c: ");
        double c = double.Parse(Console.ReadLine());

        (int solutionCount, double? x1, double? x2) = SolveQuadraticEquation(a, b, c);

        switch (solutionCount) {
            case 0:
                Console.WriteLine("Równanie nie ma rozwiązań rzeczywistych.");
                break;
            case 1:
                Console.WriteLine("Jedno rozwiązanie: x = {0:F2}", x1); // formatowanie złożone
                break;
            case 2:
                Console.WriteLine($"Dwa rozwiązania: x1 = {x1:F2}, x2 = {x2:F2}"); // interpolacja łańcucha
                break;
        }
    }

    static (int, double?, double?) SolveQuadraticEquation(double a, double b, double c) {
        // jeśli a = 0, równanie jest liniowe
        if (a == 0) {
            if (b == 0) {
                return (0, null, null); // brak rozwiązania, jeśli b = 0 i c ≠ 0
            } else {
                double x = -c / b;
                return (1, x, null); // jedno rozwiązanie liniowe
            }
        }

        double delta = b * b - 4 * a * c;

        if (delta < 0) {
            return (0, null, null); // brak rozwiązań rzeczywistych
        } else if (delta == 0) {
            double x = -b / (2 * a);
            return (1, x, null); // jedno rozwiązanie
        } else {
            double x1 = (-b + Math.Sqrt(delta)) / (2 * a);
            double x2 = (-b - Math.Sqrt(delta)) / (2 * a);
            return (2, x1, x2); // dwa rozwiązania
        }
    }
}
