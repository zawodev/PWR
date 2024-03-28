import java.util.*;

public class Page2 {
    private static class PageReplacementSimulator {
        private int virtualMemorySize;
        private int physicalMemorySize;
        private List<Integer> memoryList = new ArrayList<Integer>();
        private int lruFaults;

        public PageReplacementSimulator(int virtualMemorySize, int physicalMemorySize) {
            this.virtualMemorySize = virtualMemorySize; //pamiec logiczna
            this.physicalMemorySize = physicalMemorySize;
        }

        private int simulateLRU(int page) {
            if (memoryList.contains(page)) {
                memoryList.remove((Integer)page);
                memoryList.add(page);
            } else if(physicalMemorySize == 0) lruFaults++;
            else {
                if (memoryList.size() == physicalMemorySize) {
                    memoryList.remove(0);
                    lruFaults++;
                }
                memoryList.add(page);
            }
            return lruFaults;
        }
        public String toString() {
            return Integer.toString(lruFaults);
        }
    }
    public static List<Integer> generateReferenceString(int length, int virtualMemorySize, double localityChance) {
        List<Integer> referenceString = new ArrayList<Integer>();
        Random random = new Random();
        int[] pages = new int[virtualMemorySize];
        for (int i = 0; i < pages.length; i++) {
            pages[i] = i;
        }
        int page = 1;
        for (int i = 0; i < length; i++) {
            if(localityChance >= random.nextDouble(0, 1)){
                referenceString.add(page);
            }
            else {
                page = pages[random.nextInt(pages.length)];
                referenceString.add(page);
            }
        }
        return referenceString;
    }
    public static List<PageReplacementSimulator> generatePageReplacementSimulatorList(int[] maxVirtualSizes, int[] maxPhysicalSizes){
        List<PageReplacementSimulator> simulatorList = new ArrayList<>();
        for(int i = 0; i < maxPhysicalSizes.length; i++){
            simulatorList.add(new PageReplacementSimulator(maxVirtualSizes[i], maxPhysicalSizes[i]));
        }
        return simulatorList;
        //PageReplacementSimulator sim = new PageReplacementSimulator(10000, 64, 16, refString);
    }

    public static void displayResults(int[] maxVirtualSizes, int[] maxPhysicalSizes, int virtualMemorySize, int physicalMemorySize){
        //System.out.println("Pamięć Wirtualna: " + Arrays.toString(virtualSizes));
        System.out.println("Pamięć Wirtualna (per proces): " + Arrays.toString(maxVirtualSizes) + " - Łącznie: " + virtualMemorySize);
        //System.out.println("Pamięć Fizyczna: " + Arrays.toString(physicalSizes));
        System.out.println("Pamięć Fizyczna (per proces): " + Arrays.toString(maxPhysicalSizes) + " - Łącznie: " + physicalMemorySize);
    }
    public static void displayFinalResults(String methodName, List<PageReplacementSimulator> simulatorList){
        int sum = 0;
        String wyn = "[";
        System.out.println(methodName);
        for(PageReplacementSimulator simulator : simulatorList){
            sum += simulator.lruFaults;
            wyn += simulator + ", ";
        }
        wyn = wyn.substring(0, wyn.length()-2);
        System.out.println(wyn + "] - Łącznie: " + sum + "\n");
    }

