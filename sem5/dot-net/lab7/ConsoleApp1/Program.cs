using ConsoleApp1;
using System;
using System.Collections.Generic;
using System.Linq;

public class Department(int id, string name) {
    public int Id { get; set; } = id;
    public String Name { get; set; } = name;

    public override string ToString() {
        return $"{Id,2}), {Name,11}";
    }

}

public enum Gender {
    Female,
    Male
}

public class StudentWithTopics(int id, int index, string name, Gender gender, bool active,
    int departmentId, List<string> topics) {
    public int Id { get; set; } = id;
    public int Index { get; set; } = index;
    public string Name { get; set; } = name;
    public Gender Gender { get; set; } = gender;
    public bool Active { get; set; } = active;
    public int DepartmentId { get; set; } = departmentId;

    public List<string> Topics { get; set; } = topics;

    public override string ToString() {
        var result = $"{Id,2}) {Index,5}, {Name,11}, {Gender,6},{(Active ? "active" : "no active"),9},{DepartmentId,2}, topics: ";
        foreach (var str in Topics)
            result += str + ", ";
        return result;
    }
}

public static class Generator {
    public static int[] GenerateIntsEasy() {
        return [5, 3, 9, 7, 1, 2, 6, 7, 8];
    }

    public static int[] GenerateIntsMany() {
        var result = new int[10000];
        Random random = new();
        for (int i = 0; i < result.Length; i++)
            result[i] = random.Next(1000);
        return result;
    }

    public static List<string> GenerateNamesEasy() {
        return [
            "Nowak",
            "Kowalski",
            "Schmidt",
            "Newman",
            "Bandingo",
            "Miniwiliger",
            "Showner",
            "Neumann",
            "Rocky",
            "Bruno"
        ];
    }
    public static List<StudentWithTopics> GenerateStudentsWithTopicsEasy() {
        return new List<StudentWithTopics> {
            new StudentWithTopics(1, 12345, "Nowak", Gender.Female, true, 1, ["C#","PHP","algorithms"]),
            new StudentWithTopics(2, 13235, "Kowalski", Gender.Male, true, 1, ["C#","C++","fuzzy logic"]),
            new StudentWithTopics(3, 13444, "Schmidt", Gender.Male, false, 2, ["Basic","Java"]),
            new StudentWithTopics(4, 14000, "Newman", Gender.Female, false, 3, ["JavaScript","neural networks"]),
            new StudentWithTopics(5, 14001, "Bandingo", Gender.Male, true, 3, ["Java","C#"]),
            new StudentWithTopics(6, 14100, "Miniwiliger", Gender.Male, true, 2, ["algorithms","web programming"]),
            new StudentWithTopics(11, 22345,"Nowak", Gender.Female, true, 2, ["C#","PHP","web programming"]),
            new StudentWithTopics(12, 23235, "Nowak", Gender.Male, true, 1, ["C#","C++","fuzzy logic"]),
            new StudentWithTopics(13, 23444, "Showner", Gender.Male, false, 2, ["Basic","C#"]),
            new StudentWithTopics(14, 24000, "Neumann", Gender.Female, false, 3, ["JavaScript","neural networks"]),
            new StudentWithTopics(15, 24001, "Rocky", Gender.Male, true, 2, ["fuzzy logic","C#"]),
            new StudentWithTopics(16, 24100, "Bruno", Gender.Female, false, 2, ["algorithms","web programming"])
        };
    }

    public static List<Department> GenerateDepartmentsEasy() {
        return [
        new Department(1,"Computer Science"),
            new Department(2,"Electronics"),
            new Department(3,"Mathematics"),
            new Department(4,"Mechanics")
        ];
    }

}

public class Program {
    public static void Main() {
        Console.WriteLine("\n--------------------- TASK 1 ---------------------\n");
        Task1.Start();
        Console.WriteLine("\n--------------------- TASK 2 ---------------------\n");
        Task2.Start();
        Console.WriteLine("\n--------------------- TASK 3 ---------------------\n");
        Task3.Start();
        Console.WriteLine("\n--------------------- TASK 4 ---------------------\n");
        Task4.Start();
    }
}
