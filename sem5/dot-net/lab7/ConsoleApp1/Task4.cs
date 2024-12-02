using System;
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
            // a. task
            //get example class from string
            Type type = Type.GetType("ExampleClass"); // namespace.class

            object obj1 = Activator.CreateInstance(type);
            object obj2 = Activator.CreateInstance(type);

            // task b. invoke add method 
            //Type type = obj1.GetType();
            MethodInfo addMethod = type.GetMethod("Add");

            if (addMethod != null) {
                object result1 = addMethod.Invoke(obj1, new object[] { 5, 7 });
                Console.WriteLine($"Result of Add(5, 7): {result1}");
            }

            // invoke concatenate method using mechanizm odbicia
            MethodInfo concatenateMethod = type.GetMethod("Concatenate");

            if (concatenateMethod != null) {
                object result2 = concatenateMethod.Invoke(obj2, new object[] { "Hello", " World" });
                Console.WriteLine($"Result of Concatenate(\"Hello\", \" World\"): {result2}");
            }
        }
    }
}
