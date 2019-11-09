import biweekly.Biweekly;
import biweekly.ICalendar;
import biweekly.component.VEvent;
import biweekly.property.Summary;
import com.google.api.client.auth.oauth2.Credential;
import com.google.api.client.extensions.java6.auth.oauth2.AuthorizationCodeInstalledApp;
import com.google.api.client.extensions.jetty.auth.oauth2.LocalServerReceiver;
import com.google.api.client.googleapis.auth.oauth2.GoogleAuthorizationCodeFlow;
import com.google.api.client.googleapis.auth.oauth2.GoogleClientSecrets;
import com.google.api.client.googleapis.javanet.GoogleNetHttpTransport;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.JsonFactory;
import com.google.api.client.json.jackson2.JacksonFactory;
import com.google.api.client.util.store.FileDataStoreFactory;
import com.google.api.services.sheets.v4.Sheets;
import com.google.api.services.sheets.v4.SheetsScopes;
import com.google.api.services.sheets.v4.model.ValueRange;

import java.io.*;
import java.security.GeneralSecurityException;
import java.time.DayOfWeek;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.time.ZoneId;
import java.util.*;
import java.util.regex.Pattern;
import java.util.stream.Collector;
import java.util.stream.Collectors;

public class SheetsToCalendar {
    private static final String APPLICATION_NAME = "TIN213 Schema To iCal Application";
    private static final JsonFactory JSON_FACTORY = JacksonFactory.getDefaultInstance();
    private static final String TOKENS_DIRECTORY_PATH = "tokens";

    /**
     * Global instance of the scopes required by this program.
     * If modifying these scopes, delete your previously saved tokens/ folder.
     */
    private static final List<String> SCOPES = Collections.singletonList(SheetsScopes.SPREADSHEETS_READONLY);
    private static final String CREDENTIALS_FILE_PATH = "/credentials.json";
    /**
     * Room names for the three rooms used for computer laborations.
     */
    private static final String[] roomNames = {"7203", "7204", "4011"};
    private static final String[] fridayRoomNames = {"(1)", "(2)"};
    private static final int[] hours = {8, 10, 13, 15};

    /**
     * Creates an authorized Credential object.
     *
     * @param HTTP_TRANSPORT The network HTTP Transport.
     * @return An authorized Credential object.
     * @throws IOException If the credentials.json file cannot be found.
     */
    private static Credential getCredentials(final NetHttpTransport HTTP_TRANSPORT) throws IOException {
        // Load client secrets.
        InputStream in = SheetsToCalendar.class.getResourceAsStream(CREDENTIALS_FILE_PATH);
        if (in == null) {
            throw new FileNotFoundException("Resource not found: " + CREDENTIALS_FILE_PATH);
        }
        GoogleClientSecrets clientSecrets = GoogleClientSecrets.load(JSON_FACTORY, new InputStreamReader(in));

        // Build flow and trigger user authorization request.
        GoogleAuthorizationCodeFlow flow = new GoogleAuthorizationCodeFlow.Builder(
                HTTP_TRANSPORT, JSON_FACTORY, clientSecrets, SCOPES)
                .setDataStoreFactory(new FileDataStoreFactory(new java.io.File(TOKENS_DIRECTORY_PATH)))
                .setAccessType("offline")
                .build();
        LocalServerReceiver receiver = new LocalServerReceiver.Builder().setPort(8888).build();
        return new AuthorizationCodeInstalledApp(flow, receiver).authorize("user");
    }

    private static List<LocalDate> parseWeekDates(List<Object> row) {
        var datePattern = Pattern.compile("(?:mån|tis|ons|tors|fre) (?<day>\\d{1,2})/(?<month>\\d{1,2})");
        return row.stream().skip(1).filter(x -> x instanceof String && !((String) x).isEmpty()).map(x -> {
            var matcher = datePattern.matcher(x.toString());
            if (!matcher.matches()) throw new AssertionError("Bad date format");
            int day = Integer.parseInt(matcher.group("day")), month = Integer.parseInt(matcher.group("month"));
            return LocalDate.of(LocalDate.now().getYear(), month, day);
        }).collect(Collectors.toList());
    }

