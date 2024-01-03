package Goalkeeper;

import Goalkeeper.GoalkeeperPractice;

public class LagaPractice implements GoalkeeperPractice {
    private int laga;
    public String StartGoalkeeperPractice(){
        return "Laga bramkarzy wzrosło o 1pkt i wynosi teraz: " + ++laga;
    }
}
