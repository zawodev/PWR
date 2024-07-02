import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class AppointmentsSystem {
    private List<Patient> patients;
    private List<Doctor> doctors;
    private List<Appointment> appointments;

    public AppointmentsSystem() {
        this.patients = new ArrayList<>();
        this.doctors = new ArrayList<>();
        this.appointments = new ArrayList<>();
    }

    public void addPatient(Patient patient) {
        patients.add(patient);
    }

    public void addDoctor(Doctor doctor) {
        doctors.add(doctor);
    }

    public void addAppointment(Appointment appointment) {
        appointments.add(appointment);
    }

    public boolean removeAppointment(Appointment appointment, Integer index) {
        if (appointment != null) {
            if (appointment.isConfirmed()) {
                throw new IllegalArgumentException("Wizyta jest już potwierdzona");
            } else {
                appointments.remove(appointment);
                return true;
            }
        } else {
            if (index != null) {
                if (appointments.get(index).isConfirmed()) {
                    throw new IllegalArgumentException("Wizyta jest już potwierdzona");
                } else {
                    appointments.remove((int) index);
                    return true;
                }
            }
        }
        return false;
    }

    public boolean confirmAppointment(int index) {
        appointments.get(index).confirm();
        return true;
    }

    public List<Appointment> getAppByCriterion(LocalDateTime startTime, LocalDateTime endTime, Patient patient, Doctor doctor) {
        List<Appointment> result = new ArrayList<>();
        for (Appointment appointment : appointments) {
            if (startTime != null && appointment.getStartTime().isBefore(startTime)) {
                continue;
            }
            if (endTime != null && appointment.getStartTime().isAfter(endTime)) {
                continue;
            }
            if (patient != null && !appointment.getPatient().equals(patient)) {
                continue;
            }
            if (doctor != null && !appointment.getDoctor().equals(doctor)) {
                continue;
            }
            result.add(appointment);
        }
        return result;
    }

    public boolean editAppointment(int index, String newTime, String newDuration) {
        appointments.get(index).editTime(newTime, newDuration);
        return true;
    }
}
