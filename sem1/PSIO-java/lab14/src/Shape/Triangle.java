package Shape;

public class Triangle extends Shape{
    private int c;
    private boolean isTriangle;

    public Triangle() {
        super();
        c = 1;
        isTriangle = true;
    }

    public Triangle(String color, int a, int b, int c, boolean isTriangle) {
        super(color, a, b);
        this.c = c;
        this.isTriangle = isTriangle;
    }
    public String toString(){
        return "Shape.Triangle: color="+color+", a="+a+", b="+b+", c="+c+", isTriangle="+isTriangle+", perimeter: "+Perimeter();
    }
    @Override
    public int Perimeter() {
        return a+b+c;
    }
}
