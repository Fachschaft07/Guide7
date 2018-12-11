package de.be.thaw.model.schedule;

import java.util.List;
import java.util.Map;

/**
 * Object representing a schedule.
 * 
 * @author Benjamin Eder
 */
public class Schedule {

	private ScheduleDay[] weekdays;

	public Schedule() {

	}
	
	public Schedule(ScheduleDay[] weekdays) {
		this.weekdays = weekdays;
	}

	public ScheduleDay[] getWeekdays() {
		return weekdays;
	}

	public void setWeekdays(ScheduleDay[] weekdays) {
		this.weekdays = weekdays;
	}

	@Override
	public String toString() {
		StringBuilder sb = new StringBuilder();
		
		for (ScheduleDay day : weekdays) {
			sb.append(day.toString());
		}
		
		return sb.toString();
	}
	
}
