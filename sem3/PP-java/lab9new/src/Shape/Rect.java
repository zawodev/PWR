package Shape;

import Point.*;
import Point.Point;
import java.awt.Graphics;
import java.awt.Color;

public class Rect extends Shape {
    private Point leftTop;
    private Point rightBottom;
    private int width;
    private int height;
    public Rect(Point leftTop, Point rightBottom) {
        super();
        this.leftTop = leftTop;
        this.rightBottom = rightBottom;
        this.width = rightBottom.getX() - leftTop.getX();
        this.height = rightBottom.getY() - leftTop.getY();
    }
    public Rect(Point position, int width, int height) {
        super();
        this.center = position;
        this.leftTop = new Point(position.getX() - width / 2, position.getY() + height / 2);
        this.rightBottom = new Point(position.getX() + width / 2, position.getY() - height / 2);
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
        g.setColor(Color.RED);
        g.fillRect(leftTop.getX(), leftTop.getY(), width, height);
    }
}
