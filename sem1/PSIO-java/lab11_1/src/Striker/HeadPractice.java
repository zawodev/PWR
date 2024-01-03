package Striker;

import Striker.StrikerPractice;

import java.io.Serializable;

public class HeadPractice implements StrikerPractice, Serializable {
    private int heads = 1;
    public String StartStrikerPractice(){
        heads *= 2;
        return "Główkowanie napastników wzrosło 2 razy i wynosi teraz: " + heads;
    }
}
