package Striker;

import Striker.StrikerPractice;

import java.io.Serializable;

public class ShotPractice implements StrikerPractice, Serializable {
    private int shots;
    public String StartStrikerPractice(){
        return "Strzały napastników wzrosły o 1pkt i wynosi teraz: " + ++shots;
    }
}
