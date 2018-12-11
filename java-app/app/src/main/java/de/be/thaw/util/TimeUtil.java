package de.be.thaw.util;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;

/**
 * Created by Benjamin Eder on 23.02.2017.
 */

public class TimeUtil {

	private static final DateFormat dateFormat = new SimpleDateFormat("EEEE - dd. MMM yyyy");
	private static final DateFormat shortDateFormat = new SimpleDateFormat("dd.MM.yyyy");
	private static final DateFormat timeFormat = new SimpleDateFormat("HH:mm");

	/**
	 * Get Calendar as String representation.
	 *
	 * @param cal
	 * @return
	 */
	public static String getDateString(Calendar cal) {
		return dateFormat.format(cal.getTime());
	}

	/**
	 * Get Calendar as Time representation.
	 *
	 * @param cal
	 * @return
	 */
	public static String getTimeString(Calendar cal) {
		return timeFormat.format(cal.getTime());
	}

	/**
	 * Get Calendar as String representation (in short form).
	 * @param cal
	 * @return
	 */
	public static String getShortDateString(Calendar cal) {
		return shortDateFormat.format(cal.getTime());
	}

}