    public static List<PageReplacementSimulator> Method1(List<Integer> refString, int[] maxVirtualSizes, int virtualMemorySize, int physicalMemorySize){

        int[] virtualSizes = new int[virtualMemorySize];
        int[] physicalSizes = new int[physicalMemorySize];
        int[] maxPhysicalSizes = new int[maxVirtualSizes.length];
        int[] maxVirtualSizes2 = maxVirtualSizes.clone();
        int j = 0;
        for(int i = 0; i < virtualMemorySize; i++){
            while (maxVirtualSizes2[j] <= 0) j++;
            virtualSizes[i] = j+1;
            maxVirtualSizes2[j]--;
        }
        maxVirtualSizes2 = maxVirtualSizes.clone();
        for(int i = 0; i < physicalMemorySize; i++) {
            int maxVal = 0;
            int maxIndex = 0;
            for(int k = 0; k < maxVirtualSizes2.length; k++){
                if(maxVirtualSizes2[k] > maxVal){
                    maxVal = maxVirtualSizes2[k];
                    maxIndex = k;
                }
            }
            maxVirtualSizes2[maxIndex] -= Math.max(virtualMemorySize/physicalMemorySize, 1);
            physicalSizes[i] = maxIndex+1;
            maxPhysicalSizes[maxIndex]++;
        }

        List<PageReplacementSimulator> simulatorList = generatePageReplacementSimulatorList(maxVirtualSizes, maxPhysicalSizes);

        displayResults(maxVirtualSizes, maxPhysicalSizes, virtualMemorySize, physicalMemorySize);

        for(Integer value : refString){
            //System.out.println(value);
            simulatorList.get(virtualSizes[value] - 1).simulateLRU(value);
        }
        displayFinalResults("Przydział Proporcjonalny: ", simulatorList);
        return simulatorList;
        //jeden refernce string wrzucic wyzej dla kazdego, pozniej przejezdzac i dorzucac na biezaco, po czym display global
    }
    public static List<PageReplacementSimulator> Method2(List<Integer> refString, int[] maxVirtualSizes, int virtualMemorySize, int physicalMemorySize){

        int[] virtualSizes = new int[virtualMemorySize];
        int[] physicalSizes = new int[physicalMemorySize];
        int[] maxPhysicalSizes = new int[maxVirtualSizes.length];
        int[] maxVirtualSizes2 = maxVirtualSizes.clone();
        int j = 0;
        for(int i = 0; i < virtualMemorySize; i++){
            while (maxVirtualSizes2[j] <= 0) j++;
            virtualSizes[i] = j+1;
            maxVirtualSizes2[j]--;
        }

        for(int i = 0; i < physicalMemorySize; i++) {
            physicalSizes[i] = (i % maxPhysicalSizes.length)+1;
            maxPhysicalSizes[physicalSizes[i]-1]++;
        }

        List<PageReplacementSimulator> simulatorList = generatePageReplacementSimulatorList(maxVirtualSizes, maxPhysicalSizes);

        //displayResults(maxVirtualSizes, maxPhysicalSizes, virtualMemorySize, physicalMemorySize);

        for(Integer value : refString){
            //System.out.println(value);
            simulatorList.get(virtualSizes[value] - 1).simulateLRU(value);
        }

        displayFinalResults("Przydział Równy: ", simulatorList);
        return simulatorList;

        //jeden refernce string wrzucic wyzej dla kazdego, pozniej przejezdzac i dorzucac na biezaco, po czym display global
    }
    public static List<PageReplacementSimulator> Method3(List<Integer> refString, int[] maxVirtualSizes, int virtualMemorySize, int physicalMemorySize, boolean newMethod){

        int[] virtualSizes = new int[virtualMemorySize];
        int[] physicalSizes = new int[physicalMemorySize];
        int[] maxPhysicalSizes = new int[maxVirtualSizes.length];
        int[] maxVirtualSizes2 = maxVirtualSizes.clone();

        int[] maxFaults = new int[maxVirtualSizes.length];

        int j = 0;
        for(int i = 0; i < virtualMemorySize; i++){
            while (maxVirtualSizes2[j] <= 0) j++;
            virtualSizes[i] = j+1;
            maxVirtualSizes2[j]--;
        }

        if(!newMethod) {
            j = 0;
            maxVirtualSizes2 = maxVirtualSizes.clone();
            for (int i = 0; i < physicalMemorySize; i++) {
                while (maxVirtualSizes2[j] <= 0) j++;
                maxVirtualSizes2[j]--;
                maxPhysicalSizes[j]++;
                physicalSizes[i] = j + 1;
            }
        }
        else{
            for(int i = 0; i < physicalMemorySize; i++) {
                physicalSizes[i] = (i % maxPhysicalSizes.length)+1;
                maxPhysicalSizes[physicalSizes[i]-1]++;
            }
        }

        List<PageReplacementSimulator> simulatorList = generatePageReplacementSimulatorList(maxVirtualSizes, maxPhysicalSizes);
        //displayResults(maxVirtualSizes, maxPhysicalSizes, virtualMemorySize, physicalMemorySize);
        j = 0;
        for(Integer value : refString){
            int index = virtualSizes[value] - 1;
            PageReplacementSimulator simulator = simulatorList.get(index);
            int val = simulator.simulateLRU(value);

            if(newMethod){
                if(val != maxFaults[index]) {
                    maxFaults[index] = val;
                    while (maxPhysicalSizes[j] <= 0) {j++; j %= maxVirtualSizes.length;}
                    PageReplacementSimulator simulator2 = simulatorList.get(j);
                    simulator.physicalMemorySize += 1;
                    simulator2.physicalMemorySize -= 1;
                    while(simulator2.memoryList.size() > simulator2.physicalMemorySize) simulator2.memoryList.remove(0);
                    maxPhysicalSizes[index]++;
                    maxPhysicalSizes[j]--;
                }
            }
        }
        //displayResults(maxVirtualSizes, maxPhysicalSizes, virtualMemorySize, physicalMemorySize);
        displayFinalResults("Model Strefowy: ", simulatorList);
        return simulatorList;

        //jeden refernce string wrzucic wyzej dla kazdego, pozniej przejezdzac i dorzucac na biezaco, po czym display global
    }
    public static List<PageReplacementSimulator> Method4(List<Integer> refString, int[] maxVirtualSizes, int virtualMemorySize, int physicalMemorySize){

        int[] virtualSizes = new int[virtualMemorySize];
        int[] physicalSizes = new int[physicalMemorySize];
        int[] maxPhysicalSizes = new int[maxVirtualSizes.length];
        int[] maxVirtualSizes2 = maxVirtualSizes.clone();

        int[] maxFaults = new int[maxVirtualSizes.length];

        int j = 0;
        for(int i = 0; i < virtualMemorySize; i++){
            while (maxVirtualSizes2[j] <= 0) j++;
            virtualSizes[i] = j+1;
            maxVirtualSizes2[j]--;
        }
        maxVirtualSizes2 = maxVirtualSizes.clone();
        for(int i = 0; i < physicalMemorySize; i++) {
            int maxVal = 0;
            int maxIndex = 0;
            for(int k = 0; k < maxVirtualSizes2.length; k++){
                if(maxVirtualSizes2[k] > maxVal){
                    maxVal = maxVirtualSizes2[k];
                    maxIndex = k;
                }
            }
            maxVirtualSizes2[maxIndex] -= Math.max(virtualMemorySize/physicalMemorySize, 1);
            physicalSizes[i] = maxIndex+1;
            maxPhysicalSizes[maxIndex]++;
        }

        List<PageReplacementSimulator> simulatorList = generatePageReplacementSimulatorList(maxVirtualSizes, maxPhysicalSizes);
        //displayResults(maxVirtualSizes, maxPhysicalSizes, virtualMemorySize, physicalMemorySize);
        for(Integer value : refString){
            int index = virtualSizes[value] - 1;
            PageReplacementSimulator simulator = simulatorList.get(index);
            int val = simulator.simulateLRU(value);
            if(val != maxFaults[index]) {
                maxFaults[index] = val;
                int minVal = maxFaults[0];
                int minIndex = 0;
                for (int i = 1; i < maxFaults.length; i++) {
                    if (maxFaults[i] < minVal && maxPhysicalSizes[i] > 0) {
                        minVal = maxFaults[i];
                        minIndex = i;
                    }
                }
                if(maxPhysicalSizes[minIndex] > 0) {
                    int diff = simulatorList.get(minIndex).physicalMemorySize / 2 + simulatorList.get(minIndex).physicalMemorySize % 2;
                    PageReplacementSimulator simulator2 = simulatorList.get(minIndex);

                    simulator.physicalMemorySize += diff;
                    simulator2.physicalMemorySize -= diff;
                    while(simulator2.memoryList.size() > simulator2.physicalMemorySize) simulator2.memoryList.remove(0);
                    maxPhysicalSizes[index]++;
                    maxPhysicalSizes[minIndex]--;
                }
            }
        }
        //displayResults(maxVirtualSizes, maxPhysicalSizes, virtualMemorySize, physicalMemorySize);
        displayFinalResults("Strategia sterowania częstością błędu: ", simulatorList);
        return simulatorList;

        //jeden refernce string wrzucic wyzej dla kazdego, pozniej przejezdzac i dorzucac na biezaco, po czym display global
    }

