package Item;

import java.awt.*;

import Point.*;
import Point.Point;

import javax.swing.*;

public abstract class Item extends JComponent {
    protected BoundingBox boundingBox;
    protected Point center;

    public Item (Point center) {
        this.center = center;
        this.boundingBox = new BoundingBox(new Point(0, 0), new Point(0, 0));
    }
    public Point getPosition(){
        return center;
    }
    public BoundingBox getBoundingBox(){
        return boundingBox;
    }
    public void setBoundingBox(BoundingBox boundingBox){
        this.boundingBox = boundingBox;
    }

    public abstract String getItemInfo();
    public abstract BoundingBox calculateBoundingBox();
    public void translate(Point p){
        center.translate(p);
    }
    public abstract void draw(Graphics2D g);
}
