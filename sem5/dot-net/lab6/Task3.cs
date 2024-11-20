using System;

class Task3 {
    public static void Start() {
        int[] numbers = { 5, 2, 8, 1, 4 };

        // -- sort
        Array.Sort(numbers);
        Console.WriteLine("Sorted: " + string.Join(", ", numbers));

        // -- reverse
        Array.Reverse(numbers);
        Console.WriteLine("Reversed: " + string.Join(", ", numbers));

        // index of
        int index = Array.IndexOf(numbers, 8);
        Console.WriteLine("Index of 8: " + index);

        // clear
        Array.Clear(numbers, 0, 2);
        Console.WriteLine("After Clear: " + string.Join(", ", numbers));

        // copy
        int[] copied = new int[5];
        Array.Copy(numbers, copied, numbers.Length);
        Console.WriteLine("Copied: " + string.Join(", ", copied));
    }
}