    public static void main(String[] args) {
        //ramki to fizyczna
        //strony to virtualna
        int length = 10000;
        int[] maxVirtualSizes = new int[]{28, 3, 3, 4, 5, 5, 12, 20, 50, 3, 7};

        int virtualMemorySize = 0;
        for (int i = 0; i < maxVirtualSizes.length; i++) virtualMemorySize += maxVirtualSizes[i];

        int physicalMemorySize = 64;
        double localityChance = .8;

        System.out.println("Wirtualna pamięć (Strony): " + virtualMemorySize);
        System.out.println("Fizyczna pamięć (Ramki): " + physicalMemorySize);

        List<Integer> refString = generateReferenceString(length, virtualMemorySize, localityChance);
        System.out.println(refString);
        System.out.println("=================================");

        List<PageReplacementSimulator> simulatorList1 = Method1(refString, maxVirtualSizes, virtualMemorySize, physicalMemorySize);
        List<PageReplacementSimulator> simulatorList2 = Method2(refString, maxVirtualSizes, virtualMemorySize, physicalMemorySize);
        List<PageReplacementSimulator> simulatorList3 = Method3(refString, maxVirtualSizes, virtualMemorySize, physicalMemorySize, true);
        List<PageReplacementSimulator> simulatorList4 = Method4(refString, maxVirtualSizes, virtualMemorySize, physicalMemorySize);

        /*System.out.println("=================================");
        displayFinalResults("Przydział Proporcjonalny: ", simulatorList1);
        displayResults();
        displayFinalResults("Przydział Równy: ", simulatorList2);
        displayFinalResults("Model Strefowy: ", simulatorList3);
        displayFinalResults("Strategia sterowania częstością błędu: ", simulatorList4);*/
    }

}
