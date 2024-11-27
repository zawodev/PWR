using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

public class Topic {
    public int Id { get; set; }
    public string Name { get; set; }

    public Topic(int id, string name) {
        Id = id;
        Name = name;
    }

    public override string ToString() {
        return $"{Id}: {Name}";
    }
}

public class Student {
    public int Id { get; set; }
    public int Index { get; set; }
    public string Name { get; set; }
    public Gender Gender { get; set; }
    public bool Active { get; set; }
    public int DepartmentId { get; set; }
    public List<int> TopicIds { get; set; } = new();

    public override string ToString() {
        return $"{Id,2}) {Index,5}, {Name,11}, {Gender,6},{(Active ? "active" : "no active"),9},{DepartmentId,2}, topic IDs: {string.Join(", ", TopicIds)}";
    }
}

public class StudentToTopic {
    public int StudentId { get; set; }
    public int TopicId { get; set; }

    public StudentToTopic(int studentId, int topicId) {
        StudentId = studentId;
        TopicId = topicId;
    }

    public override string ToString() {
        return $"StudentId: {StudentId}, TopicId: {TopicId}";
    }
}

namespace ConsoleApp1 {
    class Task3 {
        public static void Start() {
            var studentsWithTopics = Generator.GenerateStudentsWithTopicsEasy();

            // task a:
            var topics = new List<Topic> {
                new Topic(1, "C#"),
                new Topic(2, "PHP"),
                new Topic(3, "algorithms"),
                new Topic(4, "C++"),
                new Topic(5, "fuzzy logic"),
                new Topic(6, "Basic"),
                new Topic(7, "Java"),
                new Topic(8, "JavaScript"),
                new Topic(9, "neural networks"),
                new Topic(10, "web programming"),
                new Topic(11, "IT")
            };

            // task b:
            var topicsFromStudents = GenerateTopicsFromStudents(studentsWithTopics);

            // display topics (task a and b):
            var students = TransformToStudents(studentsWithTopics, topics);
            Console.WriteLine("Students (list of topic IDs):");
            foreach (var student in students) {
                Console.WriteLine(student);
            }

            // task c:
            Console.WriteLine("\nRelation many-to-many (StudentToTopic):");
            var studentToTopic = TransformToStudentToTopic(studentsWithTopics, topics);
            foreach (var relation in studentToTopic) {
                Console.WriteLine(relation);
            }
        }
        // task a: map students with topics to students with topics
        public static List<Student> TransformToStudents(List<StudentWithTopics> studentsWithTopics, List<Topic> topics) {
            return studentsWithTopics.Select(s => new Student {
                Id = s.Id,
                Index = s.Index,
                Name = s.Name,
                Gender = s.Gender,
                Active = s.Active,
                DepartmentId = s.DepartmentId,
                TopicIds = s.Topics.Select(t => topics.First(topic => topic.Name == t).Id).ToList()
            }).ToList();
        }

        //b. task b
        public static List<Topic> GenerateTopicsFromStudents(List<StudentWithTopics> studentsWithTopics) {
            return studentsWithTopics
                .SelectMany(s => s.Topics)          // flatten all topic lists into one list
                .Distinct()                         // get unique topic names
                .Select((t, index) => new Topic(index + 1, t)) // assign unique IDs to topics
                .ToList();
        }

        // tasik c: map many-to-many relation using StudentToTopic
        public static List<StudentToTopic> TransformToStudentToTopic(List<StudentWithTopics> studentsWithTopics, List<Topic> topics) {
            return studentsWithTopics.SelectMany(s => s.Topics.Select(t => new StudentToTopic(
                s.Id,
                topics.First(topic => topic.Name == t).Id
            ))).ToList();
        }
    }
}
