package Scene;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.ArrayList;
import java.util.Random;
import Item.*;
import Point.Point;
import Shape.*;
import javax.swing.*;
import Segment.*;
class CreateItemPanel extends JPanel {
    protected Scene scene;
    public CreateItemPanel(Scene scene) {
        super();
        this.scene = scene;
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        setPreferredSize(new Dimension(130, 0));
        setBackground(Color.LIGHT_GRAY);
        createButtons();
    }
    private Item getRandomSegment(Random random){
        int x1 = random.nextInt(500);
        int y1 = random.nextInt(500);
        int x2 = random.nextInt(500);
        int y2 = random.nextInt(500);
        return new Segment(new Point(x1, y1), new Point(x2, y2));
    }
    private Item getRandomTriangle(Random random){
        int x = random.nextInt(100, 400);
        int y = random.nextInt(100, 400);
        int x1 = x + random.nextInt(-100, 100);
        int y1 = y + random.nextInt(-100, 100);
        int x2 = x + random.nextInt(-100, 100);
        int y2 = y + random.nextInt(-100, 100);
        int x3 = x + random.nextInt(-100, 100);
        int y3 = y + random.nextInt(-100, 100);
        boolean filled = random.nextBoolean();
        return new Triangle(new Point(x1, y1), new Point(x2, y2), new Point(x3, y3), filled);
    }
    private Item getRandomCircle(Random random){
        int x = random.nextInt(500);
        int y = random.nextInt(500);
        int radius = random.nextInt(100);
        boolean filled = random.nextBoolean();
        return new Circle(new Point(Math.abs(x - radius), Math.abs(y - radius)), radius, filled);
    }
    private Item getRandomRect(Random random){
        int x = random.nextInt(500);
        int y = random.nextInt(500);
        int width = random.nextInt(100);
        int height = random.nextInt(100);
        boolean filled = random.nextBoolean();
        return new Rect(new Point(x, y), new Point(x + width, y + height), filled);
    }
    private Item getRandomStar(Random random){
        int x = random.nextInt(100, 400);
        int y = random.nextInt(100, 400);
        int innerRadius = random.nextInt(40);
        int outerRadius = random.nextInt(40);
        int n = random.nextInt(5, 12);
        boolean filled = random.nextBoolean();
        return new Star(new Point(x, y), innerRadius, outerRadius, n, filled);
    }
    private Item getRandomText(Random random){
        int x = random.nextInt(100, 400);
        int y = random.nextInt(100, 400);
        String text = "Wesołych świąt xD";
        return new TextItem(new Point(x, y), text);
    }
    private void createButtons() {
        Random random = new Random();

        add(new JLabel("Create Example Item:"));

        JButton clearSceneButton = new JButton("Wyczyść Scenę");
        clearSceneButton.addActionListener(e -> {scene.clearItems(); scene.draw();});
        add(clearSceneButton);

        JCheckBox checkBox = new JCheckBox("Bounding Box");
        checkBox.addActionListener(e -> scene.toggleBoundingBoxVisible());
        add(checkBox);

        JButton segmentButton = createSegmentButton(random);
        JButton triangleButton = createTriangleButton(random);
        JButton circleButton = createCircleButton(random);
        JButton rectButton = createRectButton(random);
        JButton starButton = createStarButton(random);
        JButton textButton = createTextButton(random);
        JButton complexButton = createComplexButton(random);

        add(textButton);
        add(segmentButton);
        add(triangleButton);
        add(circleButton);
        add(rectButton);
        add(starButton);
        add(complexButton);

        repaint();
        revalidate();
    }
    private JButton createComplexButton(Random random) {
        JButton complexButton = new JButton("Draw Complex");
        complexButton.addActionListener(e -> {
            int x = random.nextInt(100, 400);
            int y = random.nextInt(100, 400);
            int n = random.nextInt(2, 8);
            ArrayList<Item> items = new ArrayList<Item>();
            for(int i = 0; i < n; i++){
                int j = random.nextInt(6);
                switch (j){
                    case 0:
                        items.add(getRandomSegment(random));
                        break;
                    case 1:
                        items.add(getRandomTriangle(random));
                        break;
                    case 2:
                        items.add(getRandomCircle(random));
                        break;
                    case 3:
                        items.add(getRandomRect(random));
                        break;
                    case 4:
                        items.add(getRandomStar(random));
                        break;
                    case 5:
                        items.add(getRandomText(random));
                        break;
                }
            }
            scene.addItem(new ComplexItem(new Point(x, y), items));
            scene.draw();
            System.out.println("Complex added, total items on Scene: " + scene.getItems().size());
        });
        return complexButton;
    }
    private JButton createSegmentButton(Random random) {
        JButton segmentButton = new JButton("Draw Segment");
        segmentButton.addActionListener(e -> {
            scene.addItem(getRandomSegment(random));
            scene.draw();
            System.out.println("Segment added, total items on Scene: " + scene.getItems().size());
        });
        return segmentButton;
    }
    private JButton createTextButton(Random random) {
        JButton textButton = new JButton("Draw Text");
        textButton.addActionListener(e -> {
            scene.addItem(getRandomText(random));
            scene.draw();
            System.out.println("Text added, total items on Scene: " + scene.getItems().size());
        });
        return textButton;
    }
    private JButton createCircleButton(Random random) {
        JButton circleButton = new JButton("Draw Circle");
        circleButton.addActionListener(e -> {
            scene.addItem(getRandomCircle(random));
            scene.draw();
            System.out.println("Circle added, total items on Scene: " + scene.getItems().size());
        });
        return circleButton;
    }
    private JButton createTriangleButton(Random random) {
        JButton triangleButton = new JButton("Draw Triangle");
        triangleButton.addActionListener(e -> {
            scene.addItem(getRandomTriangle(random));
            scene.draw();
            System.out.println("Triangle added, total items on Scene: " + scene.getItems().size());
        });
        return triangleButton;
    }
    private JButton createRectButton(Random random) {
        JButton rectangleButton = new JButton("Draw Rectangle");
        rectangleButton.addActionListener(e -> {
            scene.addItem(getRandomRect(random));
            scene.draw();
            System.out.println("Rect added, total items on Scene: " + scene.getItems().size());
        });
        return rectangleButton;
    }
    private JButton createStarButton(Random random) {
        JButton starButton = new JButton("Draw Star");
        starButton.addActionListener(e -> {
            scene.addItem(getRandomStar(random));
            scene.draw();
            System.out.println("Star added, total items on Scene: " + scene.getItems().size());
        });
        return starButton;
    }
}