package de.be.thaw.model.schedule;

import java.util.Date;
import java.util.Map;

public class ScheduleItem {

	private Date start;
	private Date end;

	private String title;
	
	private String description;

	public ScheduleItem() {

	}

	public ScheduleItem(String title, String description, Date start, Date end) {
		this.title = title;
		this.description = description;
		this.start = start;
		this.end = end;
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

	public Date getStart() {
		return start;
	}

	public void setStart(Date start) {
		this.start = start;
	}

	public Date getEnd() {
		return end;
	}

	public void setEnd(Date end) {
		this.end = end;
	}

	@Override
	public String toString() {
		return title + ": " + description;
	}
	
}
