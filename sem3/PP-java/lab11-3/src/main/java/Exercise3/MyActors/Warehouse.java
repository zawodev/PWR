package Exercise3.MyActors;

public class Warehouse extends MyAbstractActor {
    public Warehouse(String actorName) {
        super(actorName);
    }

    @Override
    public void HandleNewResource() {
        TransferResources();
    }
}
