import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class GUItocopyforlater {
    private JLabel labelName;
    private JLabel labelID;
    private JTextField textFieldName;
    private JTextField textFieldID;
    private JTextField labelOutput;
    private JButton button;
    private JFrame frame;
    private JPanel panel;
    class ClickButton implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e){

            textFieldID.setText("");
            textFieldName.setText("");
        }
    }
    class OutPut implements ActionListener{
        @Override
        public void actionPerformed(ActionEvent e){
            labelOutput.setText("1");
        }
    }
    public void run (){
        labelName = new JLabel("Name");
        labelID = new JLabel("ID");
        labelOutput = new JTextField("output");
        textFieldName = new JTextField();
        textFieldID = new JTextField();
        button = new JButton("Dodaj Studenta");
        frame = new JFrame();
        panel = new JPanel();

        panel.setLayout(new GridLayout(3,2));
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.getContentPane().add(panel);

        panel.add(labelName);
        panel.add(textFieldName);
        panel.add(labelID);
        panel.add(textFieldID);
        panel.add(button);
        panel.add(labelOutput);

        frame.setSize(800,400);
        frame.setVisible(true);

        button.addActionListener(new ClickButton());
        labelOutput.addActionListener(new OutPut());
    }
}
