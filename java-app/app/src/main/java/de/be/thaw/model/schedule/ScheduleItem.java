package de.be.thaw.model.schedule;

import android.os.Parcel;
import android.os.Parcelable;

import java.util.Date;
import java.util.Map;

public class ScheduleItem implements Parcelable {

	private Date start;
	private Date end;
	private Date timestamp;

	private String title;
	private String description;
	private String location;
	private String url;

	/**
	 * Unique ID of the schedule item.
	 */
	private String UID;

	private boolean eventCancelled;

	public ScheduleItem(String title, String description, String UID) {
		this.title = title;
		this.description = description;
		this.UID = UID;
	}

	public ScheduleItem() {
		// Default constructor for JSON Builder.
	}

	public Date getTimestamp() {
		return timestamp;
	}

	public void setTimestamp(Date timestamp) {
		this.timestamp = timestamp;
	}

	public String getLocation() {
		return location;
	}

	public void setLocation(String location) {
		this.location = location;
	}

	public String getUrl() {
		return url;
	}

	public void setUrl(String url) {
		this.url = url;
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

	public boolean isEventCancelled() {
		return eventCancelled;
	}

	public void setEventCancelled(boolean eventCancelled) {
		this.eventCancelled = eventCancelled;
	}

	public String getUID() {
		return UID;
	}

	public void setUID(String UID) {
		this.UID = UID;
	}

	protected ScheduleItem(Parcel in) {
		title = in.readString();
		description = in.readString();
		location = in.readString();
		url = in.readString();
		eventCancelled = in.readByte() != 0;
		start = (Date) in.readValue(getClass().getClassLoader());
		end = (Date) in.readValue(getClass().getClassLoader());
		timestamp = (Date) in.readValue(getClass().getClassLoader());
		UID = in.readString();
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(title);
		dest.writeString(description);
		dest.writeString(location);
		dest.writeString(url);
		dest.writeByte((byte) (eventCancelled ? 1 : 0));
		dest.writeValue(getStart());
		dest.writeValue(getEnd());
		dest.writeValue(getTimestamp());
		dest.writeString(UID);
	}

	@Override
	public boolean equals(Object o) {
		if (this == o) return true;
		if (o == null || getClass() != o.getClass()) return false;

		ScheduleItem that = (ScheduleItem) o;

		if (eventCancelled != that.eventCancelled) return false;
		if (start != null ? !start.equals(that.start) : that.start != null) return false;
		if (end != null ? !end.equals(that.end) : that.end != null) return false;
		if (title != null ? !title.equals(that.title) : that.title != null) return false;
		if (description != null ? !description.equals(that.description) : that.description != null)
			return false;
		if (location != null ? !location.equals(that.location) : that.location != null)
			return false;
		if (url != null ? !url.equals(that.url) : that.url != null) return false;
		return UID != null ? UID.equals(that.UID) : that.UID == null;

	}

	@Override
	public int hashCode() {
		int result = start != null ? start.hashCode() : 0;
		result = 31 * result + (end != null ? end.hashCode() : 0);
		result = 31 * result + (title != null ? title.hashCode() : 0);
		result = 31 * result + (description != null ? description.hashCode() : 0);
		result = 31 * result + (location != null ? location.hashCode() : 0);
		result = 31 * result + (url != null ? url.hashCode() : 0);
		result = 31 * result + (UID != null ? UID.hashCode() : 0);
		result = 31 * result + (eventCancelled ? 1 : 0);
		return result;
	}

	@Override
	public int describeContents() {
		return 0;
	}

	public static final Creator<ScheduleItem> CREATOR = new Creator<ScheduleItem>() {
		@Override
		public ScheduleItem createFromParcel(Parcel in) {
			return new ScheduleItem(in);
		}

		@Override
		public ScheduleItem[] newArray(int size) {
			return new ScheduleItem[size];
		}
	};

	@Override
	public String toString() {
		return title + ": " + description;
	}
	
}
