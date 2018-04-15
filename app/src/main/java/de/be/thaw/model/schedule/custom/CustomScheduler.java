package de.be.thaw.model.schedule.custom;

import java.util.ArrayList;
import java.util.Calendar;
import java.util.Date;
import java.util.List;

/**
 * Gets that the dates between two dates in a specific frequency.
 */

public class CustomScheduler {

    public static final int DAILY = 1;
    public static final int WEEKLY = 7;
    public static final int BIWEEKLY = 14;

    public static List<CustomScheduleItem> createScheduleItems(CustomEntry entry) {
    	List<CustomScheduleItem> items = new ArrayList<>();

    	List<Date> dates = getDates(entry.getStart(), entry.getEnd(), entry.getCycle());

    	Calendar calendar = Calendar.getInstance();
    	for (Date date : dates) {
    		CustomScheduleItem si = new CustomScheduleItem(entry, items.size());
    		si.setStart(date);

    		calendar.setTime(date);
    		calendar.add(Calendar.MINUTE, entry.getDuration());

    		si.setEnd(calendar.getTime());

    		items.add(si);
		}

    	return items;
	}

    /**
     * Gets the successive dates in a specified time period and frequency.
     * @param start First and starting date
     * @param end Limits the time period
     * @param cycle Frequency of entries
     * @return
     */
    private static List<Date> getDates(Date start, Date end, int cycle) {
        List<Date> dates = new ArrayList<>();
		Calendar calendar = Calendar.getInstance();
		calendar.setTime(start);
		while (calendar.getTime().before(end)) {
			dates.add(calendar.getTime());
			calendar.add(Calendar.DAY_OF_MONTH, cycle);
		}

        return dates;
    }
}
