package Striker;

import Striker.StrikerPractice;

public class ShotPractice implements StrikerPractice {
    private int shots;
    public String StartStrikerPractice(){
        return "Strzały napastników wzrosły o 1pkt i wynosi teraz: " + ++shots;
    }
}
