using System;

class MainProgram {
    static void Main() {
        bool running = true;

        while (running) {
            Console.WriteLine("select a task to run:");
            Console.WriteLine("1. tuple stuff");
            Console.WriteLine("2. variable with name class");
            Console.WriteLine("3. system.array methods");
            Console.WriteLine("4. anonymous type (task1)");
            Console.WriteLine("5. drawcard method");
            Console.WriteLine("6. countmytypes method");
            Console.WriteLine("7. exit");
            Console.Write("enter the task number (1-6): ");

            string choice = Console.ReadLine();
            Console.WriteLine("------------------------------");

            switch (choice) {
                case "1":
                    Task1.Start();
                    break;
                case "2":
                    Task2.Start();
                    break;
                case "3":
                    Task3.Start();
                    break;
                case "4":
                    Task4.Start();
                    break;
                case "5":
                    Task5.Start();
                    break;
                case "6":
                    Task6.Start();
                    break;
                case "7":
                    Console.WriteLine("program finished");
                    running = false;
                    break;
                default:
                    Console.WriteLine("invalid choice, please enter a number between 1 and 6.");
                    break;
            }

            Console.WriteLine("------------------------------");
        }
    }
}
