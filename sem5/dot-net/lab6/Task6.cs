using System;

class Task6 {
    static (int evenInts, int positiveDoubles, int longStrings, int otherTypes) CountMyTypes(params object[] items) {
        int evenInts = 0, positiveDoubles = 0, longStrings = 0, otherTypes = 0;

        foreach (var item in items) {
            switch (item) {
                case int i when i % 2 == 0:
                    evenInts++;
                    break;
                case double d when d > 0:
                    positiveDoubles++;
                    break;
                case string s when s.Length >= 5:
                    longStrings++;
                    break;
                default:
                    otherTypes++;
                    break;
            }
        }

        return (evenInts, positiveDoubles, longStrings, otherTypes);
    }

    public static void Start() {
        var result = CountMyTypes(2, 3.5, "hello", 8, -2.1, "hi", 'c', true, 3);

        Console.WriteLine($"Even integers: {result.evenInts}");
        Console.WriteLine($"Positive doubles: {result.positiveDoubles}");
        Console.WriteLine($"Strings >= 5 chars: {result.longStrings}");
        Console.WriteLine($"Other types: {result.otherTypes}");
    }
}
