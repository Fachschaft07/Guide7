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
public class WeekPlanParser implements Parser<Schedule> {

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
	public Schedule parse(Document doc) throws ParseException {
		Element tableBody = getTableBodyElement(doc);
		Elements planDays = getPlanDays(tableBody);
		
		List<ScheduleDay> scheduleDays = new ArrayList<>();
		
		for (int i = 0; i < planDays.size(); i++) {
			scheduleDays.add(parseDay(planDays.get(i)));
		}
		
		return new Schedule(scheduleDays.toArray(new ScheduleDay[scheduleDays.size()]));
	}
	
	/**
	 * Parse a HTML Day Element.
	 * @param dayElement
	 * @return
	 * @throws ParseException
	 */
	private ScheduleDay parseDay(Element dayElement) throws ParseException {
		Date date = getDateFromDayElement(dayElement);

		List<ScheduleItem> items = new ArrayList<>();
		
		Elements possibleItems = dayElement.getElementsByTag("div");
		
		if (possibleItems != null && !possibleItems.isEmpty()) {
			for (int i = 0; i < possibleItems.size(); i++) {
				Element item = possibleItems.get(i);
				
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

						String[] splittedHeader = headerText.split(" ");
						String endDate = splittedHeader[splittedHeader.length - 1];
						String startDate = splittedHeader[splittedHeader.length - 3];


						Date start = null;
						Date end = null;
						try {
							start = TIME_PARSER.parse(startDate);
							end = TIME_PARSER.parse(endDate);

							start.setYear(date.getYear());
							start.setMonth(date.getMonth());
							start.setDate(date.getDate());

							end.setYear(date.getYear());
							end.setMonth(date.getMonth());
							end.setDate(date.getDate());
						} catch (java.text.ParseException e) {
							throw new ParseException(e);
						}


						String[] splittedContent = contentText.split("\n");

						String title = splittedContent[0];
						String description = "";
						for (int a = 1; a < splittedContent.length; a++) {
							description += splittedContent[a];
						}

						items.add(new ScheduleItem(title, description, start, end, isCancelled));
					} else {
						throw new ParseException("Ambiguous Item Content.");
					}
				}
			}
		}
		
		return new ScheduleDay(items.toArray(new ScheduleItem[items.size()]), date);
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
	
}
