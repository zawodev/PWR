package Shape;

import Item.PrimitiveItem;
import Point.*;

public abstract class Shape extends PrimitiveItem {
    protected boolean filled;
    public Shape(Point center, boolean filled) {
        super(center);
        this.filled = filled;
    }
    public boolean getFilled() { return filled; }
}
