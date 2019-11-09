import java.time.DayOfWeek;
import java.time.LocalDateTime;
import java.util.Calendar;
import java.util.Date;

public class Shift {
    String person;
    String room;
    LocalDateTime start, end;

    public Shift(String person, String room, LocalDateTime start, LocalDateTime end) {
        this.person = person;
        this.room = room;
        this.start = start;
        this.end = end;
    }

    public DayOfWeek getDayOfWeek() {
        return start.getDayOfWeek();
    }

    public String getRoom() {
        return room;
    }
}
