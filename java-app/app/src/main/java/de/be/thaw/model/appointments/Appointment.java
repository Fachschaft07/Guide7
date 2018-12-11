package de.be.thaw.model.appointments;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

import java.util.Calendar;

/**
 * Created by Benjamin Eder on 23.04.2017.
 */
public class Appointment {

	/**
	 * Calendar containing the date of the appointment.
	 */
	@JsonProperty("date")
	private Calendar date;

	/**
	 * Timespan this message applies to.
	 * Can't be parsed properly because the format is not fixed.
	 */
	@JsonProperty("timeSpan")
	private String timeSpan;

	/**
	 * Whether the appointment has a specific date which could be parsed.
	 * If it has not it is not applicable for notifications.
	 */
	@JsonProperty("hasSpecificDate")
	private boolean hasSpecificDate;

	/**
	 * The "content" of an appointment.
	 */
	@JsonProperty("description")
	private String description;

	public Appointment() {

	}

	@JsonCreator
	public Appointment(@JsonProperty("date") Calendar date,
					   @JsonProperty("timeSpan") String timeSpan,
					   @JsonProperty("description") String description,
					   @JsonProperty("hasSpecificDate") boolean hasSpecificDate) {
		this.date = date;
		this.timeSpan = timeSpan;
		this.description = description;
		this.hasSpecificDate = hasSpecificDate;
	}

	public Calendar getDate() {
		return date;
	}

	public String getTimeSpan() {
		return timeSpan;
	}

	public String getDescription() {
		return description;
	}

	public boolean hasSpecificDate() {
		return hasSpecificDate;
	}

}
