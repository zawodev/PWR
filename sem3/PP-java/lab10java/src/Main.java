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
        //scene.addItem(new Star(new Point(250, 250), 50, 29, 6, true));
        scene.draw();
        //scene.addItem(new Star(new Point(100, 100), true, 50, 29, 6));

        //test zad2
        //test zad-3


        
    }
}