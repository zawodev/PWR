package Segment;

import Point.Point;
import Item.PrimitiveItem;
import java.awt.Graphics;
import java.awt.Color;

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
        return "Triangle - P1: (" + start.getX() + ", " + start.getY() + "), P2: (" + end.getX() + ", " + end.getY() + ")";
    }
    @Override
    public void updateBoundingBox() {

    }
    @Override
    public void translate(Point p) {

    }
    @Override
    public void draw(Graphics g) {
        g.setColor(Color.RED);
        g.drawLine(start.getX(), start.getY(), end.getX(), end.getY());
    }
}
