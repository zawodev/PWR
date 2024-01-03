package Coach;

import Goalkeeper.LagaPractice;
import Striker.HeadPractice;

import java.io.Serializable;

public class CoachMichniewicz extends Coach implements Serializable {

    public CoachMichniewicz(){
        super();
        setAlgorytmInfoGK(new LagaPractice());
        setAlgorytmInfoST(new HeadPractice());
    }
    @Override
    public String ShowInfo(){
        return "Michniewicz: GK: " + getAlgorytmInfoGK() + ", ST: " + getAlgorytmInfoST();
    }
}
