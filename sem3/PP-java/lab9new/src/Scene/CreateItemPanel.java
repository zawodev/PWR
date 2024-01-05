package Scene;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Random;

import Point.Point;
import Shape.*;
import javax.swing.*;
class CreateItemPanel extends JPanel {
    private Scene scene;
    public CreateItemPanel(Scene scene) {
        super();
        this.scene = scene;
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        setPreferredSize(new Dimension(130, 0));
        setBackground(Color.LIGHT_GRAY);
        createButtons();
    }
    private void createButtons() {
        Random random = new Random();

        JButton triangleButton = createTriangleButton(random);
        JButton circleButton = createCircleButton(random);
        JButton rectButton = createRectButton(random);
        JButton starButton = createStarButton(random);

        add(new JLabel("Create Example Item:"));
        add(triangleButton);
        add(circleButton);
        add(rectButton);
        add(starButton);

        repaint();
        revalidate();
    }
    private JButton createCircleButton(Random random) {
        JButton circleButton = new JButton("Draw Circle");
        circleButton.addActionListener(e -> {
            int x = random.nextInt(500);
            int y = random.nextInt(500);
            int radius = random.nextInt(100);
            scene.addItem(new Circle(new Point(x, y), radius, true));
            scene.draw();
            System.out.println("Circle added, total items on Scene: " + scene.getItems().size());
        });
        return circleButton;
    }
    private JButton createTriangleButton(Random random) {
        JButton triangleButton = new JButton("Draw Triangle");
        triangleButton.addActionListener(e -> {
            int x = random.nextInt(500);
            int y = random.nextInt(500);
            int width = random.nextInt(100);
            int height = random.nextInt(100);
            scene.addItem(new Triangle(new Point(x, y), new Point(x + width, y + height), new Point(0, 0), true));
            scene.draw();
            System.out.println("Triangle added, total items on Scene: " + scene.getItems().size());
        });
        return triangleButton;
    }
    private JButton createRectButton(Random random) {
        JButton rectangleButton = new JButton("Draw Rectangle");
        rectangleButton.addActionListener(e -> {
            int x = random.nextInt(500);
            int y = random.nextInt(500);
            int width = random.nextInt(100);
            int height = random.nextInt(100);
            scene.addItem(new Rect(new Point(x, y), new Point(x + width, y + height), true));
            //scene.addItem(new Rect(new Point(x, y), width, height, true)); //tego ciężej zmieścić w oknie
            scene.draw();
            System.out.println("Rect added, total items on Scene: " + scene.getItems().size());
        });
        return rectangleButton;
    }
    private JButton createStarButton(Random random) {
        JButton starButton = new JButton("Draw Star");
        starButton.addActionListener(e -> {
            scene.addItem(new Star(new Point(100, 100), true, 50, 29, 6));
            scene.draw();
            System.out.println("Star added, total items on Scene: " + scene.getItems().size());
        });
        return starButton;
    }
}