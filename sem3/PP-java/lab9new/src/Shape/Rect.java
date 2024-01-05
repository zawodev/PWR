package Shape;

import Point.*;
import Point.Point;
import java.awt.Graphics;
import java.awt.Color;

public class Rect extends Shape {
    protected Point leftTop;
    protected Point rightBottom;
    protected int width;
    protected int height;
    public Rect(Point leftTop, Point rightBottom, boolean filled) {
        super(new Point((leftTop.getX() + rightBottom.getX()) / 2, (leftTop.getY() + rightBottom.getY()) / 2), filled);
        this.leftTop = leftTop;
        this.rightBottom = rightBottom;
        this.width = rightBottom.getX() - leftTop.getX();
        this.height = rightBottom.getY() - leftTop.getY();
    }
    public Rect(Point center, int width, int height, boolean filled) {
        super(center, filled);
        this.leftTop = new Point(center.getX() - width / 2, center.getY() + height / 2);
        this.rightBottom = new Point(center.getX() + width / 2, center.getY() - height / 2);
        this.width = width;
        this.height = height;
    }
    public int getWidth() {
        return width;
    }
    public int getHeight() {
        return height;
    }
    public Point getLeft() {
        return leftTop;
    }
    public Point getRightBottom() {
        return rightBottom;
    }
    public String getItemInfo() {
        return "Rect - Width: " + width + ", Height: " + height;
    }
    @Override
    public void updateBoundingBox() {
        setBoundingBox(new BoundingBox(leftTop, rightBottom));
    }
    @Override
    public void translate(Point p) {
        super.translate(p);
        leftTop.translate(p);
        rightBottom.translate(p);
    }
    @Override
    public void draw(Graphics g) {
        g.setColor(Color.BLUE);
        g.fillRect(leftTop.getX(), leftTop.getY(), width, height);
    }
}
