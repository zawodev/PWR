package Shape;

public class Rectangle extends Shape{
    private boolean isSquare;

    public Rectangle() {
        super();
        isSquare = true;
    }

    public Rectangle(String color, int a, int b, boolean isRectangle) {
        super(color, a, b);
        this.isSquare = isRectangle;
    }
    public String toString(){
        return "Shape.Rectangle: color="+color+", a="+a+", b="+b+", isSquare="+ isSquare +", perimeter: "+Perimeter();
    }

    @Override
    public int Perimeter() {
        return 2*a+2*b;
    }
}
