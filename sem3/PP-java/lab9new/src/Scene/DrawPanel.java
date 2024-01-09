package Scene;
import java.awt.*;
import java.util.*;
import Item.Item;
import javax.swing.*;
public class DrawPanel extends JPanel {
    //private final ArrayList<Item> items;
    protected Scene scene;
    public DrawPanel(Scene scene) {
        super();
        this.scene = scene;
    }
    @Override
    public void paintComponent(Graphics g) {
        Graphics2D g2d = (Graphics2D)g;
        super.paintComponent(g);
        for (Item item : scene.getItems()) {
            item.draw(g2d);
            if(scene.getBoundingBoxVisible()) {
                item.setBoundingBox(item.calculateBoundingBox());
                item.getBoundingBox().draw(g);
            }
        }
    }
}
