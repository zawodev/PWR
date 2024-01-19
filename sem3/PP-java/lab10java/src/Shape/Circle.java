package Shape;

import Point.Point;
import Point.*;
import java.awt.*;
import java.awt.geom.GeneralPath;

public class Circle extends Shape {
    private int radius;
    public int getRadius() { return radius; }
    public Circle(Point center, int radius, boolean filled) {
        super(center, filled);
        this.radius = radius;
    }
    public String getItemInfo() {
        return "Circle - Radius: " + radius;
    }
    @Override
    public BoundingBox calculateBoundingBox() {
        return new BoundingBox(new Point(center.getX(), center.getY()), new Point(center.getX() + radius, center.getY() + radius));
    }
    @Override
    public void translate(Point p) {
        super.translate(p);
    }
    @Override
    public void draw(Graphics2D g) {
        g.setColor(Color.ORANGE);
        g.setStroke(new BasicStroke(4));
        if(filled) g.fillOval(center.getX(), center.getY(), radius, radius);
        else g.drawOval(center.getX(), center.getY(), radius, radius);
    }
}
