package Main;
import GUI.GUI;
import Observable.StockMarket;
import Observer.StockBuyer;
import Observer.StockIndexesDrawer;
import Observer.StockSeller;

public class Main {
    public static GUI gui;
    public static StockMarket stockMarket;

    public static void main(String[] args) {
        stockMarket = new StockMarket();
        StockIndexesDrawer SID = new StockIndexesDrawer(stockMarket);
        StockBuyer SB = new StockBuyer(stockMarket);
        StockSeller SS = new StockSeller(stockMarket);

        gui = new GUI();
        gui.Run();
    }
}