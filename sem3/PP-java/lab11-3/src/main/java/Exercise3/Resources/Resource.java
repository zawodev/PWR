package Exercise3.Resources;

public class Resource {
    private int amount;
    private final ResourceType resourceType;
    public Resource(ResourceType resourceType, int amount) {
        this.amount = amount;
        this.resourceType = resourceType;
    }
    public void add(int amount) {
        this.amount += amount;
    }
    public void subtract(int amount) {
        this.amount -= amount;
        if(this.amount < 0) {
            System.out.println("WARNING: " + resourceType.toString() + " amount is negative! Not good!");
            this.amount = 0;
        }
    }

    public int getAmount() {
        return amount;
    }
    public ResourceType getResourceType() {
        return resourceType;
    }
}
