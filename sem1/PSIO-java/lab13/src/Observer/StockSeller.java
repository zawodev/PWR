package Observer;

import Main.Main;
import Observable.Observable;

public class StockSeller implements Observer{
    private Observable stockMarket;
    public StockSeller(Observable stockMarket) {
        this.stockMarket = stockMarket;
        this.stockMarket.registerObserver(this);
    }
    @Override
    public void update(double dogeCoinIndex, double bitCoinIndex, double litCoinIndex) {
        if(dogeCoinIndex < -10f){
            Main.gui.ChangeSellText("Sell DogeCoin!");
        }
        else if(bitCoinIndex > 40f){
            Main.gui.ChangeSellText("Sell BitCoin!");
        }
        else if(litCoinIndex > 20f && litCoinIndex < 40f){
            Main.gui.ChangeSellText("Sell LitCoin!");
        }
        else{
            Main.gui.ChangeSellText("Dont Sell anything!");
        }
    }
}
