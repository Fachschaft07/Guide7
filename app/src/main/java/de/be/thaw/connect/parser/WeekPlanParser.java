package de.be.thaw.connect.parser;

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
public class WeekPlanParser implements Parser<WeekPlanParser.ScheduleResult> {

	/**
	 * Class for the Week Plan Table
	 */
	private static final String TABLE_PLAN_CLASS = "plan";
	
	/**
	 * Class for the Week Plan Tables Day Column
	 */
	private static final String TABLE_DAY_CLASS = "day";
	
	/**
	 * The class for an HTML items header.
	 */
	private static final String ITEM_HEADER_CLASS = "slot_header";
	
	/**
	 * The inner content of an item class.
	 */
	private static final String ITEM_CONTENT_CLASS = "slot_inner";

	public static final SimpleDateFormat DATE_PARSER = new SimpleDateFormat("dd.MM.yyyy");
	public static final SimpleDateFormat TIME_PARSER = new SimpleDateFormat("HH:mm");

	private static final String CANCEL_NOTICE = "Fällt aus";
	
	@Override
	public ScheduleResult parse(Document doc) throws ParseException {
		Element tableBody = getTableBodyElement(doc);
		Elements planDays = getPlanDays(tableBody);
		
		List<ScheduleDay> scheduleDays = new ArrayList<>();

		boolean parsedCompletely = true;

		for (int i = 0; i < planDays.size(); i++) {
			ScheduleDayResult result = parseDay(planDays.get(i));

			scheduleDays.add(result.getResult());

			if (!result.isParsedCompletely()) {
				parsedCompletely = false;
			}
		}
		
		return new ScheduleResult(parsedCompletely, new Schedule(scheduleDays.toArray(new ScheduleDay[scheduleDays.size()])));
	}
	
	/**
	 * Parse a HTML Day Element.
	 * @param dayElement
	 * @return
	 * @throws ParseException
	 */
	private ScheduleDayResult parseDay(Element dayElement) throws ParseException {
		Date date = getDateFromDayElement(dayElement);

		List<ScheduleItem> items = new ArrayList<>();

		Elements possibleItems = dayElement.getElementsByTag("div");

		boolean parsedCompletely = true;
		if (possibleItems != null && !possibleItems.isEmpty()) {
			for (int i = 0; i < possibleItems.size(); i++) {
				Element item = possibleItems.get(i);

				try {
					Elements possibleHeaders = item.getElementsByClass(ITEM_HEADER_CLASS);
					Elements possibleContents = item.getElementsByClass(ITEM_CONTENT_CLASS);

					if (!possibleHeaders.isEmpty() && !possibleContents.isEmpty()) {
						if (possibleHeaders.size() == 1 && possibleContents.size() == 1) {
							Element header = possibleHeaders.get(0);
							Element content = possibleContents.get(0);

							String headerText = getHeaderFromItemElement(header);
							String contentText = getContentFromItemElement(content);

							boolean isCancelled = false;

							if (headerText.contains(CANCEL_NOTICE)) {
								isCancelled = true;

								headerText = headerText.substring(0, headerText.indexOf(CANCEL_NOTICE)).trim();
							}

							Date[] timeNotations = getParsedTimeNotations(headerText);

							if (timeNotations.length != 2) {
								throw new ParseException("A schedule item needs to have a defined start and end date.");
							}

							Date start = timeNotations[0];
							start.setYear(date.getYear());
							start.setMonth(date.getMonth());
							start.setDate(date.getDate());

							Date end = timeNotations[1];
							end.setYear(date.getYear());
							end.setMonth(date.getMonth());
							end.setDate(date.getDate());


							// Handle content.
							String[] splittedContent = contentText.split("\n");

							String title = splittedContent[0];
							String description = "";
							for (int a = 1; a < splittedContent.length; a++) {
								description += splittedContent[a];
							}

							// Append headertext to title
							title += " (" + headerText + ")";

							items.add(new ScheduleItem(title, description, start, end, isCancelled));
						} else {
							throw new ParseException("Ambiguous Item Content.");
						}
					}
				} catch (ParseException e) {
					e.printStackTrace();

					// The item could not be parsed but continue anyway.
					parsedCompletely = false; // Notice that it hasn't completed without trouble.
				}
			}
		}

		return new ScheduleDayResult(parsedCompletely, new ScheduleDay(items.toArray(new ScheduleItem[items.size()]), date));
	}

