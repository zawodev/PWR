package Striker;

import Striker.StrikerPractice;

public class HeadPractice implements StrikerPractice {
    private int heads = 1;
    public String StartStrikerPractice(){
        heads *= 2;
        return "Główkowanie napastników wzrosło 2 razy i wynosi teraz: " + heads;
    }
}
