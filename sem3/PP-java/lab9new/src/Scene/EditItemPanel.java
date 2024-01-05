package Scene;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import Point.Point;
import Item.*;
import javax.swing.*;
class EditItemPanel extends JPanel {
    protected Scene scene;
    protected Item item;
    protected JTextField translationXField;
    protected JTextField translationYField;

    public EditItemPanel(Scene scene, Item item) {
        this.scene = scene;
        this.item = item;
        //setLayout(new BorderLayout());
        setLayout(new FlowLayout(FlowLayout.CENTER, 0, 0));
        createEditFields();
        createButtons();
    }
    private void createEditFields() {
        JLabel itemInfoLabel = new JLabel(item.getItemInfo());
        add(itemInfoLabel, BorderLayout.NORTH);

        translationXField = new JTextField("0");
        translationXField.setColumns(4);
        translationYField = new JTextField("0");
        translationYField.setColumns(4);

        JPanel translationPanel = new JPanel();
        translationPanel.add(new JLabel("Translation X:"));
        translationPanel.add(translationXField);
        translationPanel.add(new JLabel("Translation Y:"));
        translationPanel.add(translationYField);

        add(translationPanel, BorderLayout.CENTER);
    }
    private void createButtons() {
        JButton translateButton = createTranslateButton();
        add(translateButton);

        JButton deleteButton = createDeleteButton();
        add(deleteButton);
    }

    private JButton createTranslateButton() {
        JButton translateButton = new JButton("Translate");
        translateButton.addActionListener(e -> {
            int translationX = Integer.parseInt(translationXField.getText());
            int translationY = Integer.parseInt(translationYField.getText());
            item.translate(new Point(translationX, translationY));
            scene.draw();
            SwingUtilities.getWindowAncestor(EditItemPanel.this).dispose();
        });
        return translateButton;
    }
    private JButton createDeleteButton() {
        JButton deleteButton = new JButton("Delete");
        deleteButton.addActionListener(e -> {
            scene.removeItem(item);
            scene.draw();
            SwingUtilities.getWindowAncestor(EditItemPanel.this).dispose();
        });
        return deleteButton;
    }

}