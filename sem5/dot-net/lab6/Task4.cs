using System;

class Task4 {
    public static void Start() {
        var person = new { Name = "Jan", Surname = "Kowalski", Age = 41, Salary = 5512.0 }; //typ anonimowy

        Console.WriteLine($"Name: {person.Name}, Surname: {person.Surname}, Age: {person.Age}, Salary: {person.Salary}");

        TestFunction(person);
    }
    private static void TestFunction(dynamic person) {
        Console.WriteLine("\nInside TestFunction:");
        Console.WriteLine($"First Name: {person.Name}");
        Console.WriteLine($"Last Name: {person.Surname}");
        Console.WriteLine($"Age: {person.Age}");
        Console.WriteLine($"Salary: {person.Salary}");
    }
}
