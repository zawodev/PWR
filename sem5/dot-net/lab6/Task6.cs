using System;

class Task6 {
    static void CountMyTypes(params object[] items) {
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

        Console.WriteLine($"Even integers: {evenInts}");
        Console.WriteLine($"Positive doubles: {positiveDoubles}");
        Console.WriteLine($"Strings >= 5 chars: {longStrings}");
        Console.WriteLine($"Other types: {otherTypes}");
    }

    public static void Start() {
        CountMyTypes(2, 3.5, "hello", 8, -2.1, "hi", 'c', true, 3);
    }
}
