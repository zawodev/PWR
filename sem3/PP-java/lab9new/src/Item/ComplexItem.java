package Item;

import java.awt.Graphics;
import java.util.*;
import Point.*;

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
        return "ComplexItem - Ain't showin' all that: ";
    }
    @Override
    public void updateBoundingBox() {
        for (Item item : children) {
            item.updateBoundingBox();
        }
    }
    @Override
    public void translate(Point p) {
        for (Item item : children) {
            item.translate(p);
        }
    }
    @Override
    public void draw(Graphics g) {
        for (Item item : children) {
            item.draw(g);
        }
    }
}
