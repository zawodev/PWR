import java.util.Comparator;

public class StudentComparator implements Comparator<Student> {
    public int compare(Student student1, Student student2) {
        return Integer.compare(student1.getId(), student2.getId());
    }
}
