package Decorator;

import Item.*;
import java.awt.*;

public class BoundingBoxDecorator extends Decorator {
    public BoundingBoxDecorator(Item item) {
        super(item);
        item.setBoundingBox(item.calculateBoundingBox());
    }

    @Override
    public String getItemInfo() {
        return super.getItemInfo() + " - Bounding Box: (" + item.getBoundingBox().getTopLeft().getX() + ", " + item.getBoundingBox().getTopLeft().getY() + "), (" + item.getBoundingBox().getBottomRight().getX() + ", " + item.getBoundingBox().getBottomRight().getY() + ")";
    }

    @Override
    public void draw(Graphics2D g) {
        item.draw(g);
        item.getBoundingBox().draw(g);
    }
}
