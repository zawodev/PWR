package Observer;

import Observable.Observable;
import Main.Main;

public class StockIndexesDrawer implements Observer {
    private Observable stockMarket;
    public StockIndexesDrawer(Observable stockMarket) {
        this.stockMarket = stockMarket;
        this.stockMarket.registerObserver(this);
    }

    @Override
    public void update(double dogeCoinIndex, double bitCoinIndex, double litCoinIndex) {
        Main.gui.DrawStockData(dogeCoinIndex, bitCoinIndex, litCoinIndex);
    }
}
