import java.util.ArrayList;
import java.util.Collections;
import java.util.Random;

public class Program5 {
    public static class Processor{
        public Processor(int id, int maxPower){
            this.id = id;
            this.maxPower = maxPower;

            processes = new ArrayList<>();
            migrationCount = 0;
            powerLevelInquiryCount = 0;
            currentPowerLevel = 0;
            timePassed = 0;
            powerLevelSum = 0;
            overFlowCount =0;
        }
        int id;
        int currentPowerLevel;
        int maxPower;
        public ArrayList<Process> processes;
        public int migrationCount;
        public int powerLevelInquiryCount;
        public int overFlowCount;
        public int powerLevelSum;
        public int timePassed;


        public float getPowerLevel() {
            return Math.min((float)currentPowerLevel / (float)maxPower, 1);
        }
        public float getAveragePowerLevel(){
            return (float) powerLevelSum / (float)timePassed;
        }
        public void migrate(){
            migrationCount++;
        }
        public void countPowerLevel(){
            powerLevelInquiryCount++;
        }

        public String toString(){
            return "Processor" + id + ", Unfinished Processes: " + processes.toString() + ":\nA) Average Processor Power : " + getAveragePowerLevel() + "\nC) MigrationCount: " + migrationCount + ", PowerLevelInquiryCount: " + powerLevelInquiryCount;
        }
        public void nextTime(int val){
            powerLevelSum += getPowerLevel() * val;
            timePassed += val;

            if(processes.isEmpty()) return;

            ArrayList<Process> endedProcesses = new ArrayList<>();
            for(Process process : processes){
                if(process.decrementTime(val)){
                    currentPowerLevel -= process.powerConsumption;
                    endedProcesses.add(process);
                }
            }
            processes.removeAll(endedProcesses);
        }
        public boolean addProcess(Process process){
            currentPowerLevel += process.powerConsumption;
            if(currentPowerLevel > maxPower) overFlowCount++;
            return processes.add(process);
        }
        public Process removeRandomProcess(){
            Random random = new Random();
            Process process = processes.remove(random.nextInt(processes.size()));
            currentPowerLevel -= process.powerConsumption;
            return process;
        }
    }
    public static class Process{
        public Process(int powerConsumption, int time, int timeToNext){
            this.powerConsumption = powerConsumption;
            this.time = time;
            this.timeToNext = timeToNext;
        }
        int powerConsumption;
        int time;
        int timeToNext;
        public int getTime(){
            return time;
        }
        public int getPowerConsumption(){
            return powerConsumption;
        }
        public boolean decrementTime(int val){
            time -= val;
            return time <= 0;
        }
        public String toString(){
            return Integer.toString(powerConsumption);
        }
    }
    public static ArrayList<Processor> generateProcessors(int N, int maxPower){
        ArrayList<Processor> processors = new ArrayList<>();
        for(int i = 0; i < N; i++){
            processors.add(new Processor(i + 1, maxPower));
        }
        return processors;
    }
    public static ArrayList<Process> generateReferenceString(int length, int minPowerConsumption, int maxPowerConsumption, int minTime, int maxTime, int minTimeToNext, int maxTimeToNext) {
        ArrayList<Process> referenceString = new ArrayList<Process>();
        Random random = new Random();
        for (int i = 0; i < length; i++) {
            referenceString.add(new Process(random.nextInt(minPowerConsumption, maxPowerConsumption), random.nextInt(minTime, maxTime), random.nextInt(minTimeToNext, maxTimeToNext)));
        }
        return referenceString;
    }
    public static ArrayList<Process> copyReferenceString(ArrayList<Process> referenceString){
        ArrayList<Process> referenceString2 = new ArrayList<Process>();
        for (int i = 0; i < referenceString.size(); i++) {
            referenceString2.add(new Process(referenceString.get(i).powerConsumption, referenceString.get(i).time, referenceString.get(i).timeToNext));
        }
        return referenceString2;
    }
    public static void Strategy1(ArrayList<Process> refString, int N, float p, int z, int maxPower){
        ArrayList<Processor> processors = generateProcessors(N, maxPower);
        ArrayList<Process> refString2 = copyReferenceString(refString);

        Random random = new Random();
        for(Process process : refString2){
            Processor processor = processors.get(random.nextInt(0, processors.size()));
            for(int i = 0; i < z; i++){
                Processor processor2 = processors.get(random.nextInt(0, processors.size()));
                processor2.countPowerLevel();
                if(processor2.getPowerLevel() <= p){
                    processor.migrate();
                    processor = processor2;
                    break;
                }
            }
            processor.addProcess(process);

            for(Processor processor1 : processors){
                processor1.nextTime(process.timeToNext);
            }
        }
        showResults("[Strategy 1]", processors);
    }
    public static void Strategy2(ArrayList<Process> refString, int N, float p, int maxPower){
        ArrayList<Processor> processors = generateProcessors(N, maxPower);
        ArrayList<Processor> processors2 = new ArrayList<>(processors);

        ArrayList<Process> refString2 = copyReferenceString(refString);

        Random random = new Random();
        for(Process process : refString2){
            Processor processor = processors.get(random.nextInt(0, processors.size()));
            processor.countPowerLevel();
            if(processor.getPowerLevel() > p){
                Collections.shuffle(processors2);
                for(Processor processor2 : processors2){
                    processor2.countPowerLevel();
                    if(processor2.getPowerLevel() <= p){
                        processor.migrate();
                        processor = processor2;
                        break;
                    }
                    //else processors2.remove(processor2); //can i do this???
                }
            }
            processor.addProcess(process);
            //System.out.println(processor.getPowerLevel());
            //System.out.println(process.powerConsumption);

            for(Processor processor1 : processors){

                processor1.nextTime(process.timeToNext);
            }
        }
        showResults("[Strategy 2]", processors);
    }
    public static void Strategy3(ArrayList<Process> refString, int N, float p, float r, float takePercent, int maxPower){
        ArrayList<Processor> processors = generateProcessors(N, maxPower);
        ArrayList<Processor> processors2 = new ArrayList<>(processors);
        ArrayList<Process> refString2 = copyReferenceString(refString);

        Random random = new Random();
        for(Process process : refString2){
            Processor processor = processors.get(random.nextInt(processors.size()));
            processor.countPowerLevel();
            if(processor.getPowerLevel() > p){
                Collections.shuffle(processors2);
                for(Processor processor2 : processors2){
                    processor2.countPowerLevel();
                    if(processor2.getPowerLevel() <= p){
                        processor.migrate();
                        processor = processor2;
                        break;
                    }
                    //else processors2.remove(processor2); //can i do this???
                }
            }
            processor.addProcess(process);

            for(Processor processor1 : processors){
                //System.out.println(processor1);
                processor1.countPowerLevel();
                if(processor1.getPowerLevel() < r){
                    Collections.shuffle(processors2);
                    for(Processor processor2 : processors2){
                        processor2.countPowerLevel();
                        if(processor2.getPowerLevel() > p){
                            processor.migrate();
                            while(processor2.getPowerLevel() > (1 - takePercent)) {
                                processor1.addProcess(processor2.removeRandomProcess());
                            }
                            break;
                        }
                        //else processors2.remove(processor2); //can i do this???
                    }
                }
            }
            for(Processor processor1 : processors){
                processor1.nextTime(process.timeToNext);
            }
        }
        showResults("[Strategy 3]", processors);
    }
    public static void showResults(String stratName, ArrayList<Processor> processors){
        System.out.println("\n" + stratName + "\n");
        float avPowerLevel = 0;
        float a1 = 0;
        float a2 = 0;
        double a3 = 0;
        int a4 = 0;
        for(Processor processor : processors){
            //System.out.println(processor.toString());
            avPowerLevel += processor.getAveragePowerLevel();
            a1 += processor.migrationCount;
            a2 += processor.powerLevelInquiryCount;
            a4 += processor.overFlowCount;
        }
        avPowerLevel /= processors.size();

        for(Processor processor : processors){
            a3 += Math.pow(processor.getAveragePowerLevel() - avPowerLevel, 2);
        }
        a3 /= (processors.size() - 1);
        a3 = Math.sqrt(a3);

        System.out.println("Srednie obciazenie: " + avPowerLevel + ", Odchylenie Standardowe: " + a3 + ", Migracje: " + a1 + ", Zapytania: " + a2 + ", Odrzucone procesy: " + a4);
    }
    //public final static int maxTime = 1000;
    public static void main(String[] args) {
        float p = .6f; //maksymalny prog po ktorym za duze obciazenie [0,1], gdzie 1 to max
        float r = .2f; //minimalny próg... od 0 do 1
        int z = 10; //ilosc wyszukan losowego procka w strat1
        int N = 100; //ilosc procesorow
        int maxPower = 100; //maksymalna pojemnosc kazdego procesora

        int minPowerConsumption = 90; //minimalny pobor mocy procesu
        int maxPowerConsumption = 100; //maksymalny pobor mocy procesu
        int minTime = 100; //minimalny czas trwania wykonania procesu
        int maxTime = 240; //maksymalny czas trwania wykonania procesu
        int minTimeToNext = 1; //minimalny czas pomiedzy procesami
        int maxTimeToNext = 5; //maksymalny czas pomiedzy procesami
        float takePercent = .3f; //procent zadan ktore przejmuje proces w strat3

        ArrayList<Process> refString = generateReferenceString(1000, minPowerConsumption, maxPowerConsumption, minTime, maxTime, minTimeToNext, maxTimeToNext);
        System.out.println(refString);
        Strategy1(refString, N, p, z, maxPower);
        Strategy2(refString, N, p, maxPower);
        Strategy3(refString, N, p, r, takePercent, maxPower);
    }
}