	/**
	 * Get all parsable time notations within the passed string.
	 *
	 * @param string
	 * @return
	 */
	private Date[] getParsedTimeNotations(String string) {
		String[] parts = string.split(" "); // Split when approaching a space.
		List<Date> timeNotations = new ArrayList<>();

		for (String part : parts) {
			try {
				Date date = TIME_PARSER.parse(part);

				if (date != null) {
					timeNotations.add(date);
				}
			} catch (java.text.ParseException e) {
				// Just jump this part.
			}
		}

		return timeNotations.toArray(new Date[timeNotations.size()]);
	}

	/**
	 * Get Title from item element.
	 * @param itemElement
	 * @return
	 */
	private String getHeaderFromItemElement(Element itemElement) {
		return itemElement.text();
	}
	
	/**
	 * Get Content from item element.
	 * @param itemElement
	 * @return
	 */
	private String getContentFromItemElement(Element itemElement) {
		return removeBreaks(itemElement.html());
	}

	private String removeBreaks(String html) {
		if (html == null) {
			return html;
		}

		Document document = Jsoup.parse(html);
		document.outputSettings(new Document.OutputSettings().prettyPrint(false)); // Preserve linebreaks and spacing
		String s = document.html().replaceAll("\\\\n", "\n");
		return Jsoup.clean(s, "", Whitelist.none(), new Document.OutputSettings().prettyPrint(false));
	}
	
	/**
	 * Extract day from day Element.
	 * @param dayElement
	 * @return
	 */
	private Date getDateFromDayElement(Element dayElement) throws ParseException {
		try {
			return DATE_PARSER.parse(dayElement.attr("id"));
		} catch (java.text.ParseException e) {
			throw new ParseException(e);
		}
	}
	
	/**
	 * Get Days from table body
	 * @param tableBody
	 * @return
	 * @throws ParseException
	 */
	private Elements getPlanDays(Element tableBody) throws ParseException {
		Elements possibleDayElements = tableBody.getElementsByClass(TABLE_DAY_CLASS);
		
		if (possibleDayElements == null || possibleDayElements.isEmpty()) {
			throw new ParseException("Could not parse days from table body.");
		}
		
		return possibleDayElements;
	}
	
	/**
	 * Get the table body element.
	 * @param doc
	 * @return
	 * @throws ParseException
	 */
	private Element getTableBodyElement(Document doc) throws ParseException {
		Elements possibleElements = doc.getElementsByClass(TABLE_PLAN_CLASS);
		
		for (int i = 0; i < possibleElements.size(); i++) {
			Element element = possibleElements.get(i);
			if (element.tagName() == "tbody") {
				return element;
			}
		}
		
		throw new ParseException("Could not parse the table body element.");
	}

	/**
	 * Schedule day parsing result containing the items and additional information.
	 */
	private class ScheduleDayResult {

		private final boolean parsedCompletely;
		private final ScheduleDay result;

		public ScheduleDayResult(boolean parsedCompletely, ScheduleDay result) {
			this.parsedCompletely = parsedCompletely;
			this.result = result;
		}

		public boolean isParsedCompletely() {
			return parsedCompletely;
		}

		public ScheduleDay getResult() {
			return result;
		}

	}

	/**
	 * Result object of the week plan parser.
	 */
	public static class ScheduleResult {

		private final boolean parsedCompletely;
		private final Schedule schedule;

		public ScheduleResult(boolean parsedCompletely, Schedule schedule) {
			this.parsedCompletely = parsedCompletely;
			this.schedule = schedule;
		}

		public boolean isParsedCompletely() {
			return parsedCompletely;
		}

		public Schedule getSchedule() {
			return schedule;
		}

	}
	
}
