package de.be.thaw.model.appointments;

import java.util.Calendar;

/**
 * Created by Benjamin Eder on 23.04.2017.
 */
public class Appointment {

	/**
	 * Calendar containing the month and year.
	 */
	private Calendar month;

	/**
	 * Timespan this message applies to.
	 * Can't be parsed properly because the format is not fixed.
	 */
	private String timeSpan;

	/**
	 * The "content" of an appointment.
	 */
	private String description;

	public Appointment() {

	}

	public Appointment(Calendar month, String timeSpan, String description) {
		this.month = month;
		this.timeSpan = timeSpan;
		this.description = description;
	}

	public Calendar getMonth() {
		return month;
	}

	public void setMonth(Calendar month) {
		this.month = month;
	}

	public String getTimeSpan() {
		return timeSpan;
	}

	public void setTimeSpan(String timeSpan) {
		this.timeSpan = timeSpan;
	}

	public String getDescription() {
		return description;
	}

	public void setDescription(String description) {
		this.description = description;
	}

}
