using System;

class Task1 {
    public static void Start() {
        var person = ("Jan", "Kowalski", 41, 5512.0);

        // bezpośredni dostęp do pól krotki
        Console.WriteLine($"Name: {person.Item1}, Surname: {person.Item2}, Age: {person.Item3}, Salary: {person.Item4}");

        // deconstruction
        var (firstName, lastName, age, salary) = person;
        Console.WriteLine($"Name: {firstName}, Surname: {lastName}, Age: {age}, Salary: {salary}");

        // iteracja przez obiekt
        Console.WriteLine(string.Join(", ", person.ToString()));

        TestFunction(person);
    }
    private static void TestFunction((string firstName, string lastName, int age, double salary) person) {
        Console.WriteLine("\nInside TestFunction:");
        Console.WriteLine($"First Name: {person.firstName}");
        Console.WriteLine($"Last Name: {person.lastName}");
        Console.WriteLine($"Age: {person.age}");
        Console.WriteLine($"Salary: {person.salary}");
    }
}
