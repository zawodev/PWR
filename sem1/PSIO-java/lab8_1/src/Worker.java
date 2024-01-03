import java.util.Arrays;

public class Worker extends Person{
    private String position;
    private int salary;
/*
    public String getPosition() {
        return position;
    }

    public void setPosition(String position) {
        this.position = position;
    }

    public int getSalary() {
        return salary;
    }

    public void setSalary(int salary) {
        this.salary = salary;
    }

    public int getHourRate() {
        return hourRate;
    }

    public void setHourRate(int hourRate) {
        this.hourRate = hourRate;
    }

    public int[] getOverTime() {
        return overTime;
    }

    public void setOverTime(int[] overTime) {
        this.overTime = overTime;
    }
*/
    private int hourRate;
    private int overTime[];
    @Override
    public double Calculate(){
        int tSum = 0;
        if(overTime != null) for (int i = 0; i<6; i++){tSum += overTime[i];}
        return salary + (hourRate * tSum);
    }
    public Worker(){
        super();
        position = "brak";
        salary = 0;
        hourRate = 0;
        overTime = null;
    }
    public Worker(String surname, String pesel, String position, int salary, int hourRate){
        super(surname, pesel);
        this.position = position;
        this.salary = salary;
        this.hourRate = hourRate;

        overTime = new int[6];
        for(int i = 0; i<6; i++){
            overTime[i] = rand.nextInt(0, 5);
        }
    }
    @Override
    public String toString(){
        return "Worker: " + getSurname() + ", Pesel: " + getPesel() + ", [position=" + position + ", salary=" + salary + ", hourRate=" + hourRate + "]";
    }
    public void ShowOvertimeHours(){
        System.out.println(Arrays.toString(overTime));
    }
    public boolean isCashier(){
        return position == "Cashier";
    }
}
