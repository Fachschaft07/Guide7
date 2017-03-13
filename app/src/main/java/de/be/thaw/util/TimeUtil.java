package de.be.thaw.util;

import java.text.SimpleDateFormat;
import java.util.Calendar;

/**
 * Created by Benjamin Eder on 23.02.2017.
 */

public class TimeUtil {

	private static final SimpleDateFormat dateFormat = new SimpleDateFormat("EEEE - dd. MMM yyyy");
	private static final SimpleDateFormat timeFormat = new SimpleDateFormat("HH:mm");

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

}
