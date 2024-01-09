package Item;

import java.awt.*;
import java.util.*;
import Point.*;
import Point.Point;

public class ComplexItem extends Item{
    private ArrayList<Item> children;
    public ArrayList<Item> getChildren() {
        return children;
    }
    public ComplexItem(Point center, ArrayList<Item> children) {
        super(center);
        this.children = children;
    }
    public String getItemInfo() {
        return "ComplexItem - Data";
    }
    @Override
    public BoundingBox calculateBoundingBox() {
        Point minPoint = new Point(children.getFirst().calculateBoundingBox().getTopLeft().getX(), children.getFirst().calculateBoundingBox().getTopLeft().getY());
        Point maxPoint = new Point(children.getFirst().calculateBoundingBox().getTopLeft().getX(), children.getFirst().calculateBoundingBox().getTopLeft().getY());

        for(Item item : children){
            minPoint.setX(Math.min(minPoint.getX(), item.calculateBoundingBox().getTopLeft().getX()));
            minPoint.setY(Math.min(minPoint.getY(), item.calculateBoundingBox().getTopLeft().getY()));
            maxPoint.setX(Math.max(maxPoint.getX(), item.calculateBoundingBox().getBottomRight().getX()));
            maxPoint.setY(Math.max(maxPoint.getY(), item.calculateBoundingBox().getBottomRight().getY()));

            System.out.println(minPoint.getX());
        }

        return new BoundingBox(minPoint, maxPoint);
    }
    @Override
    public void translate(Point p) {
        for (Item item : children) {
            item.translate(p);
        }
    }
    @Override
    public void draw(Graphics2D g) {
        for (Item item : children) {
            item.draw(g);
        }
    }
}
