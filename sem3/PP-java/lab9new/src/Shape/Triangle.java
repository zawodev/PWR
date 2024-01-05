package Shape;

import Point.Point;
import java.util.*;
import java.awt.Graphics;
import java.awt.Color;

public class Triangle extends Shape {
    protected Point p1;
    protected Point p2;
    protected Point p3;
    public Triangle(Point p1, Point p2, Point p3, boolean filled) {
        super(new Point((p1.getX() + p2.getX() + p3.getX()) / 3, (p1.getY() + p2.getY() + p3.getY()) / 3), filled);
        this.p1 = p1;
        this.p2 = p2;
        this.p3 = p3;
    }
    public Point getP1() {
        return p1;
    }
    public Point getP2() {
        return p2;
    }
    public Point getP3() {
        return p3;
    }
    public String getItemInfo() {
        return "Triangle - P1: (" + p1.getX() + ", " + p1.getY() + "), P2: (" + p2.getX() + ", " + p2.getY() + "), P3: (" + p3.getX() + ", " + p3.getY() + ")";
    }
    @Override
    public void updateBoundingBox() {

    }
    @Override
    public void translate(Point p) {
        super.translate(p);
        p1.translate(p);
        p2.translate(p);
        p3.translate(p);
    }
    @Override
    public void draw(Graphics g) {
        g.setColor(Color.RED);
        g.drawLine(p1.getX(), p1.getY(), p2.getX(), p2.getY());
        g.drawLine(p2.getX(), p2.getY(), p3.getX(), p3.getY());
        g.drawLine(p3.getX(), p3.getY(), p1.getX(), p1.getY());
    }
}
