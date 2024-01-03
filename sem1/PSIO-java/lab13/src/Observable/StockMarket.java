package Observable;

import Observer.Observer;

import java.util.ArrayList;
import java.util.Random;

public class StockMarket implements Observable{
    Random rand = new Random();
    ArrayList<Observer> ObserverList = new ArrayList<Observer>();
    private double dogeCoinIndex;
    private double bitCoinIndex;
    private double litCoinIndex;
    public StockMarket() {
        dogeCoinIndex = rand.nextDouble(-20, 20);
        bitCoinIndex = rand.nextDouble(-20, 20);
        litCoinIndex = rand.nextDouble(-20, 20);
    }

    public StockMarket(double dogeCoinIndex, double bitCoinIndex, double litCoinIndex) {
        this.dogeCoinIndex = dogeCoinIndex;
        this.bitCoinIndex = bitCoinIndex;
        this.litCoinIndex = litCoinIndex;
    }
    public void BoostMarketValues(double minVal, double maxVal) {
        this.dogeCoinIndex += rand.nextDouble(minVal, maxVal);
        this.bitCoinIndex += rand.nextDouble(minVal, maxVal);
        this.litCoinIndex += rand.nextDouble(minVal, maxVal);
    }
    public void RandomBoostMarketValues(){
        dogeCoinIndex += rand.nextDouble(0f,5f);
        bitCoinIndex += rand.nextDouble(0f,5f);
        litCoinIndex += rand.nextDouble(0f,5f);
    }

    @Override
    public void registerObserver(Observer observer) {
        ObserverList.add(observer);
    }

    @Override
    public void removeObserver(Observer observer) {
        ObserverList.remove(observer);
    }

    @Override
    public void notifyObservers() {
        for(int i = 0; i<ObserverList.size(); i++){
            ObserverList.get(i).update(dogeCoinIndex, bitCoinIndex, litCoinIndex);
        }
    }
}
