public class Student implements Comparable<Student> {
    public Student(int index, String name, String surname, String studyField) {
        this.index = index;
        this.name = name;
        this.surname = surname;
        this.studyField = studyField;
    }

    private int index;
    private String name;
    private String surname;
    private String studyField;

    public int getIndex() {
        return index;
    }

    public void setIndex(int index) {
        this.index = index;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getSurname() {
        return surname;
    }

    public void setSurname(String surname) {
        this.surname = surname;
    }

    public String getStudyField() {
        return studyField;
    }

    public void setStudyField(String studyField) {
        this.studyField = studyField;
    }

    public String toString(){
        return "[name: " + name + ", surname: " + surname + ", studyField: " + studyField + ", index: " + index + "]\n";
    }

    @Override
    public int compareTo(Student other) {
        return surname.compareTo(other.surname);
    }
}
