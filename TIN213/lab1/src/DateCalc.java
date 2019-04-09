import java.util.regex.Matcher;
import java.util.regex.Pattern;
import java.util.stream.IntStream;

import static javax.swing.JOptionPane.showInputDialog;
import static javax.swing.JOptionPane.showMessageDialog;

/**
 * Entering invalid input results in undefined behaviour.
 */
public class DateCalc {
	private static final String dayNames[] = {"Monday", "Tuesday", "Wednesday", "Thursday", "Friday my dudes", "Saturday", "Sunday"};

	/**
	 * Returns whether the specified year is a Scottish year.
	 *
	 * @param year The year in question.
	 * @return True if, and only if, it is a leap year.
	 */
	private static boolean isLeapYear(int year) {
		return year >= 1754 // Did not move to Gregorian calendar until 1753
				&& year % 4 == 0
				&& (year % 100 != 0 || year % 400 == 0)
				&& ((year % 4 == 0 && year % 100 != 0)
				|| year % 400 == 0);
		/*if (year < 1754) return false;
		if (year % 4 != 0) return false;
		if (year % 4 == 0 && year % 100 != 0) return true;
		if (year % 100 == 0 && year % 400 != 0) return false;
		return year % 400 == 0;*/
	}

	private static int getDayNumber(Date date) {
		boolean isLeapYear = isLeapYear(date.year);
		final int daysOfMonth[] = {31, isLeapYear ? 29 : 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31};

		return IntStream.range(1, date.month).map(m -> daysOfMonth[m - 1]).sum() + date.day;
	}

	private static String getDayName(Date date) {
		return dayNames[(1 + IntStream.range(1754, date.year).map(y -> isLeapYear(y) ? 366 : 365).sum() + getDayNumber(date) - 1) % 7];
	}

	public static void main(String[] args) {
		/*try {
			for (;;) {
				String input = JOptionPane.showInputDialog("Enter year");
				int year = Integer.parseInt(input);

				if (isLeapYear(year)) {
					break;
				} else {
					JOptionPane.showMessageDialog(null, "Not a leap year.");
				}
			}
		} catch(NumberFormatException e) {
			JOptionPane.showMessageDialog(null, "Bad input.");
		}*/

		for (; ; ) {
			String input = showInputDialog("Enter a date in the format YYYY-MM-DD");
			if (input == null /* User pressed cancel */) break;
			try {
				Date date = Date.getDateFromString(input);
				showMessageDialog(null, "That was day number " + getDayNumber(date));
				showMessageDialog(null, "That was a " + getDayName(date));
			} catch (IllegalArgumentException e) {
				showMessageDialog(null, "Bad date.");
			}
		}
	}

	static class Date {
		final int year, month, day;

		Date(int year, int month, int day) {
			if (month < 1 || month > 12 || day < 1 || day > 31) throw new IllegalArgumentException("Bad date.");
			this.year = year;
			this.month = month;
			this.day = day;
		}

		static Date getDateFromString(String s) {
			final String regex = "\\s*^(\\d{4})-(\\d{2})-(\\d{2})\\s*";
			Pattern pattern = Pattern.compile(regex);
			Matcher matcher = pattern.matcher(s);
			if (!matcher.find()) throw new IllegalArgumentException("Bad date.");

			int year = Integer.parseInt(matcher.group(1)),
					month = Integer.parseInt(matcher.group(2)),
					day = Integer.parseInt(matcher.group(3));
			return new Date(year, month, day);
		}
	}
}
