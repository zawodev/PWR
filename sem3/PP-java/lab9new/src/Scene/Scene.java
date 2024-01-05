package Scene;

import java.awt.*;
import java.util.ArrayList;
import Item.Item;
import javax.swing.*;

public class Scene {
    private ArrayList<Item> items;
    private CreateItemPanel createItemPanel;
    private DrawnItemListPanel drawnItemListPanel;
    private DrawPanel drawPanel;
    private JFrame window;
    public Scene () {
        items = new ArrayList<>();

        window = new JFrame();
        //window.setLayout(new BorderLayout());
        window.setVisible(true);
        window.setTitle("Shape Drawing");
        window.setSize(800, 500);
        window.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        window.setLocationRelativeTo(null);

        createItemPanel = new CreateItemPanel(this);
        createItemPanel.setVisible(true);
        window.getContentPane().add(createItemPanel, BorderLayout.EAST);

        drawnItemListPanel = new DrawnItemListPanel(this);
        drawnItemListPanel.setVisible(true);
        window.getContentPane().add(drawnItemListPanel, BorderLayout.WEST);

        drawPanel = new DrawPanel(items);
        drawPanel.setVisible(true);
        window.getContentPane().add(drawPanel, BorderLayout.CENTER);
    }
    public ArrayList<Item> getItems() {
        return items;
    }
    public void addItem(Item item) {
        items.add(item);
        drawnItemListPanel.refresh();
    }
    public void removeItem(Item item) {
        items.remove(item);
        drawnItemListPanel.refresh();
    }
    public void setItems(ArrayList<Item> items) {
        this.items = items;
        drawnItemListPanel.refresh();
    }
    public void clearItems() {
        items.clear();
        drawnItemListPanel.refresh();
    }
    public void draw() {
        window.repaint();
        window.revalidate();
    }
}
