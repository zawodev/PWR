import java.util.ArrayList;
import java.time.LocalDateTime;
import java.util.List;

public class Doctor {
    private String name;
    private List<Appointment> appointments;

    public Doctor(String name) {
        this.name = name;
        this.appointments = new ArrayList<>();
    }

    public String getName() {
        return name;
    }

    public List<Appointment> getAppointments() {
        return appointments;
    }

    public void addAppointment(Appointment appointment) {
        appointments.add(appointment);
    }

    public boolean isOccupied(LocalDateTime time) {
        for (Appointment appointment : appointments) {
            if (!time.isBefore(appointment.getStartTime()) && !time.isAfter(appointment.getEndTime())) {
                return true;
            }
        }
        return false;
    }

    public boolean checkConflict(Appointment newAppointment) {
        for (Appointment appointment : appointments) {
            if (appointment.conflictsWith(newAppointment)) {
                return true;
            }
        }
        return false;
    }
}
