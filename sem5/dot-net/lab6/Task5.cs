using System;

class Task5 {
    static void DrawCard(string line1, string line2 = "", char borderChar = 'X', int borderWidth = 1, int minWidth = 20) {
        // obliczenie finalnej szerokości całej wizytówki
        int cardWidth = Math.Max(minWidth, Math.Max(line1.Length, line2.Length) + 2 * borderWidth);

        // rysowanie górnej części ramki
        for (int i = 0; i < borderWidth; i++) {
            Console.WriteLine(new string(borderChar, cardWidth));
        }

        // wycentrowanie napisów (indexy na których zaczynają się napisy)
        int line1Padding = (cardWidth - line1.Length - 2 * borderWidth) / 2;
        int line2Padding = (cardWidth - line2.Length - 2 * borderWidth) / 2;

        // rysowanie pierwszej linii z napisem
        Console.WriteLine($"{new string(borderChar, borderWidth)}{new string(' ', line1Padding)}{line1}{new string(' ', cardWidth - line1.Length - line1Padding - 2 * borderWidth)}{new string(borderChar, borderWidth)}");

        // rysowanie drugiej linii z napisem
        Console.WriteLine($"{new string(borderChar, borderWidth)}{new string(' ', line2Padding)}{line2}{new string(' ', cardWidth - line2.Length - line2Padding - 2 * borderWidth)}{new string(borderChar, borderWidth)}");

        // rysowanie dolnej części ramki
        for (int i = 0; i < borderWidth; i++) {
            Console.WriteLine(new string(borderChar, cardWidth));
        }
    }

    public static void Start() {
        // paramerty domyślne
        DrawCard("Pawelec");
        Console.WriteLine();

        // parametry nazwane
        DrawCard(line1: "Karol", line2: "Pan", borderChar: '#', borderWidth: 2, minWidth: 20);
        Console.WriteLine();

        // zmiana szerokości wizytówki
        DrawCard("Jan Walus", borderWidth: 3, minWidth: 0);
        Console.WriteLine();
    }
}