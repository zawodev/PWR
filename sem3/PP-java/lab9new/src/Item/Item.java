package Item;

import java.awt.Graphics;

import Point.*;
import javax.swing.*;

public abstract class Item extends JComponent {
    protected BoundingBox boundingBox;
    protected Point center;

    public Item (Point center) {
        this.center = center;
        //this.boundingBox = ???;
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
