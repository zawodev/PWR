import javax.swing.*;
import java.awt.*;
import java.awt.geom.AffineTransform;
import java.util.ArrayList;

public class DrawGraph extends JComponent {
    private ArrayList<Point> points = new ArrayList();
    private boolean isOnPlane = false;
    private int debugCircles = 0;
    private int thickness = 30;
    private int arrowThickness = 7;
    private float radius = 200;   // Promień koła
    private float centerX = 500;  // Współrzędna x środka koła
    private float centerY = 400;  // Współrzędna y środka koła

    public DrawGraph() {
        //setPreferredSize(new Dimension(1500, 800));
        setVisible(true);
    }
    @Override
    protected void paintComponent(Graphics g){
        int numPoints = Main.graph.nodes.size();
        points = new ArrayList<>();
        double angle = 2 * Math.PI / numPoints;

        for (int i = 0; i < numPoints; i++) {
            int x;
            int y;
            if(!isOnPlane) {
                x = (int) (centerX + radius * Math.cos(i * angle));
                y = (int) (centerY + radius * Math.sin(i * angle));
            }
            else{
                x = Main.graph.nodes.get(i).pos.x;
                y = Main.graph.nodes.get(i).pos.y;
            }

            points.add(new Point(x, y));

            g.setColor(Color.gray);
            g.fillOval(x - thickness / 2, y - thickness / 2, thickness, thickness);
            if(debugCircles == 1) {
                int size = Main.graph.nodes.get(i).getLongestDist();
                g.drawOval(x - size, y - size, 2 * size, 2 * size);
            }
            else if(debugCircles == 2) {
                Node closestNode = Main.graph.nodes.get(i).getFurthestNode();
                int size = Main.graph.nodes.get(i).getLongestDist();
                g.drawOval((x + closestNode.pos.x - size) / 2, (y + closestNode.pos.y - size) / 2, size, size);
            }
            g.setColor(Color.black);
            g.drawString("N" + i, x - thickness / 2, y - thickness / 2);
        }

        for(Node node : Main.graph.nodes){
            for(Edge edge : node.outEdges){
                if(edge.weight != 0) {
                    Point a = new Point(points.get(node.id).x, points.get(node.id).y);
                    Point b = new Point(points.get(edge.endNode.id).x, points.get(edge.endNode.id).y);

                    g.setColor(Color.black);
                    g.drawLine(a.x, a.y, b.x, b.y);
                    g.setColor(Color.red);
                    //int m = (int)((-1/(((a.y-b.y)/(a.x-b.x)))));
                    //System.out.println(m);
                    if(!isOnPlane) {
                        g.drawString(Integer.toString(edge.weight), (((a.x + b.x) / 2) + b.x) / 2, (((a.y + b.y) / 2) + b.y) / 2);
                    }
                    else{
                        g.drawString(Integer.toString(edge.weight), ((a.x + b.x) / 2), ((a.y + b.y) / 2));
                    }
                    g.setColor(Color.darkGray);

                    AffineTransform tx = new AffineTransform();
                    //Line2D.Double line = new Line2D.Double(0,0,100,100);

                    Polygon arrowHead = new Polygon(new int[]{0, -arrowThickness, arrowThickness}, new int[]{arrowThickness, -arrowThickness, -arrowThickness}, 3);

                    tx.setToIdentity();
                    double angle2 = Math.atan2(b.y - a.y, b.x - a.x);
                    tx.translate(b.x * 1, b.y *1); //*1.25
                    tx.rotate((angle2 - Math.PI/2d));

                    Graphics2D g1 = (Graphics2D) g.create();
                    g1.setTransform(tx);
                    g1.fill(arrowHead);
                    g1.dispose();
                }
            }
        }

        repaint();
    }
    public void draw(boolean isOnPlane, int debugCircles){
        this.isOnPlane = isOnPlane;
        this.debugCircles = debugCircles;
        repaint();
    }
}
