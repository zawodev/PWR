package Shape;

import Point.Point;
import java.awt.Graphics;
import java.awt.Color;
import java.util.*;
public class Circle extends Shape {
    private int radius;
    public int getRadius() { return radius; }
    public Circle(Point center, int radius) {
        super();
        this.center = center;
        this.radius = radius;
    }
    public String getItemInfo() {
        return "Star - Radius: " + radius;
    }
    @Override
    public void updateBoundingBox() {

    }
    @Override
    public void translate(Point p) {
        super.translate(p);
    }
    @Override
    public void draw(Graphics g) {
        g.setColor(Color.RED);
        g.fillOval(center.getX(), center.getY(), radius, radius);
    }
}
