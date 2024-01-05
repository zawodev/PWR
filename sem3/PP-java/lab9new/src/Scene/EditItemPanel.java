package Scene;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import Point.Point;
import Item.*;
import javax.swing.*;
class EditItemPanel extends JPanel {
    private Scene scene;
    private Item item;
    private JTextField translationXField;
    private JTextField translationYField;

    public EditItemPanel(Scene scene, Item item) {
        this.item = item;
        setLayout(new BorderLayout());
        createEditFields();
        createButtons();
    }

    // Tworzenie pól tekstowych do edycji parametrów
    private void createEditFields() {
        JLabel itemInfoLabel = new JLabel(item.getItemInfo());
        add(itemInfoLabel, BorderLayout.NORTH);

        translationXField = new JTextField("0");
        translationYField = new JTextField("0");

        JPanel translationPanel = new JPanel();
        translationPanel.add(new JLabel("Translation X:"));
        translationPanel.add(translationXField);
        translationPanel.add(new JLabel("Translation Y:"));
        translationPanel.add(translationYField);

        add(translationPanel, BorderLayout.CENTER);
    }

    // Tworzenie przycisków do akcji
    private void createButtons() {
        JButton translateButton = new JButton("Translate");
        translateButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                // Akcja po kliknięciu przycisku "Translate"
                int translationX = Integer.parseInt(translationXField.getText());
                int translationY = Integer.parseInt(translationYField.getText());
                item.translate(new Point(translationX, translationY));
                repaint();
            }
        });

        JButton deleteButton = new JButton("Delete");
        deleteButton.addActionListener(new ActionListener() {
            @Override
            public void actionPerformed(ActionEvent e) {
                // Akcja po kliknięciu przycisku "Delete"
                // Usunięcie przedmiotu z listy i zamknięcie okna edycji
                scene.getItems().remove(item);
                ((JFrame) SwingUtilities.getWindowAncestor(EditItemPanel.this)).dispose();
            }
        });

        add(translateButton, BorderLayout.SOUTH);
        add(deleteButton, BorderLayout.SOUTH);
    }
}