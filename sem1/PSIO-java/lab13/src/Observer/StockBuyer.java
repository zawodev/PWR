package Observer;

import Main.Main;
import Observable.Observable;

public class StockBuyer implements Observer{
    private Observable stockMarket;
    public StockBuyer(Observable stockMarket) {
        this.stockMarket = stockMarket;
        this.stockMarket.registerObserver(this);
    }
    @Override
    public void update(double dogeCoinIndex, double bitCoinIndex, double litCoinIndex) {
        if(dogeCoinIndex > 40f){
            Main.gui.ChangeBuyText("Buy DogeCoin!");
        }
        else if(bitCoinIndex < -10f){
            Main.gui.ChangeBuyText("Buy BitCoin!");
        }
        else if(litCoinIndex > 10f && litCoinIndex < 20f){
            Main.gui.ChangeBuyText("Buy LitCoin!");
        }
        else{
            Main.gui.ChangeBuyText("Dont Buy anything!");
        }
    }
}
