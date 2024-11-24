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
                .GroupBy(t => t)          // group by topic name
                .ToDictionary(g => g.Key, g => g.Count()) // create dictionary with topic and its count
                .OrderByDescending(kv => kv.Value)       // sort by frequency descending
                .ToDictionary(kv => kv.Key, kv => kv.Value); // return sorted dictionary
        }

        // task b: sort topics by frequency within each gender
        public static Dictionary<Gender, Dictionary<string, int>> SortTopicsByGenderAndFrequency(List<StudentWithTopics> students) {
            return students
                .GroupBy(s => s.Gender) // group students by gender
                .ToDictionary(
                    g => g.Key, // key: gender
                    g => g.SelectMany(s => s.Topics) // flatten topics for the gender group
                          .GroupBy(t => t)           // group by topic
                          .ToDictionary(tg => tg.Key, tg => tg.Count()) // create topic-frequency dictionary
                          .OrderByDescending(kv => kv.Value) // sort by frequency descending
                          .ToDictionary(kv => kv.Key, kv => kv.Value) // return sorted dictionary for each gender
                );
        }
    }
}
