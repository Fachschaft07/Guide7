package de.be.thaw.model.schedule;

import java.util.Date;
import java.util.List;
import java.util.Map;

public class ScheduleDay {

	private Date date;

	private ScheduleItem[] items;

	public ScheduleDay() {

	}

	public ScheduleDay(ScheduleItem[] items, Date date) {
		this.items = items;
		this.date = date;
	}

	public ScheduleItem[] getItems() {
		return items;
	}

	public void setItems(ScheduleItem[] items) {
		this.items = items;
	}

	public Date getDate() {
		return date;
	}

	public void setDate(Date date) {
		this.date = date;
	}

	@Override
	public String toString() {
		return date.toString();
	}
}
