package Point;

public class BoundingBox {
    private Point bottomLeft;
    private Point topRight;
    public BoundingBox(Point bottomLeft, Point topRight) {
        this.bottomLeft = bottomLeft;
        this.topRight = topRight;
    }
    public Point getBottomLeft() { return bottomLeft; }
    public Point getTopRight() { return topRight; }
}
