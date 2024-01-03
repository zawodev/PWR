package Coach;

import Goalkeeper.JumpPractice;
import Striker.HeadPractice;

public class CoachScaloni extends Coach{
    public CoachScaloni(){
        setAlgorytmInfoGK(new JumpPractice());
        setAlgorytmInfoST(new HeadPractice());
    }
    @Override
    public String ShowInfo(){
        return "Scaloni: GK: " + getAlgorytmInfoGK() + ", ST: " + getAlgorytmInfoST();
    }
}
