using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp1 {
    class Task2 {
        public static void Start() {
            var students = Generator.GenerateStudentsWithTopicsEasy();

            // task a: topics sorted by frequency
            Console.WriteLine("Task a: Topics sorted by frequency");
            var topicsByFrequency = SortTopicsByFrequency(students);
            foreach (var topic in topicsByFrequency) {
                Console.WriteLine($"{topic.Key}: {topic.Value}");
            }
            Console.WriteLine();

            // task b: topics sorted by frequency within each gender
            Console.WriteLine("Task b: Topics sorted by frequency within each gender");
            var topicsByGenderAndFrequency = SortTopicsByGenderAndFrequency(students);
            foreach (var genderGroup in topicsByGenderAndFrequency) {
                Console.WriteLine($"Gender: {genderGroup.Key}");
                foreach (var topic in genderGroup.Value) {
                    Console.WriteLine($"{topic.Key}: {topic.Value}");
                }
                Console.WriteLine();
            }
        }
        // task a: sort topics by frequency
        public static Dictionary<string, int> SortTopicsByFrequency(List<StudentWithTopics> students) {
            return students
                .SelectMany(s => s.Topics) // flatten all topics into a single list
                .GroupBy(t => t)
                .ToDictionary(g => g.Key, g => g.Count())
                .OrderByDescending(kv => kv.Value)
                .ToDictionary(kv => kv.Key, kv => kv.Value);
        }

        // task b: sort topics by frequency within each gender
        public static Dictionary<Gender, Dictionary<string, int>> SortTopicsByGenderAndFrequency(List<StudentWithTopics> students) {
            return students
                .GroupBy(s => s.Gender) 
                .ToDictionary(
                    g => g.Key, // key: gender
                    g => g.SelectMany(s => s.Topics) // value: topics sorted by frequency
                          .GroupBy(t => t)
                          .ToDictionary(tg => tg.Key, tg => tg.Count()) 
                          .OrderByDescending(kv => kv.Value) 
                          .ToDictionary(kv => kv.Key, kv => kv.Value)
                );
        }
    }
}
