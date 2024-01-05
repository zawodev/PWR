package Item;

import java.awt.Graphics;

import Point.*;
import javax.swing.*;

public abstract class Item extends JComponent {
    public BoundingBox boundingBox;
    public Point center;

    public Item () {
        boundingBox = new BoundingBox(new Point(0,0), new Point(0,0)); //domyslnie pusty bounding box
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
    public abstract void updateBoundingBox();
    public void translate(Point p){
        center.translate(p);
    }
    public abstract void draw(Graphics g);
}
