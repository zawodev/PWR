package Scene;
import java.awt.*;
import java.awt.event.*;
import java.util.ArrayList;
import javax.swing.*;
import Item.*;
class DrawnItemListPanel extends JPanel {
    protected Scene scene;
    protected boolean isEditPanelOpen = false;
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
                if (!isEditPanelOpen) {
                    isEditPanelOpen = true;
                    Item newItem = scene.EnableBoundingBox(item);
                    showEditPanel(newItem);
                }
                else {
                    System.out.println("Okno edycji jest już otwarte!");
                }
                //scene.draw();
            });

            add(itemButton);
        }
        repaint();
        revalidate();
    }

    // Metoda do wyświetlenia panelu edycji po kliknięciu przycisku
    private void showEditPanel(Item item) {
        EditItemPanel editPanel = new EditItemPanel(this, scene, item);
        JFrame editFrame = new JFrame("Edit Item");
        editFrame.addWindowListener(new WindowAdapter() {
            @Override
            public void windowClosing(WindowEvent e) {
                isEditPanelOpen = false;
                if(item != null) scene.DisableBoundingBox(item);
            }
        });
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
