using System;
using System.Collections.Generic;
using System.Linq;
using System.Reflection;
using System.Text;
using System.Threading.Tasks;

namespace ConsoleApp1 {
    class Task1 {
        public static void Start() {
            // sample data
            var students = Generator.GenerateStudentsWithTopicsEasy();

            int groupSize = 3; // specify group size (n)
            var groupedStudents = GroupStudents(students, groupSize);

            // display grouped students
            foreach (var group in groupedStudents) {
                Console.WriteLine("Group:");
                foreach (var student in group) {
                    Console.WriteLine(student);
                }
                Console.WriteLine();
            }
        }
        public static IEnumerable<List<StudentWithTopics>> GroupStudents(List<StudentWithTopics> students, int groupSize) {
            // sort students by name, then by index
            var sortedStudents = students
                .OrderBy(s => s.Name)
                .ThenBy(s => s.Index)
                .ToList();

            // create groups of specified size
            return sortedStudents
                .Select((student, index) => new { student, index })
                .GroupBy(x => x.index / groupSize)
                .Select(g => g.Select(x => x.student).ToList());
        }
    }
}
