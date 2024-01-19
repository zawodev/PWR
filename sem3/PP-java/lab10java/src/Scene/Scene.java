package Scene;

import java.awt.*;
import java.util.ArrayList;
import Item.Item;
import javax.swing.*;

import Shape.*;
import Decorator.*;


public class Scene {
    protected ArrayList<Item> items;
    protected CreateItemPanel createItemPanel;
    protected DrawnItemListPanel drawnItemListPanel;
    protected DrawPanel drawPanel;
    protected JFrame window;
    public Item EnableBoundingBox(Item item) {
        if (item instanceof BoundingBoxDecorator) return item;

        Item newItem = new BoundingBoxDecorator(item);
        items.set(items.indexOf(item), newItem);

        drawnItemListPanel.refresh();
        draw();
        return newItem;
    }
    public Item DisableBoundingBox(Item item) {
        if (!(item instanceof BoundingBoxDecorator)) return item;

        Item newItem = ((BoundingBoxDecorator) item).getItem();
        items.set(items.indexOf(item), newItem);

        drawnItemListPanel.refresh();
        draw();
        return newItem;
    }
    public Scene () {
        items = new ArrayList<>();

        window = new JFrame();
        //window.setLayout(new BorderLayout());
        window.setVisible(true);
        window.setTitle("Shape Drawing");
        window.setSize(900, 600);
        window.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        window.setLocationRelativeTo(null);

        createItemPanel = new CreateItemPanel(this);
        createItemPanel.setVisible(true);
        window.getContentPane().add(createItemPanel, BorderLayout.EAST);

        drawnItemListPanel = new DrawnItemListPanel(this);
        drawnItemListPanel.setVisible(true);
        window.getContentPane().add(drawnItemListPanel, BorderLayout.WEST);

        drawPanel = new DrawPanel(this);
        drawPanel.setVisible(true);
        window.getContentPane().add(drawPanel, BorderLayout.CENTER);
    }
    public ArrayList<Item> getItems() {
        return items;
    }
    public void addItem(Item item) {
        if (item != null) {
            //items.removeIf(i -> i.equals(item)); //ta linijka sprawia, że nie można dodać dwóch takich samych elementów (zad2 mod) (tylko dla statycznych singletonów)
            items.add(item);
            drawnItemListPanel.refresh();
        }
    }
    public void removeItem(Item item) {
        if (item != null) {
            items.remove(item);
            drawnItemListPanel.refresh();
        }
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