    private static List<Shift> parseWeek(Iterator<List<Object>> values) {
        var dates = parseWeekDates(values.next());
        assert dates.size() == 5 : "Bad number of weekdays";

        var shifts = new ArrayList<Shift>();
        for (int i = 0; i < 4; ++i) {
            var row = values.next();
            var startHour = hours[i];
            for (int j = 0; j < row.size() - 1; ++j) {
                var cell = row.get(1 + j);
                var roomIndex = j % 3;
                var date = dates.get(j / 3);

                if (cell instanceof String && !((String) cell).isEmpty()) {
                    LocalDateTime start = date.atTime(startHour, 0),
                            end = start.plusHours(2);
                    var room = (start.getDayOfWeek() == DayOfWeek.FRIDAY ? fridayRoomNames : roomNames)[roomIndex];
                    shifts.add(new Shift((String) cell, room, start, end));
                }
            }
        }

        // Merge shifts
        @SuppressWarnings("Convert2Diamond") final Collector<Shift, ?, List<Shift>> shiftMergingCollector = Collectors.reducing(new ArrayList<>(),
                shift -> new ArrayList<Shift>() {{
                    add(shift);
                }},
                (a, b) -> {
                    assert b.size() == 1;
                    var list = new ArrayList<>(a);
                    Shift lastA = list.isEmpty() ? null : list.get(list.size() - 1), lastB = b.get(0);
                    if (lastA != null && lastA.person.equals(lastB.person) && lastA.end.equals(lastB.start))
                        lastA.end = lastB.end;
                    else
                        list.addAll(b);
                    return list;
                });
        var shiftsByWeekday = shifts.stream().collect(Collectors.groupingBy(Shift::getDayOfWeek, Collectors.groupingBy(Shift::getRoom, shiftMergingCollector)));

        return shiftsByWeekday.values().stream().flatMap(x -> x.values().stream()).flatMap(Collection::stream).collect(Collectors.toList());
    }

    private static Date convertLocalDateTimeToDate(LocalDateTime t) {
        return Date.from(t.atZone(ZoneId.systemDefault()).toInstant());
    }

    /**
     * Extracts schedule from the spreadsheet:
     * https://docs.google.com/spreadsheets/d/1OFd0Syt-iDuZFne1ftm3TKPg3I7aP_rM5S1P2h5jdEY/edit
     */
    public static void main(String... args) throws IOException, GeneralSecurityException {
        // Build a new authorized API client service.
        final NetHttpTransport HTTP_TRANSPORT = GoogleNetHttpTransport.newTrustedTransport();
        final String spreadsheetId = "1OFd0Syt-iDuZFne1ftm3TKPg3I7aP_rM5S1P2h5jdEY";
        final String range = "schema!A2:P";
        Sheets service = new Sheets.Builder(HTTP_TRANSPORT, JSON_FACTORY, getCredentials(HTTP_TRANSPORT))
                .setApplicationName(APPLICATION_NAME)
                .build();
        ValueRange response = service.spreadsheets().values()
                .get(spreadsheetId, range)
                .execute();
        List<List<Object>> values = response.getValues();
        if (values == null || values.isEmpty()) {
            System.out.println("No data found.");
        } else {
            var it = values.iterator();
            var shifts = new ArrayList<Shift>();
            // For all the seven LV:s
            for (int i = 0; i < 7; ++i) {
                shifts.addAll(parseWeek(it));
                if (it.hasNext()) it.next(); // Skip empty separator row
            }

            if (args.length >= 1) {
                var person = args[0];
                shifts.removeIf(x -> !x.person.equals(person));
            }

            var ical = new ICalendar();
            for (var shift : shifts) {
                VEvent event = new VEvent();
                Summary summary = event.setSummary(String.format("TIN213 Övning m %s", shift.person));
                summary.setLanguage("sv-se");
                event.setLocation(shift.room);
                event.setDateStart(convertLocalDateTimeToDate(shift.start));
                event.setDateEnd(convertLocalDateTimeToDate(shift.end));
                ical.addEvent(event);
            }
            String str = Biweekly.write(ical).go();
            System.out.println(str);
            Biweekly.write(ical).go(new File("output.ical"));
        }
    }
}
