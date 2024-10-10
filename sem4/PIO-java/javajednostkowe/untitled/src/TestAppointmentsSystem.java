import org.junit.Before;
import org.junit.Test;
import java.util.ArrayList;
import java.util.List;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import static org.junit.Assert.*;

public class TestAppointmentsSystem {

    private Patient pat1, pat2, pat3, pat4, pat5;
    private Doctor doc1, doc2, doc3, doc4, doc5;
    private AppointmentsSystem system;

    @Before
    public void setUp() {
        pat1 = new Patient("Michał Białko", "231798543", "05012400101");
        pat2 = new Patient("Andrzej Nowa", "234533122", "04011452120");
        pat3 = new Patient("Anna Zuzanna", "666020123", "03201453333");
        pat4 = new Patient("Hanna Wanna", "657402022", "02210454244");
        pat5 = new Patient("Michał Warczeński", "981293003", "06217455005");

        doc1 = new Doctor("Janusz Wieluński");
        doc2 = new Doctor("Andrzej Walaski");
        doc3 = new Doctor("Jan Parawan");
        doc4 = new Doctor("Jan Kran");
        doc5 = new Doctor("Józef Maria Halinka");

        //testujemy polski język

        system = new AppointmentsSystem();

        system.addDoctor(doc1);
        system.addDoctor(doc2);
        system.addDoctor(doc3);
        system.addDoctor(doc4);
        system.addDoctor(doc5);
        system.addPatient(pat1);
        system.addPatient(pat2);
        system.addPatient(pat3);
        system.addPatient(pat4);
        system.addPatient(pat5);

        List<Appointment> visits = new ArrayList<>();
        visits.add(new Appointment(pat1, doc1, "2024-06-18 15:00", "0:30", "kontrola"));
        visits.add(new Appointment(pat2, doc2, "2024-06-18 15:35", "0:25", "wizyta kontrolna"));
        visits.add(new Appointment(pat3, doc3, "2024-06-18 17:15", "0:15", "badanie serca"));
        visits.add(new Appointment(pat2, doc1, "2024-06-19 15:45", "0:30", "badanie krwi"));
        visits.add(new Appointment(pat2, doc3, "2024-06-19 12:15", "0:30", "kontrola"));

        for (Appointment a : visits) {
            system.addAppointment(a);
        }
    }

    @Test
    public void testConfirmAppointment() {
        assertTrue(system.confirmAppointment(1));
        assertTrue(system.confirmAppointment(3));
    }

    @Test
    public void testGetAppByCriterion() {
        DateTimeFormatter formatter = DateTimeFormatter.ofPattern("yyyy-MM-dd HH:mm");
        List<Appointment> testList1 = system.getAppByCriterion(LocalDateTime.parse("2024-06-18 00:00", formatter), null, pat1, null);
        List<Appointment> testList2 = system.getAppByCriterion(LocalDateTime.parse("2024-06-18 14:00", formatter), LocalDateTime.parse("2024-06-18 18:00", formatter), null, null);
        assertEquals(1, testList1.size());
        assertEquals(3, testList2.size());
    }

    @Test
    public void testRemoveAppointment() {
        assertTrue(system.removeAppointment(null, 2));
        assertTrue(system.removeAppointment(null, 0));
    }

    @Test
    public void testEditAppointment() {
        assertTrue(system.editAppointment(1, "2024-06-18 16:15", "0:35"));
        assertTrue(system.editAppointment(2, "2024-06-19 11:15", "0:25"));
    }
}
