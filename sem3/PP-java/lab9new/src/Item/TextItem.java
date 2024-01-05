package Item;

import java.awt.Graphics;
import java.util.*;
import Point.Point;

public class TextItem extends Item{
    private String text;
    public String getText() {
        return text;
    }
    public TextItem(Point center, String text) {
        super(center);
        this.text = text;
    }
    public String getItemInfo() {
        return "TextItem - " + text;
    }
    @Override
    public void updateBoundingBox() {

    }
    @Override
    public void translate(Point p) {

    }
    @Override
    public void draw(Graphics g) {
        g.drawString(text, 0, 0);
    }
}
