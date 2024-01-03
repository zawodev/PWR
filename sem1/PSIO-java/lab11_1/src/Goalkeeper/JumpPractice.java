package Goalkeeper;

import Goalkeeper.GoalkeeperPractice;

import java.io.Serializable;

public class JumpPractice implements GoalkeeperPractice, Serializable {
    private int jump;
    public String StartGoalkeeperPractice(){
        jump += 5;
        return "Skok bramkarzy wzrósł o 5pkt i wynosi teraz: " + jump;
    }
}
