package Scene;
import java.awt.*;
import java.util.*;
import Item.Item;
import javax.swing.*;
public class DrawPanel extends JPanel {
    private final ArrayList<Item> items;
    public DrawPanel(ArrayList<Item> items) {
        super();
        this.items = items;
    }
    @Override
    public void paintComponent(Graphics g) {
        super.paintComponent(g);
        Graphics2D g2d = (Graphics2D)g;
        for (Item item : items) {
            item.draw(g2d);
        }
    }
}
