import Scene.*;
import Point.*;
import Item.*;
import Segment.Segment;
import Shape.Circle;
import Shape.Rect;
import Shape.Star;
import Shape.Triangle;

import java.util.ArrayList;

public class Main {
    public static void main(String[] args) {
        Scene scene = new Scene();
        //scene.addItem(new Segment(new Point(0, 90), new Point(90, 0)));
        //scene.addItem(new Circle(new Point(100, 100), 50));
        //scene.addItem(new Rect(new Point(100, 100), new Point(200, 200)));
        //scene.addItem(new Triangle(new Point(20, 20), new Point(100, 100), new Point(20, 100)));
        //scene.addItem(new TextItem(new Point(20, 20), "Hello World"));
        scene.draw();
    }
}