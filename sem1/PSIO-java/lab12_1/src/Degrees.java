import javax.swing.*;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

public class Degrees {
    private JLabel labelC;
    private JLabel labelF;
    private JTextField textFieldC;
    private JTextField textFieldF;
    private JButton button;
    private JFrame frame;
    private JPanel panel;
    class Clear implements ActionListener {
        @Override
        public void actionPerformed(ActionEvent e){
            textFieldF.setText("");
            textFieldC.setText("");
        }
    }
    class DF implements ActionListener{
        @Override
        public void actionPerformed(ActionEvent e){
            try{
                double val = Double.parseDouble(textFieldF.getText());
                textFieldC.setText(String.valueOf(Converter.FtoC(val)));
            }
            catch (NumberFormatException exception){
                JOptionPane.showMessageDialog(null, "Invalid number format!", "", JOptionPane.ERROR_MESSAGE);
            }
        }
    }
    class DC implements ActionListener{
        @Override
        public void actionPerformed(ActionEvent e){
            try{
                double val = Double.parseDouble(textFieldC.getText());
                textFieldF.setText(String.valueOf(Converter.CtoF(val)));
            }
            catch (NumberFormatException exception){
                JOptionPane.showMessageDialog(null, "Invalid number format!", "", JOptionPane.ERROR_MESSAGE);
            }
        }
    }
    public void GUI (){
        labelC = new JLabel("Celsius");
        labelF = new JLabel("Fahrenheit");
        textFieldC = new JTextField(10);
        textFieldF = new JTextField(10);
        button = new JButton("Clear fields");
        frame = new JFrame();
        panel = new JPanel();

        panel.setLayout(new GridLayout(3,2));
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.getContentPane().add(panel);

        panel.add(labelC);
        panel.add(textFieldC);
        panel.add(labelF);
        panel.add(textFieldF);
        panel.add(button);

        frame.setSize(400,150);
        frame.setVisible(true);

        button.addActionListener(new Clear());
        textFieldF.addActionListener(new DF());
        textFieldC.addActionListener(new DC());
    }
}
