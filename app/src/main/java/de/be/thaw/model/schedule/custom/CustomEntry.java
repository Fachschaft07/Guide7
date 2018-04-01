package de.be.thaw.model.schedule.custom;

import java.util.Calendar;
import java.util.Date;

/**
 * Holds information to create a series of CustomScheduleItems.
 */

public class CustomEntry {

	/**
	 * Starting date and time of day.
	 */
	private Date start;

	/**
	 * Duration of the appointment in minutes.
	 */
	private int duration;

	/**
	 * Last day the appointment occurs on.
	 */
	private Date end;

	/**
	 * How frequently the entry is repeated.
	 */
	private int cycle = CustomScheduler.DAILY;

	private String title;

	private String description;

	private String location;

	private final String UID;

	public CustomEntry() {
		this.UID = Long.toHexString(System.currentTimeMillis());
	}

	public Date getStart() {
		return start;
	}

	public void setStart(Date start) {
		this.start = start;
	}

	public int getDuration() {
		return duration;
	}

	public void setDuration(int duration) {
		this.duration = duration;
	}

	public Date getEnd() {
		if (end == null) {
			Calendar c = Calendar.getInstance();
			c.setTime(getStart());
			c.set(Calendar.HOUR_OF_DAY, 23);
			c.set(Calendar.MINUTE, 59);

			return c.getTime();
		}
		return end;
	}

	public void setEnd(Date end) {
		this.end = end;
	}

	public int getCycle() {
		return cycle;
	}

	public void setCycle(int cycle) {
		this.cycle = cycle;
	}

	public String getTitle() {
		return title;
	}

	public void setTitle(String title) {
		this.title = title;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public String getUID() {
		return UID;
	}
}
