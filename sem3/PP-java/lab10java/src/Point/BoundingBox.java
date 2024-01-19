package Point;

import java.awt.*;

public class BoundingBox {
    protected Point topLeft;
    protected Point bottomRight;
    protected boolean visible = false;
    public BoundingBox(Point topLeft, Point bottomRight) {
        this.topLeft = topLeft;
        this.bottomRight = bottomRight;
    }
    public Point getTopLeft() { return topLeft; }
    public Point getBottomRight() { return bottomRight; }
    public boolean isVisible() { return visible; }
    public void setVisible(boolean _visible) { visible = _visible; }

    public void draw(Graphics g){
        Graphics2D g2d = (Graphics2D) g;
        g2d.setColor(Color.BLACK);

        var prevStroke = g2d.getStroke();
        Stroke dashed = new BasicStroke(3, BasicStroke.CAP_BUTT, BasicStroke.JOIN_BEVEL, 0, new float[]{9}, 0);
        g2d.setStroke(dashed);

        int width = bottomRight.getX() - topLeft.getX();
        int height = bottomRight.getY() - topLeft.getY();
        g2d.drawRect(topLeft.getX(), topLeft.getY(), width, height);

        g2d.setStroke(prevStroke);
    }
}
