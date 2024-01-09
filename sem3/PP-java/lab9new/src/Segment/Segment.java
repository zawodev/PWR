package Segment;

import Point.*;
import Item.PrimitiveItem;
import Point.Point;

import java.awt.*;

public class Segment extends PrimitiveItem {
    protected Point start;
    protected Point end;
    protected int length;
    public Point getStart() {
        return start;
    }
    public Point getEnd() {
        return end;
    }
    public int getLength() {
        return length;
    }
    public Segment(Point start, Point end) {
        super(new Point((start.getX() + end.getX()) / 2, (start.getY() + end.getY()) / 2));
        this.start = start;
        this.end = end;
        this.length = (int) Math.sqrt(Math.pow(end.getX() - start.getX(), 2) + Math.pow(end.getY() - start.getY(), 2));
    }
    public String getItemInfo() {
        return "Segment - P1: (" + start.getX() + ", " + start.getY() + "), P2: (" + end.getX() + ", " + end.getY() + ")";
    }
    @Override
    public BoundingBox calculateBoundingBox() {
        Point minPoint = new Point(start.getX(), start.getY());
        Point maxPoint = new Point(start.getX(), start.getY());

        minPoint.setX(Math.min(minPoint.getX(), end.getX()));
        minPoint.setY(Math.min(minPoint.getY(), end.getY()));
        maxPoint.setX(Math.max(maxPoint.getX(), end.getX()));
        maxPoint.setY(Math.max(maxPoint.getY(), end.getY()));

        return new BoundingBox(minPoint, maxPoint);
    }
    @Override
    public void translate(Point p) {
        super.translate(p);
        start.translate(p);
        end.translate(p);
    }
    @Override
    public void draw(Graphics2D g) {
        g.setColor(Color.PINK);
        g.setStroke(new BasicStroke(4));
        g.drawLine(start.getX(), start.getY(), end.getX(), end.getY());
    }
}
