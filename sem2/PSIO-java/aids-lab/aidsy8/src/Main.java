import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import java.util.Random;

public class Main {

    private static class GUI {
        private JCheckBox showWest;
        private JCheckBox showEast;
        private JLabel labelName;
        private JLabel labelID1;
        private JLabel labelID2;
        private JLabel labelWeight;
        private JTextField textFieldName;
        private JTextField textFieldID1;
        private JTextField textFieldID2;
        private JTextField textFieldWeight;
        private JTextArea textAreaOutputWest;
        private JTextArea textAreaOutputEast;
        private JButton addNodeButton;
        private JButton addEdgeButton;
        private JButton newOnPlaneGraphButton;
        private JButton newRandomGraphButton;
        private JButton newGraphButton;
        private JButton connectAllNodesButton;
        private JButton newRNGGraphButton;
        private JButton newGGGraphButton;
        private JButton setStartEndButton;
        private JButton switchDirectedButton;
        private JButton debugCirclesButton;
        private JFrame frame;
        private JPanel inputPanel;
        private JPanel buttonPanel;
        private DrawGraph drawGraphComponent;
        class AddNode implements ActionListener {
            @Override
            public void actionPerformed(ActionEvent e){
                try {
                    String name = textFieldName.getText();
                    int x = random.nextInt(50, drawGraphComponent.getWidth() - 150);
                    int y = random.nextInt(50, drawGraphComponent.getHeight() - 50);
                    try{
                        x = Integer.parseInt(textFieldID1.getText());
                        y = Integer.parseInt(textFieldID2.getText());
                    }catch (Exception exception){}

                    if(!isOnPlane) graph.addNode(name);
                    else graph.addNodeOnPlane(name, x, y);
                    printGraph();
                }
                catch (Exception exception){
                    exception.printStackTrace();
                }
            }
        }
        class AddEdge implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                try {
                    int id1 = Integer.parseInt(textFieldID1.getText());
                    int id2 = Integer.parseInt(textFieldID2.getText());
                    int weight = Integer.parseInt(textFieldWeight.getText());
                    graph.connect(id1, id2, weight);
                    printGraph();
                }
                catch (Exception exception){
                    exception.printStackTrace();
                }
            }
        }
        class SetStartEnd implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                try {
                    int id1 = Integer.parseInt(textFieldID1.getText());
                    int id2 = Integer.parseInt(textFieldID2.getText());
                    startNodeID = id1;
                    endNodeID = id2;
                    printGraph();
                }
                catch (Exception exception){
                    exception.printStackTrace();
                }
            }
        }
        class SwitchDirected implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                graph.setDirected(!graph.directed);
                directedButtonFix();
                printGraph();
            }
        }
        public void directedButtonFix(){
            if(graph.directed) switchDirectedButton.setText("Zmień na Nieskierowany");
            else switchDirectedButton.setText("Zmień na Skierowany");
        }
        class CreateGraph implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                isOnPlane = false;
                graph = new Graph();
                directedButtonFix();
                startNodeID = 0;
                endNodeID = 0;
                printGraph();
            }
        }
        class CreatePlaneGraph implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                isOnPlane = true;
                int nodeCount = random.nextInt(6, 12);
                graph = new Graph(nodeCount); //on plane
                graph.generateOnPlaneGraph(nodeCount, 50, drawGraphComponent.getWidth() - 150, 50, drawGraphComponent.getHeight() - 50);

                directedButtonFix();
                printGraph();
            }
        }
        class CreateRNGGraph implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                isOnPlane = true;
                graph.connectAll(graph.nodes.size());
                graph = convertRNG(graph.nodes.size());

                directedButtonFix();
                printGraph();
            }
        }
        class CreateGGGraph implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                isOnPlane = true;
                graph.connectAll(graph.nodes.size());
                graph = convertGG(graph.nodes.size());

                directedButtonFix();
                printGraph();
            }
        }
        private Graph convertRNG(int nodeCount){
            if (!isOnPlane) return graph;

            Graph outputGraph = new Graph(nodeCount); //on plane
            outputGraph.setDirected(false);

            for(int i = 0; i < nodeCount; i++){
                outputGraph.addNodeOnPlane("N" + i, graph.nodes.get(i).pos.x, graph.nodes.get(i).pos.y);
            }

            for (int i = 0; i < graph.nodes.size(); i++) {
                for (int j = 0; j < graph.nodes.size(); j++) {
                    int dist_ij = graph.nodes.get(i).getEdgeWeight(graph.nodes.get(j));
                    if(relativeNeighborCheck(i, j, dist_ij)) outputGraph.connectOnPlane(graph.nodes.get(i).id, graph.nodes.get(j).id);
                }
            }
            return outputGraph;
        }
        private boolean relativeNeighborCheck(int i, int j, int dist_ij){
            for (int x = 0; x < graph.nodes.size(); x++) {
                int dist_ix = graph.nodes.get(i).getEdgeWeight(graph.nodes.get(x));
                int dist_xj = graph.nodes.get(x).getEdgeWeight(graph.nodes.get(j));
                if (dist_xj * dist_ix * dist_ij != 0){
                    if (Math.max(dist_ix, dist_xj) < dist_ij) return false;
                }
            }
            return true;
        }

        private Graph convertGG(int nodeCount){
            if (!isOnPlane) return graph;

            Graph outputGraph = new Graph(nodeCount); //on plane
            outputGraph.setDirected(false);

            for(int i = 0; i < nodeCount; i++){
                outputGraph.addNodeOnPlane("N" + i, graph.nodes.get(i).pos.x, graph.nodes.get(i).pos.y);
            }

            for (int i = 0; i < graph.nodes.size(); i++) {
                for (int j = 0; j < graph.nodes.size(); j++) {
                    int radius = graph.nodes.get(i).getEdgeWeight(graph.nodes.get(j)) / 2;
                    if(gabrielCheck(i, j, radius)) outputGraph.connectOnPlane(graph.nodes.get(i).id, graph.nodes.get(j).id);
                }
            }
            return outputGraph;
        }
        private boolean gabrielCheck(int i, int j, int radius){
            for (int x = 0; x < graph.nodes.size(); x++) {
                if(x != i && x != j && radius != 0) {
                    Point iPoint = graph.nodes.get(i).pos;
                    Point jPoint = graph.nodes.get(j).pos;
                    Point xPoint = graph.nodes.get(x).pos;
                    Point mid = new Point((iPoint.x + jPoint.x) / 2, (iPoint.y + jPoint.y) / 2);
                    int dist = graph.calculateDistance(mid, xPoint);
                    if (dist <= radius) return false;
                }
            }
            return true;
        }

        class ConnectAll implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                /* //OLD EXAMPLE GRAPH
                isOnPlane = false;
                graph = new Graph();
                directedButtonFix();

                startNodeID = 0;
                endNodeID = 3;

                graph.addNode("N0");
                graph.addNode("N1");
                graph.addNode("N2");
                graph.addNode("N3");
                graph.addNode("N4");
                graph.connect(0, 3, 9);
                graph.connect(0, 1, 1);
                graph.connect(1, 2, 2);
                graph.connect(2, 3, 3);

                printGraph();
                */
                isOnPlane = true;
                graph.connectAll(graph.nodes.size());

                directedButtonFix();
                printGraph();
            }
        }
        class CreateRandomGraph implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                isOnPlane = false;
                int nodeCount = random.nextInt(1, 11);
                startNodeID = random.nextInt(0, nodeCount);
                endNodeID = random.nextInt(0, nodeCount);
                graph = new Graph(nodeCount, 20, graph.directed);
                graph.generateCoherentGraph(nodeCount, 20);
                directedButtonFix();
                printGraph();
            }
        }
        class ShowWest implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                if(showWest.isSelected()){
                    frame.remove(textAreaOutputWest);
                }
                else{
                    frame.add(textAreaOutputWest, BorderLayout.WEST);
                }
                frame.repaint();
                drawGraphComponent.draw(isOnPlane, debugCircles);
            }
        }
        class ShowEast implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                if(showEast.isSelected()){
                    frame.remove(textAreaOutputEast);
                }
                else{
                    frame.add(textAreaOutputEast, BorderLayout.EAST);
                }
                frame.repaint();
                drawGraphComponent.draw(isOnPlane, debugCircles);
            }
        }
        class DebugCircles implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                debugCircles += 1;
                debugCircles %= 3;
                drawGraphComponent.draw(isOnPlane, debugCircles);
            }
        }
        private void printGraph(){
            textFieldID1.setText("");
            textFieldID2.setText("");
            textFieldWeight.setText("");
            textFieldName.setText("");
            dijkstra.run(graph, startNodeID, endNodeID);
            cycleFinder.run(graph);
            textAreaOutputWest.setText("StartNode: " + startNodeID + ", EndNode: " + endNodeID + "\nDijkstra shortest path length: " + dijkstra.getShortestPathLength() + "\nDijkstra Shortest Path: " + dijkstra.shortestPath + "\nGraph: " + graph.toString());
            textAreaOutputEast.setText(cycleFinder.display());

            drawGraphComponent.draw(isOnPlane, debugCircles);
            //panel3 = new DrawCircleFrame(graph.nodes.size());
            //panel3.repaint();
        }
        public void run(){
            textAreaOutputWest = new JTextArea();
            textAreaOutputWest.setRows(19);
            textAreaOutputWest.setEditable(false);

            textAreaOutputEast = new JTextArea();
            textAreaOutputEast.setRows(19);
            textAreaOutputEast.setEditable(false);

            labelName = new JLabel("Name", SwingConstants.CENTER);
            labelID1 = new JLabel("ID1", SwingConstants.CENTER);
            labelID2 = new JLabel("ID2", SwingConstants.CENTER);
            labelWeight = new JLabel("Weight", SwingConstants.CENTER);

            textFieldName = new JTextField();
            textFieldID1 = new JTextField();
            textFieldID2 = new JTextField();
            textFieldWeight = new JTextField();

            addNodeButton = new JButton("Dodaj Nowy Węzęł");
            addNodeButton.addActionListener(new AddNode());

            addEdgeButton = new JButton("Dodaj Nową Krawędź");
            addEdgeButton.addActionListener(new AddEdge());

            setStartEndButton = new JButton("Ustaw Start i End");
            setStartEndButton.addActionListener(new SetStartEnd());

            switchDirectedButton = new JButton("Zmień na Nieskierowany");
            switchDirectedButton.addActionListener(new SwitchDirected());

            newOnPlaneGraphButton = new JButton("Nowy Graf 2D"); //asjuhsdahigdfaighjdifahgiohgiad
            newOnPlaneGraphButton.addActionListener(new CreatePlaneGraph());

            newGraphButton = new JButton("Wyczyść Graf");
            newGraphButton.addActionListener(new CreateGraph());

            newRNGGraphButton = new JButton("Nowy Graf RNG");
            newRNGGraphButton.addActionListener(new CreateRNGGraph());

            newGGGraphButton = new JButton("Nowy Graf GG");
            newGGGraphButton.addActionListener(new CreateGGGraph());

            connectAllNodesButton = new JButton("Połącz Wszystkie Nody");
            connectAllNodesButton.addActionListener(new ConnectAll());

            newRandomGraphButton = new JButton("Wylosuj Nowy Graf");
            newRandomGraphButton.addActionListener(new CreateRandomGraph());

            showWest = new JCheckBox("Hide West Panel");
            showWest.addActionListener(new ShowWest());

            showEast = new JCheckBox("Hide East Panel");
            showEast.addActionListener(new ShowEast());

            debugCirclesButton = new JButton("Toggle Circles");
            debugCirclesButton.addActionListener(new DebugCircles());

            inputPanel = new JPanel();
            inputPanel.setLayout(new GridLayout(1,11));
            inputPanel.add(labelName);
            inputPanel.add(textFieldName);
            inputPanel.add(labelID1);
            inputPanel.add(textFieldID1);
            inputPanel.add(labelID2);
            inputPanel.add(textFieldID2);
            inputPanel.add(labelWeight);
            inputPanel.add(textFieldWeight);
            inputPanel.add(showWest);
            inputPanel.add(showEast);
            inputPanel.add(debugCirclesButton);

            drawGraphComponent = new DrawGraph();

            buttonPanel = new JPanel();
            buttonPanel.setLayout(new GridLayout(2,5));
            buttonPanel.add(addNodeButton);
            buttonPanel.add(addEdgeButton);
            buttonPanel.add(setStartEndButton);
            buttonPanel.add(switchDirectedButton);
            buttonPanel.add(newOnPlaneGraphButton);
            buttonPanel.add(newGraphButton);
            buttonPanel.add(newRNGGraphButton);
            buttonPanel.add(newGGGraphButton);
            buttonPanel.add(connectAllNodesButton);
            buttonPanel.add(newRandomGraphButton);

            frame = new JFrame("Dijkstra");
            frame.setVisible(true);
            frame.setSize(1800,800);
            frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            frame.setResizable(true);

            frame.add(textAreaOutputWest, BorderLayout.WEST);
            frame.add(textAreaOutputEast, BorderLayout.EAST);
            frame.add(inputPanel, BorderLayout.NORTH);
            frame.add(buttonPanel, BorderLayout.SOUTH);
            frame.add(drawGraphComponent, BorderLayout.CENTER);

            printGraph();
        }
    }
    public static Graph graph = new Graph();
    public static boolean isOnPlane = false;
    public static int startNodeID = 0;
    public static int endNodeID = 3;
    public static int debugCircles = 0;
    public static Random random = new Random();
    public static Dijkstra dijkstra = new Dijkstra();
    public static CycleFinder cycleFinder = new CycleFinder();
    public static GUI gui = new GUI();

    public static void main(String[] args) {

        graph.setDirected(false);
        graph.addNode("N0");
        graph.addNode("N1");
        graph.addNode("N2");
        graph.addNode("N3");
        graph.connect(0, 2, 8);
        graph.connect(2, 3, 5);
        graph.connect(3, 0, 5);
        graph.connect(1, 0, 3);
        graph.connect(1, 2, 3);

        dijkstra.run(graph, startNodeID, endNodeID);
        System.out.println("StartNode: " + startNodeID + ", EndNode: " + endNodeID);
        System.out.println(graph);
        System.out.println("Dijkstra shortest path length: " + dijkstra.getShortestPathLength());
        System.out.println("Dijkstra shortest path: " + dijkstra.shortestPath);

        gui.run();
    }
}