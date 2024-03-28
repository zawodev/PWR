import java.util.*;

public class DiscScheduler {
    public static class Process {
        private int pos;
        private int arrivalTime;
        private int deadlineTime;
        private int finalTime;
        public boolean isExecuted;
        public Process(int pos, int arrivalTime, int deadlineTime) {
            this.pos = pos;
            this.arrivalTime = arrivalTime;
            this.deadlineTime = deadlineTime;
            this.finalTime = deadlineTime + arrivalTime;
            this.isExecuted = false;
        }
        public Process(int pos) {
            this.pos = pos;
        }
        public String toString(){
            return "deadlineTime: " + deadlineTime + ", pos: " + pos + ", startTime: " + arrivalTime;
        }
    }

    public static class Disc {
        private ArrayList<Process> processes = new ArrayList();
        private int maxPos;

        public Disc(int n, int maxPos, int maxArrivalTime, int maxDeadlineTime) {
            Random random = new Random();
            this.maxPos = maxPos;
            for (int i = 0; i < n; i++) {
                add(new Process(random.nextInt(maxPos), random.nextInt(maxArrivalTime), random.nextInt(maxDeadlineTime)));
            }
        }

        public Disc() {
            add(new Process(11, 10, 41));
            add(new Process(34, 12, 150));
            add(new Process(41, 42, 160));
            add(new Process(50, 56, 32));
            add(new Process(60, 24, 63));
            add(new Process(79, 61, 85));
            add(new Process(92, 14, 91));
            add(new Process(114, 16, 14));
            add(new Process(176, 67, 11));

            //add(new Process(20, 1, 0));
            //add(new Process(10, 2, 0));
            //add(new Process(70, 3, 0));
            this.maxPos = 200;
        }

        public void add(Process d) {
            processes.add(d);
        }

        public void remove(Process d) {
            processes.remove(d);
        }

        public int FCFS(int headPos) {
            Collections.sort(processes, Comparator.comparingInt(p -> p.arrivalTime));
            int seekCount = 0;
            for (Process process : processes) {
                seekCount += Math.abs(process.pos - headPos);
                headPos = process.pos;
            }
            return seekCount;
        }

        public int SSTF(int headPos) {
            //ignores the arrival time tbh
            int seekCount = 0;
            List<Process> processesList = new ArrayList<>();
            for (Process process : processes) {
                processesList.add(process);
            }
            while (!processesList.isEmpty()) {
                int closestIndex = 0;
                for (int i = 1; i < processesList.size(); i++) {
                    if (Math.abs(processesList.get(i).pos - headPos) < Math.abs(processesList.get(closestIndex).pos - headPos)){
                        closestIndex = i;
                    }
                }
                seekCount += Math.abs(processesList.get(closestIndex).pos - headPos);
                headPos = processesList.get(closestIndex).pos;
                processesList.remove(closestIndex);
            }
            return seekCount;
        }

        public int SCAN(int headPos, boolean movesRight) {
            Collections.sort(processes, Comparator.comparingInt(p -> p.pos));
            int seekCount = 0;
            int rightIndex = -1;
            int leftIndex = -1;
            for (int i = 0; i < processes.size(); i++) {
                if (processes.get(i).pos < headPos) {
                    leftIndex = i;
                } else if (processes.get(i).pos > headPos) {
                    rightIndex = i;
                    break;
                }
            }
            if (movesRight) {
                if (leftIndex == -1) seekCount += Math.abs(headPos - processes.get(processes.size() - 1).pos);
                else seekCount += 2 * Math.abs(headPos - maxPos) + Math.abs(headPos - processes.get(0).pos);
            }
            if (!movesRight) {
                if (rightIndex == -1) seekCount += Math.abs(headPos - processes.get(0).pos);
                else
                    seekCount += 2 * Math.abs(headPos - 0) + Math.abs(headPos - processes.get(processes.size() - 1).pos);
            }
            return seekCount;
        }

        public int CSCAN(int headPos, boolean movesRight) {
            Collections.sort(processes, Comparator.comparingInt(p -> p.pos));
            int seekCount = 0;
            int rightIndex = -1;
            int leftIndex = -1;
            for (int i = 0; i < processes.size(); i++) {
                if (processes.get(i).pos < headPos) {
                    leftIndex = i;
                } else if (processes.get(i).pos > headPos) {
                    rightIndex = i;
                    break;
                }
            }
            if (movesRight) {
                if (leftIndex == -1) seekCount += Math.abs(headPos - processes.get(processes.size() - 1).pos);
                else seekCount += 2 * maxPos - Math.abs(headPos - processes.get(leftIndex).pos);
            }
            if (!movesRight) {
                if (rightIndex == -1) seekCount += Math.abs(headPos - processes.get(0).pos);
                else seekCount += 2 * maxPos - Math.abs(headPos - processes.get(rightIndex).pos);
            }

            return seekCount;
        }

        public int EDF(int headPos) {
            int seekCount = 0;
            List<Process> processesList = new ArrayList<>();
            for (Process process : processes) {
                processesList.add(process);
            }
            while (!processesList.isEmpty()) {
                int closestIndex = 0;
                for (int i = 1; i < processesList.size(); i++) {
                    if (processesList.get(i).finalTime < processesList.get(closestIndex).finalTime || (processesList.get(i).finalTime == processesList.get(closestIndex).finalTime && Math.abs(processesList.get(i).pos - headPos) < Math.abs(processesList.get(closestIndex).pos - headPos))) {
                        closestIndex = i;
                    }
                }
                seekCount += Math.abs(processesList.get(closestIndex).pos - headPos);
                //System.out.println(processesList.get(closestIndex).pos);
                headPos = processesList.get(closestIndex).pos;
                processesList.remove(closestIndex);
            }
            return seekCount;
        }

        public int FDSCAN(int headPos) {
            Collections.sort(processes, Comparator.comparingInt(p -> p.pos));
            int seekCount = 0;
            List<Process> processesList = new ArrayList<>();
            for (Process process : processes) {
                processesList.add(process);
            }
            while (!processesList.isEmpty()) {
                int closestIndex = 0;
                for (int i = 1; i < processesList.size(); i++) {
                    if (seekCount <= processesList.get(i).finalTime && processesList.get(i).finalTime < processesList.get(closestIndex).finalTime) {
                        closestIndex = i;
                    }
                }
                seekCount += Math.abs(processesList.get(closestIndex).pos - headPos);
                headPos = processesList.get(closestIndex).pos;
                processesList.remove(closestIndex);
            }
            return seekCount;
        }
    }
    public static void main(String[] args) {
        Disc disc;
        int totalSeekCount;
        int headPos = 50;

        disc = new Disc(200, 200, 200, 200);
        //disc = new Disc();

        totalSeekCount = disc.FCFS(headPos);
        System.out.println("FCFS: " + totalSeekCount);

        totalSeekCount = disc.SSTF(headPos);
        System.out.println("SSTF: " + totalSeekCount);

        totalSeekCount = disc.SCAN(headPos, false);
        System.out.println("SCAN: " + totalSeekCount);

        totalSeekCount = disc.CSCAN(headPos, true);
        System.out.println("CSCAN: " + totalSeekCount);

        totalSeekCount = disc.EDF(headPos);
        System.out.println("EDF: " + totalSeekCount);

        totalSeekCount = disc.FDSCAN(headPos);
        System.out.println("FDSCAN: " + totalSeekCount);
    }
}
