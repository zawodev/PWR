package Exercise3.MyActors;

import Exercise3.ActorMsgs.*;
import Exercise3.Tools.Recipe;
import Exercise3.Tools.InactivityTimer;
import Exercise3.Resources.Resource;
import Exercise3.Resources.ResourceType;
import akka.actor.UntypedAbstractActor;
import akka.actor.ActorRef;
import Exercise3.Tools.Pair;

import java.util.*;
import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public abstract class MyAbstractActor extends UntypedAbstractActor {
    protected String actorName;
    protected Random random;
    protected Recipe recipe;
    protected int availableSlots;
    protected ExecutorService executorService;
    protected ArrayList<Resource> myResources;
    protected ArrayList<Pair<ActorRef, ResourceType>> resourcesToTransfer;
    public MyAbstractActor(String actorName) {
        this.actorName = actorName;
        this.random = new Random();
        recipe = new Recipe(
                new ArrayList<>(),
                new ArrayList<>(),
                1,
                1,
                1,
                0
        );
        this.availableSlots = recipe.getSlotAmount();
        this.executorService = Executors.newFixedThreadPool(availableSlots);
        this.myResources = new ArrayList<>();
        this.resourcesToTransfer = new ArrayList<>();
    }
    public abstract void HandleNewResource();
    @Override
    public void onReceive(Object message) {
        InactivityTimer.inactivityTimer.ResetInactivityTimer();
        switch (message) {
            case ResourceMsg resourceMsg:
                onReceivedResourceMsg(resourceMsg.resource());
                break;
            case RecipeMsg recipeMsg:
                onReceivedRecipeMsg(recipeMsg.recipe());
                break;
            case TransferRuleMsg transferRuleMsg:
                onReceivedTransferRuleMsg(transferRuleMsg.transferRules());
                break;
            case PrintActorMsg printMsg:
                onReceivedPrintActorMsg(printMsg.printAll());
                break;
            case null:
            default:
                System.out.println(actorName + " nie obsługuje wiadomości!");
                unhandled(message);
                break;
        }
    }
    private void onReceivedResourceMsg(Resource resource) {
        AddToMyResources(resource);
        if(resource.getAmount() > 0) {
            System.out.println(actorName + " otrzymał: " + resource.getResourceType().toString() + "[" + resource.getAmount() + "]");
            HandleNewResource();
        }
    }
    private void onReceivedRecipeMsg(Recipe recipe) {
        this.recipe = recipe;
        this.executorService = Executors.newFixedThreadPool(recipe.getSlotAmount());
    }
    private void onReceivedTransferRuleMsg(ArrayList<Pair<ActorRef, ResourceType>> pairs) {
        this.resourcesToTransfer = pairs;
    }
    private void onReceivedPrintActorMsg(boolean printAll) {
        StringBuilder printMsg = new StringBuilder(actorName + ": ");
        for (Resource myResource : myResources) {
            printMsg.append(myResource.getResourceType().toString()).append(" [").append(myResource.getAmount()).append("], ");
        }
        if (!myResources.isEmpty()) System.out.println(printMsg.substring(0, printMsg.length() - 2));
        else System.out.println(printMsg + "brak zasobów");
    }




    protected synchronized void AddToMyResources(Resource resource) {
        boolean found = false;
        for (Resource myResource : myResources) {
            if (myResource.getResourceType() == resource.getResourceType()) {
                myResource.add(resource.getAmount());
                found = true;
                break;
            }
        }
        if (!found) myResources.add(new Resource(resource.getResourceType(), resource.getAmount()));
    }
    protected void TransferResources()  {
        for (Pair<ActorRef, ResourceType> resourceToTransfer : resourcesToTransfer) {
            ActorRef actorRef = resourceToTransfer.getFirst();
            ResourceType resourceType = resourceToTransfer.getSecond();

            if (actorRef == null) {
                System.out.println(actorName + " nie ma referencji do aktora!!!");
                return;
            }

            for (Resource myResource : myResources) {
                if (myResource.getResourceType() == resourceType && myResource.getAmount() > 0) {
                    System.out.println(actorName + " wysłał: " + myResource.getResourceType().toString() + "[" + myResource.getAmount() + "]" + " do " + actorRef.path().name());
                    actorRef.tell(new ResourceMsg(new Resource(myResource.getResourceType(), myResource.getAmount())), ActorRef.noSender());
                    myResource.subtract(myResource.getAmount());

                    try {
                        Thread.sleep((long) (recipe.getTransferTime() * 1000));
                    } catch (InterruptedException e) {
                        throw new RuntimeException(e);
                    }

                    break;
                }
            }
        }
    }






    protected synchronized boolean isAbleToStartProduction(){
        for (Resource requiredResource : recipe.getRequiredResources()) {
            boolean found = false;
            for (Resource myResource : myResources) {
                if (requiredResource.getResourceType() == myResource.getResourceType()) {
                    if (requiredResource.getAmount() <= myResource.getAmount()) {
                        found = true;
                    }
                }
            }
            if(!found) {
                return false;
            }
        }


        if (availableSlots <= 0) {
            System.out.println(actorName + " nie ma wolnych slotów!");
            return false;
        }


        return true;
    }
    protected synchronized void StartProduction() {
        RemoveRequiredResources();
        executorService.submit(() -> {
            availableSlots--;
            AddProducedResources();
            availableSlots++;
            TransferResources();

            if(isAbleToStartProduction()) StartProduction();
        });
    }
    private synchronized void RemoveRequiredResources() {
        for (Resource requiredResource : recipe.getRequiredResources()) {
            for (Resource myResource : myResources) {
                if (requiredResource.getResourceType() == myResource.getResourceType()) {
                    myResource.subtract(requiredResource.getAmount());
                }
            }
        }
    }
    private void AddProducedResources() {
        try {
            Thread.sleep((long) (recipe.getProductionTime() * 1000));
        } catch (InterruptedException e) {
            throw new RuntimeException(e);
        }

        if (random.nextDouble() > recipe.getFailureProbability()) {
            for (Resource producedResource : recipe.getProducedResources()) {
                AddToMyResources(producedResource);
            }
            System.out.println(actorName + ": wyprodukował skutecznie to co miał wyprodukować!");
        } else {
            System.out.println("--- " + actorName + ": o jezus maria zdarzyła się awaria! ---");
        }
    }
}
