using System;

class Task4 {
    public static void Start() {
        var person = new { Name = "Jan", Surname = "Kowalski", Age = 41, Salary = 5512.0 }; //typ anonimowy

        Console.WriteLine($"Name: {person.Name}, Surname: {person.Surname}, Age: {person.Age}, Salary: {person.Salary}");
    }
}
