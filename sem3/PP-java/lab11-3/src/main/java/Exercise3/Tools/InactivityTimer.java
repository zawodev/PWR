package Exercise3.Tools;

import Exercise3.SudokuFactory;

import java.util.Timer;
import java.util.TimerTask;

public class InactivityTimer {
    public static InactivityTimer inactivityTimer;
    private final SudokuFactory sudokuMagazineFactory;
    private Timer timer;
    private double timeInSeconds;

    public InactivityTimer(SudokuFactory sudokuMagazineFactory, double timeInSeconds) {
        inactivityTimer = this;
        this.sudokuMagazineFactory = sudokuMagazineFactory;
        timer = new Timer();
        this.timeInSeconds = timeInSeconds;

        ResetInactivityTimer();
    }
    public synchronized void ResetInactivityTimer() {
        if (timer != null) {
            timer.cancel();
        }
        timer = new Timer();
        TimerTask task = new TimerTask() {
            @Override
            public void run() {
                sudokuMagazineFactory.Shutdown();
            }
        };
        long delay = (long) (timeInSeconds * 1000);
        timer.schedule(task, delay);
    }
}

