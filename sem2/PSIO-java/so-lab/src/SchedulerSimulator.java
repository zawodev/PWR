import java.util.*;

public class SchedulerSimulator {
    private static class Process {
        int id; // numer procesu
        int burstTime; // czas trwania procesu
        int arrivalTime; // czas przyjścia procesu do systemu
        int waitingTime; // czas oczekiwania na wykonanie
        int remainingTime; // pozostały czas do wykonania
        int turnaroundTime; // czas wykonania procesu
        boolean started; // czy proces został rozpoczęty
        boolean executed; // czy proces został wykonany

        public Process(int id, int burstTime, int arrivalTime) {
            this.id = id;
            this.burstTime = burstTime;
            this.arrivalTime = arrivalTime;
            this.waitingTime = 0;
            this.remainingTime = burstTime;
            this.turnaroundTime = 0;
            this.executed = false;
            this.started = false;
        }
        public int Execute(int currentTime){
            waitingTime = currentTime - arrivalTime;
            turnaroundTime = waitingTime + burstTime;
            currentTime += burstTime;
            remainingTime = 0;
            executed = true;
            return currentTime;
        }
        public String ToString(){
            return "id: " + id + ", burstTime: " + burstTime + ", arrivalTime: " + arrivalTime + ", waitingTime: " + waitingTime + ", remainingTime: " + remainingTime + ", turnaroundTime: " + turnaroundTime + ", executed: " + executed + ", started: " + started;
        }
    }
    private static List<Process> generateProcesses(int n, int maxBurstTime, int maxArrivalTime) {
        List<Process> processes = new ArrayList<>();
        Random random = new Random();
        for (int i = 1; i <= n; i++) {
            int burstTime = random.nextInt(maxBurstTime) + 1;
            int arrivalTime = random.nextInt(maxArrivalTime) + 1;
            processes.add(new Process(i, burstTime, arrivalTime));
        }
        return processes;
    }
    private static List<Process> generateTestProcesses() {
        List<Process> processes = new ArrayList<>();
        /*processes.add(new Process(1, 5, 0));
        processes.add(new Process(2, 3, 1));
        processes.add(new Process(3, 6, 3));
        processes.add(new Process(4, 1, 5));
        processes.add(new Process(5, 4, 6));*/

        processes.add(new Process(1, 1, 0));
        processes.add(new Process(2, 3, 3));
        processes.add(new Process(3, 6, 3));
        processes.add(new Process(4, 1, 5));
        processes.add(new Process(5, 4, 6));
        return processes;
    }
    private static int scheduleFCFS(List<Process> processes) {
        int currentTime = 0;
        for (Process process : processes) {
            if (process.arrivalTime > currentTime) {
                currentTime = process.arrivalTime;
            }
            currentTime = process.Execute(currentTime);
        }
        return currentTime;
    }
    private static int scheduleSJF(List<Process> processes) {
        int currentTime = 0;
        int i = -1;
        List<Process> queue = new ArrayList<>();
        while(i < processes.size() || !queue.isEmpty()){
            if(!queue.isEmpty()){
                Collections.sort(queue, Comparator.comparingInt(p -> p.burstTime));
                Process process = queue.get(0);
                currentTime = process.Execute(currentTime);
                //System.out.println(queue.size());
                queue.remove(0);
                for (Process _process : processes) {
                    if(_process.arrivalTime <= currentTime && !_process.executed) {
                        queue.add(_process);
                        i++;
                    }
                    else{
                        if(queue.contains(process))queue.remove(process);
                    }
                }
            }
            else if(i < processes.size()){
                i++;
                Process process = processes.get(i);
                if(!process.executed) {
                    queue.add(process);
                    currentTime = process.arrivalTime;
                }
            }
        }

        return currentTime;
    }
    private static int scheduleSJFPreemptive(List<Process> processes) {
        int currentTime = processes.get(0).arrivalTime;
        int executedIndex = 0;
        List<Process> queue = new ArrayList<>();
        Process currentProcess = null;
        while (executedIndex < processes.size()) {
            for (Process process : processes) {
                if (process.arrivalTime <= currentTime && !process.executed && (currentProcess == null || process.burstTime < currentProcess.burstTime)) {
                    if (currentProcess != null) {
                        queue.add(currentProcess);
                    }
                    currentProcess = process;
                }
            }
            if (currentProcess == null) {
                currentTime++;
                if(currentTime > 10000) break; //tak zeby sie nie robiło w nieskonczonosc w razie bledu
            }
            else {
                currentProcess.remainingTime--;
                if (currentProcess.remainingTime == 0) {
                    currentProcess.waitingTime = currentTime - currentProcess.arrivalTime - currentProcess.burstTime + 1;
                    currentProcess.turnaroundTime = currentProcess.waitingTime + currentProcess.burstTime;
                    currentProcess.executed = true;
                    executedIndex++;
                    currentProcess = null;
                }
                currentTime++;
                if (!queue.isEmpty() && currentProcess == null) {
                    Collections.sort(queue, Comparator.comparingInt(p -> p.burstTime));
                    currentProcess = queue.get(0);
                    queue.remove(0);
                }
            }
        }
        return currentTime;
    }
    private static int scheduleRR(List<Process> processes, int timeQuant) {
        int currentTime = processes.get(0).arrivalTime;
        int executedIndex = 0;
        Process prevProcess = null;
        Queue<Process> roundRobinQueue = new LinkedList<>();
        do{
            for (Process process : processes) {
                if (process.arrivalTime <= currentTime && !process.started) {
                    roundRobinQueue.add(process);
                    process.started = true;
                }
            }
            if (prevProcess != null) roundRobinQueue.add(prevProcess);
            prevProcess = null;
            if (!roundRobinQueue.isEmpty()) {
                Process currentProcess = roundRobinQueue.poll();
                //System.out.println(currentProcess.id + " " + currentTime);
                if (currentProcess.remainingTime <= timeQuant) {
                    currentProcess.waitingTime = Integer.max(0, currentTime - currentProcess.arrivalTime);
                    currentProcess.turnaroundTime = currentProcess.waitingTime + currentProcess.burstTime;
                    currentProcess.executed = true;
                    executedIndex++;
                    currentTime += currentProcess.remainingTime;
                    currentProcess.remainingTime = 0;

                } else {
                    currentProcess.remainingTime -= timeQuant;
                    prevProcess = currentProcess;
                    currentTime += timeQuant;
                }
            }
            else currentTime++;
        }
        while (!roundRobinQueue.isEmpty() || executedIndex < processes.size());

        return currentTime;
    }

