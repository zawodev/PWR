﻿using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

public class ExampleClass {
    public int Add(int a, int b) {
        return a + b;
    }

    public string Concatenate(string str1, string str2) {
        return str1 + str2;
    }
}

namespace ConsoleApp1 {
    class Task4 {
        public static void Start() {
            // a. Create objects of the class and store them in variables of type object
            object obj1 = new ExampleClass();
            object obj2 = new ExampleClass();

            // b. Invoke the 'Add' method using reflection
            Type type = obj1.GetType();
            MethodInfo addMethod = type.GetMethod("Add");

            if (addMethod != null) {
                object result1 = addMethod.Invoke(obj1, new object[] { 5, 7 });
                Console.WriteLine($"Result of Add(5, 7): {result1}");
            }

            // Invoke the 'Concatenate' method using reflection
            MethodInfo concatenateMethod = type.GetMethod("Concatenate");

            if (concatenateMethod != null) {
                object result2 = concatenateMethod.Invoke(obj2, new object[] { "Hello", " World" });
                Console.WriteLine($"Result of Concatenate(\"Hello\", \" World\"): {result2}");
            }
        }
    }
}