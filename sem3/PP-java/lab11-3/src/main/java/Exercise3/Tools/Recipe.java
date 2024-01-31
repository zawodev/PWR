package Exercise3.Tools;

import Exercise3.Resources.Resource;

import java.util.ArrayList;

public class Recipe {
    private final ArrayList<Resource> requiredResources;
    private final ArrayList<Resource> producedResources;
    private final int slotAmount;
    private final double transferTime;
    private final double productionTime;
    private final double failureProbability;
    public Recipe(ArrayList<Resource> requiredResources, ArrayList<Resource> producedResources, int slotAmount, double transferTime, double productionTime, double failureProbability) {
        this.requiredResources = requiredResources;
        this.producedResources = producedResources;

        this.slotAmount = slotAmount;
        this.transferTime = transferTime;
        this.productionTime = productionTime;
        this.failureProbability = failureProbability;
    }
    public ArrayList<Resource> getRequiredResources() {
        return requiredResources;
    }
    public ArrayList<Resource> getProducedResources() {
        return producedResources;
    }
    public int getSlotAmount() {
        return slotAmount;
    }
    public double getTransferTime() {
        return transferTime;
    }
    public double getProductionTime() {
        return productionTime;
    }
    public double getFailureProbability() {
        return failureProbability;
    }
}
