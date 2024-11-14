using System;

class Program {
    static void Main(string[] args) {
        Console.WriteLine("Podaj współczynniki równania kwadratowego ax^2 + bx + c = 0");

        Console.Write("Podaj a: ");
        if (!double.TryParse(Console.ReadLine(), out double a)) {
            Console.WriteLine("Podana wartość nie jest liczbą, przyjmuję a = 0.");
            a = 0; // wartość domyślna
        }

        Console.Write("Podaj b: ");
        if (!double.TryParse(Console.ReadLine(), out double b)) {
            Console.WriteLine("Podana wartość nie jest liczbą, przyjmuję b = 0.");
            b = 0; // wartość domyślna
        }

        Console.Write("Podaj c: ");
        if (!double.TryParse(Console.ReadLine(), out double c)) {
            Console.WriteLine("Podana wartość nie jest liczbą, przyjmuję c = 0.");
            c = 0; // wartość domyślna
        }
        PrintSolution(SolveQuadraticEquation(a, b, c));
        Console.WriteLine("");
        PrintSolution(SolveQuadraticEquation(1, 2, 3));
        PrintSolution(SolveQuadraticEquation(1, 3, 2));
        PrintSolution(SolveQuadraticEquation(1, 2, 1));
        PrintSolution(SolveQuadraticEquation(0, 4, 2));
        PrintSolution(SolveQuadraticEquation(0, 0, 5));
        PrintSolution(SolveQuadraticEquation(0, 0, 0));
    }

    static (int, double?, double?) SolveQuadraticEquation(double a, double b, double c) {
        // jeśli a = 0, równanie jest liniowe
        if (a == 0) {
            if (b == 0) {
                if (c == 0) return (-1, null, null); // nieskończenie wiele rozwiązań
                else return (0, null, null); // brak rozwiązania, jeśli b = 0 i c ≠ 0
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
    static void PrintSolution((int solutionCount, double? x1, double? x2) tuple) {
        switch (tuple.solutionCount) {
            case -1:
                Console.WriteLine("Równanie ma nieskończenie wiele rozwiązań.");
                break;
            case 0:
                Console.WriteLine("Równanie nie ma rozwiązań rzeczywistych.");
                break;
            case 1:
                Console.WriteLine("Jedno rozwiązanie: x = {0:F2}", tuple.x1); // formatowanie złożone
                break;
            case 2:
                Console.WriteLine($"Dwa rozwiązania: x1 = {tuple.x1:F2}, x2 = {tuple.x2:F2}"); // interpolacja łańcucha
                break;
        }
    }
}
