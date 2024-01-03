package GUI;

import Main.Main;

import javax.swing.*;
import java.awt.*;

public class GUI {
    private JLabel labelD;
    private JLabel labelB;
    private JLabel labelL;
    private JLabel buyer;
    private JLabel seller;
    private JTextField textFieldD;
    private JTextField textFieldB;
    private JTextField textFieldL;
    private JButton button1;
    private JButton button2;
    private JFrame frame;
    private JPanel panel;

    public void Run (){
        labelD = new JLabel("Doge Coin");
        labelB = new JLabel("Bit Coin");
        labelL = new JLabel("Lit Coin");
        buyer = new JLabel("???");
        seller = new JLabel("???");
        textFieldD = new JTextField(10);
        textFieldB = new JTextField(10);
        textFieldL = new JTextField(10);
        button1 = new JButton("Refresh");
        button2 = new JButton("Boost");
        frame = new JFrame("Stock Market");
        panel = new JPanel();

        panel.setLayout(new GridLayout(5,2));
        frame.setDefaultCloseOperation(JFrame.EXIT_ON_CLOSE);
        frame.getContentPane().add(panel);

        panel.add(labelD);
        panel.add(textFieldD);
        panel.add(labelB);
        panel.add(textFieldB);
        panel.add(labelL);
        panel.add(textFieldL);
        panel.add(buyer);
        panel.add(seller);
        panel.add(button1);
        panel.add(button2);

        frame.setSize(600,300);
        frame.setVisible(true);

        button1.addActionListener(e -> Refresh());
        button2.addActionListener(e -> Boost());
    }
    public void Refresh(){
        Main.stockMarket.BoostMarketValues(-15f, 16f);
        Main.stockMarket.notifyObservers();
    }
    public void Boost(){
        Main.stockMarket.RandomBoostMarketValues();
        Main.stockMarket.notifyObservers();
    }
    public double Round(double x){
        return Math.round(x*100.0)/100.0;
    }
    public void DrawStockData(double d, double b, double l){
        textFieldD.setText(String.valueOf(Round(d)));
        textFieldB.setText(String.valueOf(Round(b)));
        textFieldL.setText(String.valueOf(Round(l)));
    }
    public void ChangeBuyText(String val){
        buyer.setText(val);
    }
    public void ChangeSellText(String val){
        seller.setText(val);
    }
}