    public static void main(String[] args) {


        int n = 10; //50
        int maxBurstTime = 20;//20
        int maxArrivalTime = 20;//20
        int timeQuant = 21;

        List<Process> processes = generateProcesses(n, maxBurstTime, maxArrivalTime);
        //List<Process> processes = generateTestProcesses();
        System.out.println("\n==================================\n");
        Collections.sort(processes, Comparator.comparingInt(p -> p.arrivalTime));
        for (Process process : processes) System.out.println(process.ToString());
        System.out.println("\n==================================\n");

        List<Process> fcfsProcesses = new ArrayList<>();
        for(Process process : processes) fcfsProcesses.add(new Process(process.id, process.burstTime, process.arrivalTime));
        //Collections.sort(fcfsProcesses, Comparator.comparingInt(p -> p.arrivalTime));
        List<Process> sfjProcesses = new ArrayList<>();
        for(Process process : processes) sfjProcesses.add(new Process(process.id, process.burstTime, process.arrivalTime));
        //Collections.sort(sfjProcesses, Comparator.comparingInt(p -> p.arrivalTime));
        List<Process> sjfPreemptiveProcesses = new ArrayList<>();
        for(Process process : processes) sjfPreemptiveProcesses.add(new Process(process.id, process.burstTime, process.arrivalTime));
        //Collections.sort(sjfPreemptiveProcesses, Comparator.comparingInt(p -> p.arrivalTime));
        List<Process> rrProcesses = new ArrayList<>();
        for(Process process : processes) rrProcesses.add(new Process(process.id, process.burstTime, process.arrivalTime));



        double fcfsFinalTime = scheduleFCFS(fcfsProcesses);
        double fcfsAverageWaitingTime = 0;
        for (Process process : fcfsProcesses) {
            System.out.println(process.ToString());
            fcfsAverageWaitingTime += process.waitingTime;
        }
        fcfsAverageWaitingTime /= n;
        System.out.println("Algorytm FCFS: średni czas oczekiwania = " + fcfsAverageWaitingTime);
        System.out.println("Algorytm FCFS: czas wykonania wszystkich procesów = " + fcfsFinalTime);
        System.out.println("\n==================================\n");




        double sfjFinalTime = scheduleSJF(sfjProcesses);
        double sjfAverageWaitingTime = 0;
        for (Process process : sfjProcesses) {
            System.out.println(process.ToString());
            sjfAverageWaitingTime += process.waitingTime;
        }
        sjfAverageWaitingTime /= n;
        System.out.println("Algorytm SJF bez wywłaszczania: średni czas oczekiwania = " + sjfAverageWaitingTime);
        System.out.println("Algorytm SJF bez wywłaszczania: czas wykonania wszystkich procesów = " + sfjFinalTime);
        System.out.println("\n==================================\n");




        double sfjPreemptiveFinalTime = scheduleSJFPreemptive(sjfPreemptiveProcesses);
        double sjfPreemptiveAverageWaitingTime = 0;
        for (Process process : sjfPreemptiveProcesses) {
            System.out.println(process.ToString());
            sjfPreemptiveAverageWaitingTime += process.waitingTime;
        }
        sjfPreemptiveAverageWaitingTime /= n;
        System.out.println("Algorytm SJF z wywłaszczaniem: średni czas oczekiwania = " + sjfPreemptiveAverageWaitingTime);
        System.out.println("Algorytm SJF z wywłaszczaniem: czas wykonania wszystkich procesów = " + sfjPreemptiveFinalTime);
        System.out.println("\n==================================\n");



        double rrFinalTime = scheduleRR(rrProcesses, timeQuant);
        double rrAverageWaitingTime = 0;
        for (Process process : rrProcesses) {
            System.out.println(process.ToString());
            rrAverageWaitingTime += process.waitingTime;
        }
        rrAverageWaitingTime /= n;
        System.out.println("Algorytm rotacyjny z wyborem kwantu czasu: średni czas oczekiwania = " + rrAverageWaitingTime);
        System.out.println("Algorytm rotacyjny z wyborem kwantu czasu: czas wykonania wszystkich procesów " + rrFinalTime);
    }
}