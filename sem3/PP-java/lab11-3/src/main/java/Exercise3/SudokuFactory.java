package Exercise3;

import Exercise3.ActorMsgs.*;
import Exercise3.MyActors.*;
import Exercise3.Tools.Recipe;
import Exercise3.Resources.Resource;
import Exercise3.Resources.ResourceType;
import Exercise3.Tools.InactivityTimer;
import Exercise3.Tools.Pair;
import akka.actor.ActorRef;
import akka.actor.ActorSystem;
import akka.actor.Props;

import java.util.ArrayList;

public class SudokuFactory {
    public static final String warehouseName = "Warehouse";
    public static final String woodCutterName = "WoodCutter";
    public static final String inkColoringName = "InkColoring";
    public static final String printerName = "Printer";
    public static final String packingName = "Packing";

    private final double transferTime = 1.6;
    private final double timeSpeed = 20.0;
    private final double inactivityTime = 5.0;

    private final ArrayList<Resource> startResources;
    private ActorSystem system;
    private final ArrayList<ActorRef> actors = new ArrayList<>();

    public SudokuFactory(ArrayList<Resource> startResources) {
        this.startResources = startResources;
        new InactivityTimer(this, inactivityTime);
    }
    public void Initialize() {
        system = ActorSystem.create("SudokuFactory");
        System.out.println("\n---- Starting Sudoku Magazine Factory... ----\n");

        ActorRef warehouseActor = system.actorOf(Props.create(Warehouse.class, warehouseName), warehouseName);
        ActorRef woodCutterActor = system.actorOf(Props.create(ProductionWorker.class, woodCutterName), woodCutterName);
        ActorRef inkColoringActor = system.actorOf(Props.create(ProductionWorker.class, inkColoringName), inkColoringName);
        ActorRef printerActor = system.actorOf(Props.create(ProductionWorker.class, printerName), printerName);
        ActorRef packingActor = system.actorOf(Props.create(ProductionWorker.class, packingName), packingName);

        actors.add(warehouseActor);
        actors.add(woodCutterActor);
        actors.add(inkColoringActor);
        actors.add(printerActor);
        actors.add(packingActor);

        Recipe warehouseRecipe = new Recipe(
                new ArrayList<>() {{
                    add(new Resource(ResourceType.WOOD, 15));
                }},
                new ArrayList<>() {{
                    add(new Resource(ResourceType.PAPER, 10));
                    add(new Resource(ResourceType.WOOD_WASTE, 15));
                }},
                8,
                transferTime / timeSpeed,
                3.7 / timeSpeed,
                0.02
        );
        Recipe woodCutterRecipe = new Recipe(
                new ArrayList<>() {{
                    add(new Resource(ResourceType.INK, 25));
                    add(new Resource(ResourceType.DYE, 25));
                }},
                new ArrayList<>() {{
                    add(new Resource(ResourceType.DYED_INK, 50));
                }},
                4,
                transferTime / timeSpeed,
                3.4 / timeSpeed,
                0.01
        );
        Recipe printerRecipe = new Recipe(
                new ArrayList<>() {{
                    add(new Resource(ResourceType.PAPER, 20));
                    add(new Resource(ResourceType.DYED_INK, 5));
                }},
                new ArrayList<>() {{
                    add(new Resource(ResourceType.SUDOKU, 40));
                }},
                16,
                transferTime / timeSpeed,
                0.69 / timeSpeed,
                0.03
        );
        Recipe packingRecipe = new Recipe(
                new ArrayList<>() {{
                    add(new Resource(ResourceType.PLASTIC, 5));
                    add(new Resource(ResourceType.SUDOKU, 10));
                }},
                new ArrayList<>() {{
                    add(new Resource(ResourceType.SUDOKU_MAGAZINE, 1));
                }},
                1,
                transferTime / timeSpeed,
                2.1 / timeSpeed,
                0.07
        );

        woodCutterActor.tell(new TransferRuleMsg(new ArrayList<>() {{
            add(new Pair<>(warehouseActor, ResourceType.WOOD_WASTE));
            add(new Pair<>(printerActor, ResourceType.PAPER));
        }}), ActorRef.noSender());

        inkColoringActor.tell(new TransferRuleMsg(new ArrayList<>() {{
            add(new Pair<>(printerActor, ResourceType.DYED_INK));
        }}), ActorRef.noSender());

        printerActor.tell(new TransferRuleMsg(new ArrayList<>() {{
            add(new Pair<>(packingActor, ResourceType.SUDOKU));
        }}), ActorRef.noSender());

        packingActor.tell(new TransferRuleMsg(new ArrayList<>() {{
            add(new Pair<>(warehouseActor, ResourceType.SUDOKU_MAGAZINE));
        }}), ActorRef.noSender());

        warehouseActor.tell(new TransferRuleMsg(new ArrayList<>() {{
            add(new Pair<>(woodCutterActor, ResourceType.WOOD));
            add(new Pair<>(inkColoringActor, ResourceType.INK));
            add(new Pair<>(inkColoringActor, ResourceType.DYE));
            add(new Pair<>(printerActor, ResourceType.DYED_INK));
            add(new Pair<>(printerActor, ResourceType.PAPER));
            add(new Pair<>(packingActor, ResourceType.SUDOKU));
            add(new Pair<>(packingActor, ResourceType.PLASTIC));
        }}), ActorRef.noSender());

        woodCutterActor.tell(new RecipeMsg(warehouseRecipe), ActorRef.noSender());
        inkColoringActor.tell(new RecipeMsg(woodCutterRecipe), ActorRef.noSender());
        printerActor.tell(new RecipeMsg(printerRecipe), ActorRef.noSender());
        packingActor.tell(new RecipeMsg(packingRecipe), ActorRef.noSender());

        for (Resource resource : startResources) {
            warehouseActor.tell(new ResourceMsg(resource), ActorRef.noSender());
        }
    }
    public void Shutdown(){
        System.out.println("\n---- Shutting down Sudoku Magazine Factory... ----\n");
        for (ActorRef actor : actors) {
            actor.tell(new PrintActorMsg(true), ActorRef.noSender());
        }
        system.terminate();
        System.exit(0);
    }
}
