package de.be.thaw.connect.parser;

import net.fortuna.ical4j.model.Calendar;
import net.fortuna.ical4j.model.Component;
import net.fortuna.ical4j.model.DateTime;
import net.fortuna.ical4j.model.Property;

import java.text.SimpleDateFormat;
import java.util.ArrayList;
import java.util.Date;
import java.util.List;

import org.jsoup.Jsoup;
import org.jsoup.nodes.Document;
import org.jsoup.nodes.Element;
import org.jsoup.safety.Whitelist;
import org.jsoup.select.Elements;

import de.be.thaw.connect.parser.exception.ParseException;
import de.be.thaw.model.schedule.Schedule;
import de.be.thaw.model.schedule.ScheduleDay;
import de.be.thaw.model.schedule.ScheduleItem;

/**
 * Parser parsing the week plan from ZPA.
 *
 * @author Benjamin Eder
 */
public class WeekPlanParser implements Parser<Calendar, List<ScheduleItem>> {

	/**
	 * Property containing the summary.
	 */
	private static final String SUMMARY_PROPERTY = "SUMMARY";

	/**
	 * Property containing the event start.
	 */
	private static final String START_PROPERTY = "DTSTART";

	/**
	 * Property containing the event end.
	 */
	private static final String END_PROPERTY = "DTEND";

	/**
	 * Property containing the event time stamp.
	 */
	private static final String TIMESTAMP_PROPERTY = "DTSTAMP";

	/**
	 * Property containing the events description.
	 */
	private static final String DESCRIPTION_PROPERTY = "DESCRIPTION";

	/**
	 * Property containing the events description.
	 */
	private static final String LOCATION_PROPERTY = "LOCATION";

	/**
	 * Property containing the events zpa url.
	 */
	private static final String URL_PROPERTY = "URL";

	/**
	 * Unique ID of a schedule item.
	 */
	private static final String UID_PROPERTY = "UID";

	/**
	 * String determining a special note.
	 */
	private static final String SPECIAL_NOTICE = "***";

	@Override
	public List<ScheduleItem> parse(Calendar calendar) throws ParseException {
		List<ScheduleItem> items = new ArrayList<>();

		for (Component component : calendar.getComponents()) {
			String summary = component.getProperty(SUMMARY_PROPERTY).getValue();
			String description = component.getProperty(DESCRIPTION_PROPERTY).getValue();
			String location = component.getProperty(LOCATION_PROPERTY).getValue();
			String start = component.getProperty(START_PROPERTY).getValue();
			String end = component.getProperty(END_PROPERTY).getValue();
			String timestamp = component.getProperty(TIMESTAMP_PROPERTY).getValue();
			String url = component.getProperty(URL_PROPERTY).getValue();
			String UID = component.getProperty(UID_PROPERTY).getValue();

			Date startDate = null;
			Date endDate = null;
			Date timestampDate = null;
			java.util.Calendar cal = java.util.Calendar.getInstance();
			try {
				cal.setTimeInMillis(new DateTime(start).getTime());
				startDate = cal.getTime();

				cal.setTimeInMillis(new DateTime(end).getTime());
				endDate = cal.getTime();

				cal.setTimeInMillis(new DateTime(timestamp).getTime());
				timestampDate = cal.getTime();
			} catch (java.text.ParseException e) {
				throw new ParseException(e);
			}

			boolean cancelled = false;
			if (summary.contains(SPECIAL_NOTICE)) {
				String notice = null;
				int index = summary.indexOf(SPECIAL_NOTICE);

				String tmp = summary.substring(index + SPECIAL_NOTICE.length());

				index = tmp.indexOf(SPECIAL_NOTICE);
				if (index != -1) {
					tmp = tmp.substring(0, index);

					notice = tmp.trim();
				}

				if (notice != null) {
					if (notice.contains("Fallt aus") || notice.contains("Fällt aus")) {
						cancelled = true;
					}
				}
			}

			ScheduleItem item = new ScheduleItem(summary, description, UID);

			item.setStart(startDate);
			item.setEnd(endDate);
			item.setTimestamp(timestampDate);

			item.setLocation(location);
			item.setUrl(url);

			item.setEventCancelled(cancelled);

			items.add(item);
		}

		return items;
	}

}
