public class Rectangle {
    public Point A;
    public Point B;
    private double sideX;
    private double sideY;
    private double diagonal;
    public Rectangle(){
        A = new Point(0, 0);
        B = new Point(1, 1);
    }
    public Rectangle(Point A, Point B){
        this();
        this.A = A;
        this.B = B;
        sideX = CalculateHorizontalLength();
        sideY = CalculateVerticalLength();
        diagonal = CalculateDiagonalLength();
    }
    public double CalculateHorizontalLength() {
        return Math.abs(A.GetX() - B.GetX());
    }
    public double CalculateVerticalLength(){
        return Math.abs(A.GetY() - B.GetY());
    }
    public double CalculateDiagonalLength(){
        return Math.sqrt(sideX * sideX + sideY * sideY);
    }
    public double Area(){
        return sideX * sideY;
    }
    public double Circumference(){
        return 2 * (sideX + sideY);
    }
    public double Diagonal(){
        return diagonal;
    }
}