package Exercise3.MyActors;

import Exercise3.Resources.Resource;

public class ProductionWorker extends MyAbstractActor {
    public ProductionWorker(String actorName) {
        super(actorName);
    }
    @Override
    public void HandleNewResource() {
        if (isAbleToStartProduction()){
            StartProduction();
        }
    }
}
