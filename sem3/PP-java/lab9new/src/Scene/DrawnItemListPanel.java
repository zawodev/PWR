package Scene;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.*;
import Item.*;
class DrawnItemListPanel extends JPanel {
    protected Scene scene;
    public DrawnItemListPanel(Scene scene) {
        this.scene = scene;
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        setPreferredSize(new Dimension(170, 0));
        setBackground(Color.LIGHT_GRAY);
        createButtons();
    }

    // Tworzenie przycisków dla każdego przedmiotu
    private void createButtons() {
        removeAll();//lepiej by było gdyby usuwać tylko te które się zmieniły i nie są już na scenie

        add(new JLabel("Drawn Items:"));

        for (Item item : scene.getItems()) {
            JButton itemButton = new JButton(item.getItemInfo());
            itemButton.addActionListener(e -> {
                showEditPanel(item);
                //scene.draw();
            });

            add(itemButton);
        }
        repaint();
        revalidate();
    }

    // Metoda do wyświetlenia panelu edycji po kliknięciu przycisku
    private void showEditPanel(Item item) {
        EditItemPanel editPanel = new EditItemPanel(scene, item);
        JFrame editFrame = new JFrame("Edit Item");
        editFrame.setDefaultCloseOperation(JFrame.DISPOSE_ON_CLOSE);
        editFrame.getContentPane().add(editPanel, BorderLayout.CENTER);
        editFrame.setSize(300, 150);
        editFrame.setLocationRelativeTo(null);
        editFrame.setVisible(true);
    }
    public void refresh() {
        createButtons();
    }
}
