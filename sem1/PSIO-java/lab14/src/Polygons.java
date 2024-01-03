import Shape.Shape;

import java.util.ArrayList;
import java.util.Comparator;

import Shape.Rectangle;
import Shape.Triangle;

public class Polygons {
    public ColorCompare getColorComparator() {
        return colorComparator;
    }

    public SideCompare getSideComparator() {
        return sideComparator;
    }
    public BothCompare getBothComparator() { return bothComparator;}

    private ArrayList<Shape> shapes;
    private ColorCompare colorComparator;
    private SideCompare sideComparator;
    private BothCompare bothComparator;

    public Polygons() {
        shapes = new ArrayList<>();
    }

    public ArrayList<Shape> getShapes() {
        return shapes;
    }

    public void CreateTriangle(String color, int a, int b, int c, boolean isTriangle){
        shapes.add(new Triangle(color, a, b, c, isTriangle));
    }
    public void CreateRect(String color, int a, int b, boolean isRectangle){
        shapes.add(new Rectangle(color, a, b, isRectangle));
    }
    public void ViewPolygons(){
        for(int i = 0; i< shapes.size(); i++){
            ViewPolygon(i);
        }
    }
    public void ViewPolygon(int i){
        System.out.println(shapes.get(i).toString());
    }
    public void CreateComparators(){
        sideComparator = new SideCompare();
        colorComparator = new ColorCompare();
        bothComparator = new BothCompare();
    }
    class ColorCompare implements Comparator<Shape> {
        public int compare(Shape s1, Shape s2){
            return s1.getColor().compareTo(s2.getColor());
        }
    }
    class SideCompare implements Comparator<Shape> {
        public int compare(Shape s1, Shape s2){
            return s1.getA() > s2.getA() ? 1 : s1.getA() < s2.getA() ? -1 : 0;
        }
    }
    class BothCompare implements Comparator<Shape> {
        public int compare(Shape s1, Shape s2){
            return s1.getA() > s2.getA() ? 1 : s1.getA() < s2.getA() ? -1 : s1.getColor().compareTo(s2.getColor());
        }
    }
}