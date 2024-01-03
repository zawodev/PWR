package Coach;

import Goalkeeper.LagaPractice;
import Striker.HeadPractice;

public class CoachMichniewicz extends Coach {

    public CoachMichniewicz(){
        setAlgorytmInfoGK(new LagaPractice());
        setAlgorytmInfoST(new HeadPractice());
    }
    @Override
    public String ShowInfo(){
        return "Michniewicz: GK: " + getAlgorytmInfoGK() + ", ST: " + getAlgorytmInfoST();
    }
}
