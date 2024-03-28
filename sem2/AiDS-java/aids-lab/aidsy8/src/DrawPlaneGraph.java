import javax.swing.*;
import java.awt.*;
import java.awt.geom.AffineTransform;
import java.util.ArrayList;
import java.util.PriorityQueue;

public class DrawPlaneGraph extends JComponent {
    private ArrayList<Point> points = new ArrayList();
    private int thickness = 50;
    private int arrowThickness = 7;
    private float radius = 200;   // Promień koła
    private float centerX = 500;  // Współrzędna x środka koła
    private float centerY = 400;  // Współrzędna y środka koła

    public DrawPlaneGraph() {
        //setPreferredSize(new Dimension(1500, 800));
        setVisible(true);
    }
    @Override
    protected void paintComponent(Graphics g){
        int numPoints = Main.graph.nodes.size();
        double angle = 2 * Math.PI / numPoints;
        points = new ArrayList<>();

        for (int i = 0; i < numPoints; i++) {
            int x = (int) (centerX + radius * Math.cos(i * angle));
            int y = (int) (centerY + radius * Math.sin(i * angle));

            points.add(new Point(x, y));

            g.setColor(Color.gray);
            g.fillOval(x - thickness / 2, y - thickness / 2, thickness, thickness);
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
                    g.drawString(Integer.toString(edge.weight), (((a.x + b.x) / 2) + b.x) / 2, (((a.y + b.y) / 2) + b.y) / 2);
                    g.setColor(Color.darkGray);

                    AffineTransform tx = new AffineTransform();
                    //Line2D.Double line = new Line2D.Double(0,0,100,100);

                    Polygon arrowHead = new Polygon(new int[]{0, -arrowThickness, arrowThickness}, new int[]{arrowThickness, -arrowThickness, -arrowThickness}, 3);

                    tx.setToIdentity();
                    double angle2 = Math.atan2(b.y - a.y, b.x - a.x);
                    tx.translate(b.x, b.y);
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
    public void draw(){
        repaint();
    }
}
