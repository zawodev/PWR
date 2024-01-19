package Item;

import java.awt.*;
import java.util.*;
import Point.Point;
import Point.*;

public class TextItem extends Item{
    protected String text;
    public String getText() {
        return text;
    }
    public static Font font = new Font("Consolas", Font.PLAIN, 14);
    public TextItem(Point center, String text) {
        super(center);
        this.text = text;
    }
    public String getItemInfo() {
        return "TextItem - " + text;
    }
    @Override
    public BoundingBox calculateBoundingBox() {
        Point a = new Point(center.getX(), center.getY() - 12);
        Point b = new Point(center.getX() + text.length() * 8, center.getY());
        return new BoundingBox(a, b);
    }
    @Override
    public void translate(Point p) {
        super.translate(p);
    }
    @Override
    public void draw(Graphics2D g) {
        g.setColor(Color.BLACK);
        g.setFont(font);
        g.drawString(text, center.getX(), center.getY());
    }
}
