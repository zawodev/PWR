package Shape;

public abstract class Shape implements Comparable<Shape> {

    String color;
    int a;
    int b;

    public String getColor() {
        return color;
    }

    public void setColor(String color) {
        this.color = color;
    }

    public int getA() {
        return a;
    }

    public void setA(int a) {
        this.a = a;
    }

    public int getB() {
        return b;
    }

    public void setB(int b) {
        this.b = b;
    }

    @Override
    public int compareTo(Shape shape){
        return Perimeter() > shape.Perimeter() ? 1 : Perimeter() < shape.Perimeter() ? -1 : 0;
    }
    public Shape() {
        color = "black";
        a = 1;
        b = 1;
    }

    public Shape(String color, int a, int b) {
        this.color = color;
        this.a = a;
        this.b = b;
    }
    public abstract int Perimeter();
}
