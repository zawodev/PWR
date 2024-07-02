import java.time.LocalDateTime;
import java.time.Duration;
import java.time.format.DateTimeFormatter;

public class Appointment {
    private Patient patient;
    private Doctor doctor;
    private String description;
    private LocalDateTime startTime;
    private Duration duration;
    private LocalDateTime endTime;
    private boolean isConfirmed;

    public Appointment(Patient patient, Doctor doctor, String startTime, String duration, String description) {
        this.patient = patient;
        this.doctor = doctor;
        this.description = description;
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        this.startTime = LocalDateTime.parse(startTime, formatter);
        String[] durationParts = duration.split(":");
        this.duration = Duration.ofHours(Integer.parseInt(durationParts[0])).plusMinutes(Integer.parseInt(durationParts[1]));
        this.endTime = this.startTime.plus(this.duration);
        this.isConfirmed = false;

        if (this.patient.checkConflict(this)) {
            throw new IllegalArgumentException("Pacjent już umówiony w tym terminie");
        }
        if (this.doctor.checkConflict(this)) {
            throw new IllegalArgumentException("Lekarz już umówiony w tym terminie");
        }
        this.doctor.addAppointment(this);
        this.patient.addAppointment(this);
    }

    public Patient getPatient() {
        return patient;
    }

    public Doctor getDoctor() {
        return doctor;
    }

    public String getDescription() {
        return description;
    }

    public LocalDateTime getStartTime() {
        return startTime;
    }

    public Duration getDuration() {
        return duration;
    }

    public LocalDateTime getEndTime() {
        return endTime;
    }

    public boolean isConfirmed() {
        return isConfirmed;
    }

    public void confirm() {
        if (isConfirmed) {
            throw new IllegalStateException("Wizyta już potwierdzona");
        }
        isConfirmed = true;
    }

    public boolean conflictsWith(Appointment other) {
        return !startTime.isAfter(other.endTime) && !endTime.isBefore(other.startTime);
    }

    public void editTime(String newStartTime, String newDuration) {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        LocalDateTime newStart = LocalDateTime.parse(newStartTime, formatter);
        String[] durationParts = newDuration.split(":");
        Duration newDur = Duration.ofHours(Integer.parseInt(durationParts[0])).plusMinutes(Integer.parseInt(durationParts[1]));

        if (isConfirmed) {
            throw new IllegalStateException("Wizyta już potwierdzona");
        }
        if (newStart.plusHours(72).isAfter(LocalDateTime.now())) {
            throw new IllegalArgumentException("Termin za blisko do zmiany");
        }
        if (doctor.isOccupied(newStart) || doctor.isOccupied(newStart.plus(newDur))) {
            throw new IllegalArgumentException("Lekarz już umówiony w tym terminie");
        }
        if (patient.isOccupied(newStart) || patient.isOccupied(newStart.plus(newDur))) {
            throw new IllegalArgumentException("Pacjent już umówiony w tym terminie");
        }
        this.startTime = newStart;
        this.duration = newDur;
        this.endTime = this.startTime.plus(this.duration);
    }

    @Override
    public String toString() {
        return String.format("Patient: %s\nDescription: %s\nStart time: %s\nDuration: %s\nEnd time: %s",
                patient.getName(), description, startTime, duration, endTime);
    }
}
