package Shape;

import Point.*;
import Point.Point;
import java.awt.*;
import java.awt.geom.GeneralPath;
import java.util.ArrayList;

public class Star extends Shape {
    protected int innerRadius;
    protected int outerRadius;
    protected int n;
    protected ArrayList<Point> points;
    public Star(Point center, int innerRadius, int outerRadius, int n, boolean filled) {
        super(center, filled);
        this.center = center;
        this.innerRadius = innerRadius;
        this.outerRadius = outerRadius;
        this.n = n;
    }
    public int getInnerRadius() { return innerRadius; }
    public int getOuterRadius() { return outerRadius; }
    public int getN() { return n; }

    @Override
    public String getItemInfo() {
        return "Star - Center: (" + center.getX() + ", " + center.getY() + "), Inner Radius: " + innerRadius +
                ", Outer Radius: " + outerRadius + ", N: " + n;
    }

    @Override
    public BoundingBox calculateBoundingBox() {
        Point minPoint = new Point(points.getFirst().getX(), points.getFirst().getY());
        Point maxPoint = new Point(points.getFirst().getX(), points.getFirst().getY());

        for(Point point : points){
            minPoint.setX(Math.min(minPoint.getX(), point.getX()));
            minPoint.setY(Math.min(minPoint.getY(), point.getY()));
            maxPoint.setX(Math.max(maxPoint.getX(), point.getX()));
            maxPoint.setY(Math.max(maxPoint.getY(), point.getY()));
        }

        return new BoundingBox(minPoint, maxPoint);
    }
    @Override
    public void translate(Point p) {
        super.translate(p);
        System.out.println("Star translate");
    }
    @Override
    public void draw(Graphics2D g) {
        g.setColor(Color.BLUE);
        g.setStroke(new BasicStroke(4));
        GeneralPath star = drawStarToFill();

        if(filled) g.fill(star);
        else g.draw(star);
    }

    private GeneralPath drawStarToFill() {
        GeneralPath star = new GeneralPath();
        points = new ArrayList<>();

        double angle = Math.PI / n;
        for (int i = 0; i < 2 * n; i++) {
            double r = (i % 2 == 0) ? outerRadius : innerRadius;
            int xPoint = (int)(center.getX() + r * Math.cos(i * angle));
            int yPoint = (int)(center.getY() + r * Math.sin(i * angle));
            points.add(new Point(xPoint, yPoint));

            if (i == 0) star.moveTo(xPoint, yPoint);
            else star.lineTo(xPoint, yPoint);
        }

        star.closePath();
        return star;
    }
}
