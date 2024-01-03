import java.util.*;
public class PageReplacementSimulator {

    //wartości pamięci wirtualnej i fizycznej
    private int length;
    private int virtualMemorySize;
    private int physicalMemorySize;
    private double localityChance;

    // ciąg odwołań do stron
    private List<Integer> referenceString;

    // liczba błędów strony dla poszczególnych algorytmów zastępowania
    private int fifoFaults;
    private int optFaults;
    private int lruFaults;
    private int approxLruFaults;
    private int randFaults;

    public PageReplacementSimulator(int length, int virtualMemorySize, int physicalMemorySize, double localityChance) {
        this.length = length;
        this.virtualMemorySize = virtualMemorySize; //pamiec logiczna
        this.physicalMemorySize = physicalMemorySize;
        this.localityChance = localityChance;
        this.referenceString = generateReferenceString();
    }

    // metoda generująca ciąg odwołań do stron z zasadą lokalności
    private List<Integer> generateReferenceString() {
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

    // metoda symulująca algorytm FIFO
    private void simulateFIFO() {
        Queue<Integer> memoryQueue = new LinkedList<Integer>();
        fifoFaults = 0;
        for (int page : referenceString) {
            if (memoryQueue.contains(page)) {
                continue;
            }
            if (memoryQueue.size() == physicalMemorySize) {
                memoryQueue.poll();
            }
            memoryQueue.offer(page);
            fifoFaults++;
        }
    }

    // metoda symulująca algorytm OPT staraa
    private void simulateOPT_old() {
        List<Integer> memoryList = new ArrayList<Integer>();
        optFaults = 0;
        for (int page : referenceString) {
            if (memoryList.contains(page)) {
                continue;
            }
            if (memoryList.size() < physicalMemorySize) {
                memoryList.add(page);
            } else {
                int[] distances = new int[physicalMemorySize];
                Arrays.fill(distances, -1);
                for (int i = 0; i < physicalMemorySize; i++) {
                    int nextIndex = referenceString.indexOf(memoryList.get(i));
                    for (int j = i + 1; j < referenceString.size(); j++) {
                        if (referenceString.get(j) == memoryList.get(i)) {
                            nextIndex = j;
                            break;
                        }
                    }
                    if (nextIndex != -1) {
                        distances[i] = nextIndex;
                    }
                }
                int indexToRemove = 0;
                for (int i = 1; i < physicalMemorySize; i++) {
                    if (distances[i] == -1 || (distances[indexToRemove] > distances[i])) {
                        indexToRemove = i;
                    }
                }
                memoryList.set(indexToRemove, page);
            }
            optFaults++;
        }
    }
    private void simulateOPT() {
        List<Integer> memoryList = new ArrayList<Integer>();
        optFaults = 0;
        for (int i = 0; i < referenceString.size(); i++) {
            int page = referenceString.get(i);
            if (memoryList.contains(page)) {
                continue;
            }
            if (memoryList.size() < physicalMemorySize) {
                memoryList.add(page);
            } else {
                int indexToReplace = -1;
                int farthestUse = i;
                for (int j = 0; j < memoryList.size(); j++) {
                    int nextPageIndex = findNextUsage(memoryList.get(j), i);
                    if (nextPageIndex == -1) {
                        indexToReplace = j;
                        break;
                    } else if (nextPageIndex > farthestUse) {
                        farthestUse = nextPageIndex;
                        indexToReplace = j;
                    }
                }
                memoryList.set(indexToReplace, page);
            }
            optFaults++;
        }
    }

    // metoda pomocnicza znajdująca najdalsze użycie strony w ciągu testowym
    private int findNextUsage(int page, int startIndex) {
        for (int i = startIndex; i < referenceString.size(); i++) {
            if (referenceString.get(i) == page) {
                return i;
            }
        }
        return -1;
    }

    private void simulateLRU() {
        List<Integer> memoryList = new ArrayList<Integer>();
        lruFaults = 0;
        for (int page : referenceString) {
            if (memoryList.contains(page)) {
                memoryList.remove((Integer)page);
                memoryList.add(page);
            } else {
                if (memoryList.size() == physicalMemorySize) {
                    memoryList.remove(0);
                }
                memoryList.add(page);
                lruFaults++;
            }
        }
    }
    private void simulateApproxLRU() {
        List<Integer> memoryList = new ArrayList<Integer>();
        boolean[] bitref = new boolean[physicalMemorySize];
        approxLruFaults = 0;
        for (int page : referenceString) {
            if (memoryList.contains(page)) {
                memoryList.remove((Integer)page);
                memoryList.add(page);
                bitref[memoryList.indexOf(page)] = true;
            } else {
                if (memoryList.size() == physicalMemorySize) {
                    for (int i = 0; i < memoryList.size(); i++){
                        if (bitref[i]) bitref[i] = false;
                        else {memoryList.remove(i);}
                    }
                    if (memoryList.size() == physicalMemorySize) memoryList.remove(0);
                }
                memoryList.add(page);
                approxLruFaults++;
            }
        }
    }
    private void simulateRAND() {
        List<Integer> memoryList = new ArrayList<Integer>();
        randFaults = 0;
        for (int page : referenceString) {
            if (memoryList.contains(page)) {
                continue;
            }
            if (memoryList.size() == physicalMemorySize) {
                int indexToRemove = new Random().nextInt(physicalMemorySize);
                memoryList.remove(indexToRemove);
            }
            memoryList.add(page);
            randFaults++;
        }
    }

    public void displayResults() {
        System.out.println("Reference String: " + referenceString);
        System.out.println("Physical Memory Size: " + physicalMemorySize);
        System.out.println("FIFO Faults: " + fifoFaults);
        System.out.println("OPT Faults: " + optFaults);
        System.out.println("LRU Faults: " + lruFaults);
        System.out.println("Approx LRU Faults: " + approxLruFaults);
        System.out.println("RAND Faults: " + randFaults);
    }
    //lokalnosc zaklada ze jak mamy jakas strone istnieje wieksze prawdopodobienstwo ze nastepna tez bedzie ta strona a nie jakas losowa (np 50/50%)
    //ramki to fizyczna
    //strony to virtualna
    public static void main(String[] args) {
        PageReplacementSimulator simulator = new PageReplacementSimulator(10000,64, 16, .5);
        simulator.simulateFIFO();
        simulator.simulateOPT();
        simulator.simulateLRU();
        simulator.simulateApproxLRU();
        simulator.simulateRAND();
        simulator.displayResults();
    }
}

/*public class PageReplacementSimulator {
    public static int FIFO(){
        return 1;
    }
    public static void main(String[] args){
        int totalErrorCount; //odwołanie się do pamięci zapisanej na dysku
        int page = 10000;
        int ramki = 6;
        int lenght = 2000;
        totalErrorCount = FIFO();
        System.out.println("FIFO: " + totalErrorCount);
    }
}*/
