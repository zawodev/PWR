
package Shape;

import Point.Point;

import java.awt.*;
import java.awt.geom.*;

public class Star extends Shape {
    private int innerRadius;
    private int outerRadius;
    private int n;
    public Star(Point center, int innerRadius, int outerRadius, int n) {
        super();
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
    public void updateBoundingBox() {

    }
    @Override
    public void translate(Point p) {
        super.translate(p);
    }
    @Override
    public void draw(Graphics g) {
        Graphics2D g2d = (Graphics2D) g;

        double angle = Math.PI / n;
        GeneralPath star = new GeneralPath();
        for (int i = 0; i < 2 * n; i++) {
            double r = (i % 2 == 0) ? outerRadius : innerRadius;
            double xPoint = center.getX() + r * Math.cos(i * angle);
            double yPoint = center.getY() + r * Math.sin(i * angle);

            if (i == 0) {
                star.moveTo(xPoint, yPoint);
            } else {
                star.lineTo(xPoint, yPoint);
            }
        }

        star.closePath();

        g2d.setColor(Color.BLUE);
        g2d.fill(star);
    }
}
