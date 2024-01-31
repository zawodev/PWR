package Exercise3;

import Exercise3.Resources.Resource;
import Exercise3.Resources.ResourceType;

import java.util.ArrayList;

public class FinalApp {
    public static void main(String[] args) throws InterruptedException {
        ArrayList<Resource> startResources = new ArrayList<>() {{
            add(new Resource(ResourceType.WOOD_WASTE, 0));
            add(new Resource(ResourceType.PAPER, 0));
            add(new Resource(ResourceType.INK, 150));
            add(new Resource(ResourceType.DYE, 150));
            add(new Resource(ResourceType.WOOD, 150));
            add(new Resource(ResourceType.SUDOKU, 0));
            add(new Resource(ResourceType.SUDOKU_MAGAZINE, 0));
            add(new Resource(ResourceType.DYED_INK, 0));
            add(new Resource(ResourceType.PLASTIC, 150));
        }};

        //max performance
        //Packing: SUDOKU [0], PLASTIC [50], SUDOKU_MAGAZINE [0]
        //Warehouse: WOOD_WASTE [150], PAPER [0], INK [0], DYE [0], WOOD [0], SUDOKU [0], SUDOKU_MAGAZINE [20], DYED_INK [0], PLASTIC [0]
        //Printer: DYED_INK [275], PAPER [0], SUDOKU [0]
        //InkColoring: INK [0], DYE [0], DYED_INK [0]
        //WoodCutter: WOOD [0], PAPER [0], WOOD_WASTE [0]

        SudokuFactory sudokuMagazineFactory = new SudokuFactory(startResources);
        sudokuMagazineFactory.Initialize();
    }
}
