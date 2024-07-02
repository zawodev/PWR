import java.util.ArrayList;
import java.time.LocalDateTime;
import java.util.List;

public class Patient {
    private String name;
    private String phone;
    private String pesel;
    private List<Appointment> appointments;

    public Patient(String name, String phone, String pesel) {
        if (!phone.matches("\\d{9}")) {
            throw new IllegalArgumentException("Telefon nie w formacie");
        }
        if (!pesel.matches("\\d{11}")) {
            throw new IllegalArgumentException("Pesel nie w formacie");
        }
        this.name = name;
        this.phone = phone;
        this.pesel = pesel;
        this.appointments = new ArrayList<>();
    }

    public String getName() {
        return name;
    }

    public String getPhone() {
        return phone;
    }

    public String getPesel() {
        return pesel;
    }

    public List<Appointment> getAppointments() {
        return appointments;
    }

    public void addAppointment(Appointment appointment) {
        appointments.add(appointment);
    }

    public boolean checkConflict(Appointment newAppointment) {
        for (Appointment appointment : appointments) {
            if (appointment.conflictsWith(newAppointment)) {
                return true;
            }
        }
        return false;
    }

    public boolean isOccupied(LocalDateTime time) {
        for (Appointment appointment : appointments) {
            if (!time.isBefore(appointment.getStartTime()) && !time.isAfter(appointment.getEndTime())) {
                return true;
            }
        }
        return false;
    }
}
