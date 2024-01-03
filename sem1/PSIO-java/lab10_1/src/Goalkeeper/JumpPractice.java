package Goalkeeper;

import Goalkeeper.GoalkeeperPractice;

public class JumpPractice implements GoalkeeperPractice {
    private int jump;
    public String StartGoalkeeperPractice(){
        jump += 5;
        return "Skok bramkarzy wzrósł o 5pkt i wynosi teraz: " + jump;
    }
}
