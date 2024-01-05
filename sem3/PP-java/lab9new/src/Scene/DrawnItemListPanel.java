package Scene;
import java.awt.*;
import java.awt.event.ActionEvent;
import java.awt.event.ActionListener;
import javax.swing.*;
import Item.*;
class DrawnItemListPanel extends JPanel {
    private Scene scene;

    public DrawnItemListPanel(Scene scene) {
        this.scene = scene;
        setLayout(new BoxLayout(this, BoxLayout.Y_AXIS));
        createButtons();
    }

    // Tworzenie przycisków dla każdego przedmiotu
    private void createButtons() {
        removeAll();
        System.out.println(scene.getItems().size());
        for (Item item : scene.getItems()) {
            JButton itemButton = new JButton(item.getItemInfo());
            itemButton.addActionListener(e -> {
                // Akcja po kliknięciu przycisku - wyświetlenie panelu edycji
                showEditPanel(item);
                //scene.draw();
            });

            // Dodawanie przycisków do panelu
            add(itemButton);
        }
        //repaint();
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
