package Coach;

import Goalkeeper.GoalkeeperPractice;
import Striker.StrikerPractice;

public abstract class Coach {
    private GoalkeeperPractice practiceGK;
    private StrikerPractice practiceST;
    private String algorytmInfoGK;
    private String algorytmInfoST;

    public void trainST(){
        setAlgorytmInfoST(practiceST);
    }
    public void trainGK(){
        setAlgorytmInfoGK(practiceGK);
    }

    public String getAlgorytmInfoGK() {
        return algorytmInfoGK;
    }
    public String getAlgorytmInfoST() {
        return algorytmInfoST;
    }
    public void setAlgorytmInfoST(StrikerPractice practiceST){
        this.practiceST = practiceST;
        algorytmInfoST = practiceST.StartStrikerPractice();
    }
    public void setAlgorytmInfoGK(GoalkeeperPractice practiceGK){
        this.practiceGK = practiceGK;
        algorytmInfoGK = practiceGK.StartGoalkeeperPractice();
    }

    public abstract String ShowInfo();
}
