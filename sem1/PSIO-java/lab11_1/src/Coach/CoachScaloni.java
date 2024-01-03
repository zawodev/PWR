package Coach;

import Goalkeeper.JumpPractice;
import Striker.HeadPractice;

import java.io.Serializable;

public class CoachScaloni extends Coach implements Serializable {
    public CoachScaloni(){
        super();
        setAlgorytmInfoGK(new JumpPractice());
        setAlgorytmInfoST(new HeadPractice());
    }
    @Override
    public String ShowInfo(){
        return "Scaloni: GK: " + getAlgorytmInfoGK() + ", ST: " + getAlgorytmInfoST();
    }
}
