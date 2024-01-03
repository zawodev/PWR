public class Bank {
    public static Person [] P;
    public static int n;
    public static void main(String args[]){
        //zad1
        System.out.println("ZAD 1");
        n = 9;
        P = new Person[20];
        P[0] = new Client();
        P[1] = new Worker();
        P[2] = new Client("Kowalski", "010101010", 2);
        P[3] = new Worker("Jowalski", "650696932", "Cashier", 300, 50);
        P[4] = new Worker();
        P[5] = new Worker("Abażurek", "432425266", "Manager", 100, 10);
        P[6] = new Client();
        P[7] = new Client("Cegiełka", "333333333", 3);
        P[8] = new Worker("Kubacicz", "215456764", "Cashier", 500, 30);

        //zad2
        System.out.println("\nZAD 2");
        for (int i = 0; i<n; i++){
            System.out.println(P[i].toString());
        }

        //zad3
        System.out.println("\nZAD 3");
        for (int i = 0; i<n; i++){
            if(P[i] instanceof Worker){
                System.out.println(P[i].toString());
                ((Worker)P[i]).ShowOvertimeHours();
            }
        }

        //zad4
        System.out.println("\nZAD 4");
        for (int i = 0; i<n; i++){
            if(P[i] instanceof Client){
                System.out.println(P[i].toString());
                ((Client)P[i]).ShowDeposits();
                System.out.print("\n");
            }
        }

        //zad5
        System.out.println("ZAD 5");
        int cashierNum = 0;
        for (int i = 0; i<n; i++){
            if(P[i] instanceof Worker && ((Worker)P[i]).isCashier()){
                cashierNum++;
            }
        }
        System.out.println(cashierNum);

        //zad6
        System.out.println("\nZAD 6");
        Worker bestWorker = null;
        for (int i = 0; i<n; i++){
            if(P[i] instanceof Worker){
                if(bestWorker == null) bestWorker = (Worker)P[i];
                if(P[i].Calculate() > bestWorker.Calculate()) {
                    bestWorker = (Worker) P[i];
                }
            }
        }
        if(bestWorker != null) System.out.println(bestWorker.toString() + ", Earned: " + bestWorker.Calculate());
    }
}
