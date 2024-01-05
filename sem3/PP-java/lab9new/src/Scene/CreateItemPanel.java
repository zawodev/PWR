package Scene;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import Point.Point;
import Shape.*;
import javax.swing.*;
class CreateItemPanel extends JPanel {
    private Scene scene;
    public CreateItemPanel(Scene scene) {
        super();
        this.scene = scene;
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        createButtons();
    }
    private void createButtons() {
        JButton circleButton = new JButton("Draw Circle");
        circleButton.addActionListener(e -> {
            scene.addItem(new Circle(new Point(100, 100), 50));
            scene.draw();
            System.out.println("Circle added, total items on Scene: " + scene.getItems().size());
        });

        JButton rectangleButton = new JButton("Draw Rectangle");
        rectangleButton.addActionListener(e -> {
            scene.addItem(new Rect(new Point(100, 100), new Point(200, 200)));
            scene.draw();
            System.out.println("Rect added, total items on Scene: " + scene.getItems().size());
        });

        add(circleButton);
        add(rectangleButton);
    }
}