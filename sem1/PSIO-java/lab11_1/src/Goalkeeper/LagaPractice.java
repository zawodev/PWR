package Goalkeeper;

import Goalkeeper.GoalkeeperPractice;

import java.io.Serializable;

public class LagaPractice implements GoalkeeperPractice, Serializable {
    private int laga;
    public String StartGoalkeeperPractice(){
        return "Laga bramkarzy wzrosło o 1pkt i wynosi teraz: " + ++laga;
    }
}
