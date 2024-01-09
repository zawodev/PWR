package Shape;

import Point.*;
import Point.Point;
import java.awt.*;
import java.awt.geom.GeneralPath;

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
    public BoundingBox calculateBoundingBox() {
        Point minPoint = new Point(Math.min(p1.getX(), Math.min(p2.getX(), p3.getX())), Math.min(p1.getY(), Math.min(p2.getY(), p3.getY())));
        Point maxPoint = new Point(Math.max(p1.getX(), Math.max(p2.getX(), p3.getX())), Math.max(p1.getY(), Math.max(p2.getY(), p3.getY())));
        return new BoundingBox(minPoint, maxPoint);
    }
    @Override
    public void translate(Point p) {
        super.translate(p);
        p1.translate(p);
        p2.translate(p);
        p3.translate(p);
    }
    @Override
    public void draw(Graphics2D g) {
        g.setColor(Color.RED);

        GeneralPath triangle = new GeneralPath();
        triangle.moveTo(p1.getX(), p1.getY());
        triangle.lineTo(p3.getX(), p3.getY());
        triangle.lineTo(p2.getX(), p2.getY());
        triangle.lineTo(p1.getX(), p1.getY());
        triangle.closePath();

        if(filled) g.fill(triangle);
        else g.draw(triangle);
    }

}
