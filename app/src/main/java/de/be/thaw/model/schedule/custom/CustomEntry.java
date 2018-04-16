package de.be.thaw.model.schedule.custom;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.Calendar;
import java.util.Date;

/**
 * Holds information to create a series of CustomScheduleItems.
 */

public class CustomEntry implements Parcelable {

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

	public CustomEntry(Parcel in) {
		start = (Date) in.readValue(getClass().getClassLoader());
		duration = in.readInt();
		end = (Date) in.readValue(getClass().getClassLoader());
		cycle = in.readInt();
		title = in.readString();
		description = in.readString();
		location = in.readString();
		UID = in.readString();
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

	@Override
	public int describeContents() {
		return 0;
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeValue(start);
		dest.writeInt(duration);
		dest.writeValue(end);
		dest.writeInt(cycle);
		dest.writeString(title);
		dest.writeString(description);
		dest.writeString(location);
		dest.writeString(UID);
	}

	public static final Creator<CustomEntry> CREATOR = new Creator<CustomEntry>() {

		@Override
		public CustomEntry createFromParcel(Parcel in) {
			return new CustomEntry(in);
		}

		@Override
		public CustomEntry[] newArray(int size) {
			return new CustomEntry[size];
		}

	};
}
