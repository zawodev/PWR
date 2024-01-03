import javax.swing.*;
import javax.swing.text.SimpleAttributeSet;
import javax.swing.text.StyleConstants;
import javax.swing.text.StyledDocument;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;

import static javax.swing.JComponent.getDefaultLocale;
import static javax.swing.JOptionPane.showMessageDialog;

public class Main {
    private static class GUI {
        private JLabel labelName;
        private JLabel labelID;
        private JTextField textFieldName;
        private JTextField textFieldID;
        private JTextArea textAreaOutput;
        private JButton addStudentButton;
        private JButton removeStudentButton;
        private JButton findStudentButton;
        private JButton newBSTButton;
        private JButton newRBTButton;
        private JFrame frame;
        private JPanel panel1;
        private JPanel panel2;
        class AddStudent implements ActionListener {
            @Override
            public void actionPerformed(ActionEvent e){
                try {
                    int id = Integer.parseInt(textFieldID.getText());
                    String name = textFieldName.getText();
                    tree.insert(new Student(id, name));
                    printTree();
                }
                catch (Exception exception){
                    exception.printStackTrace();
                }
            }
        }
        class RemoveStudent implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                try {
                    int id = Integer.parseInt(textFieldID.getText());
                    String name = textFieldName.getText();
                    tree.remove(new Student(id, name));
                    printTree();
                }
                catch (Exception exception){
                    exception.printStackTrace();
                }
            }
        }
        class FindStudent implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                try {
                    int id = Integer.parseInt(textFieldID.getText());
                    String name = textFieldName.getText();
                    Student student = tree.find(new Student(id, name));
                    if(student != null)
                        JOptionPane.showMessageDialog(null, "Znaleziono Studenta: " + student);
                    else
                        JOptionPane.showMessageDialog(null, "Nie ma takiego studenta w drzewie");
                }
                catch (Exception exception){
                    exception.printStackTrace();
                }
            }
        }
        class CreateBSTree implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                tree = new BST<>(new StudentComparator());
                printTree();
            }
        }
        class CreateRBTree implements ActionListener{
            @Override
            public void actionPerformed(ActionEvent e){
                tree = new RBT<>(new StudentComparator());
                printTree();
            }
        }
        private void printTree(){
            textFieldID.setText("");
            textFieldName.setText("");
            textAreaOutput.setText(tree.getTreeToString());
        }
        public void run(){
            textAreaOutput = new JTextArea();
            textAreaOutput.setRows(19);
            textAreaOutput.setEditable(false);

            labelName = new JLabel("Name", SwingConstants.CENTER);
            labelID = new JLabel("ID", SwingConstants.CENTER);

            textFieldName = new JTextField();
            textFieldID = new JTextField();

            addStudentButton = new JButton("Dodaj Studenta");
            addStudentButton.addActionListener(new AddStudent());

            removeStudentButton = new JButton("Usun Studenta");
            removeStudentButton.addActionListener(new RemoveStudent());

            findStudentButton = new JButton("Znajdz Studenta");
            findStudentButton.addActionListener(new FindStudent());

            newBSTButton = new JButton("Nowe Drzewo BST");
            newBSTButton.addActionListener(new CreateBSTree());

            newRBTButton = new JButton("Nowe Drzewo RBT");
            newRBTButton.addActionListener(new CreateRBTree());

            panel1 = new JPanel();
            panel1.setLayout(new GridLayout(1,4));
            panel1.add(labelName);
            panel1.add(textFieldName);
            panel1.add(labelID);
            panel1.add(textFieldID);

            panel2 = new JPanel();
            panel2.setLayout(new GridLayout(1,5));
            panel2.add(addStudentButton);
            panel2.add(removeStudentButton);
            panel2.add(findStudentButton);
            panel2.add(newBSTButton);
            panel2.add(newRBTButton);

            frame = new JFrame("Drzewa BST oraz RBT");
            frame.setVisible(true);
            frame.setSize(1500,400);
            frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
            frame.setResizable(false);

            frame.add(textAreaOutput, BorderLayout.NORTH);
            frame.add(panel1, BorderLayout.CENTER);
            frame.add(panel2, BorderLayout.SOUTH);

            printTree();
        }
    }
    static Tree<Student> tree;
    public static void main(String[] args) {
        //tree = new BST<>(new StudentComparator());
        tree = new RBT<>(new StudentComparator());
        GUI gui = new GUI();


        Student2StrExec exec = new Student2StrExec();

        tree.insert(new Student(2, "a"));
        tree.insert(new Student(4, "b"));
        tree.insert(new Student(1, "C"));
        tree.insert(new Student(8, "D"));
        tree.insert(new Student(3, "e"));
        tree.insert(new Student(7, "f"));
        tree.insert(new Student(9, "G"));
        tree.insert(new Student(6, "H"));

        tree.inOrderWalk(exec);
        System.out.println(exec.getResult());
        exec.reset();


        gui.run();

    }
}