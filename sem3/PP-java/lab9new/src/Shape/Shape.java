package Shape;

import Item.PrimitiveItem;
import java.awt.Graphics;

public abstract class Shape extends PrimitiveItem {
    private boolean filled;
    public Shape() {
        super();
    }
    public boolean getFilled() { return filled; }
}
