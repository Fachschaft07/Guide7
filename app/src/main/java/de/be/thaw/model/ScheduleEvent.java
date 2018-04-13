package de.be.thaw.model;

import android.os.Parcel;
import android.os.Parcelable;

import com.alamkanak.weekview.WeekViewEvent;

import java.util.Calendar;

import de.be.thaw.model.schedule.ScheduleItem;

/**
 * Created by Benjamin Eder on 13.02.2017.
 */
public class ScheduleEvent extends WeekViewEvent implements Parcelable {

	private static int ID_COUNTER = 0;
	private ScheduleItem item;

	public ScheduleEvent(ScheduleItem item) {
		setId(ID_COUNTER);
		ID_COUNTER++;

		this.item = item;

		// Initialize Calendars
		Calendar startTime = Calendar.getInstance();
		startTime.setTime(item.getStart());
		setStartTime(startTime);

		Calendar endTime = Calendar.getInstance();
		endTime.setTime(item.getEnd());
		setEndTime(endTime);
	}

	@Override
	public String getName() {
		return item.getTitle();
	}

	@Override
	public String getLocation() {
		return item.getDescription() + "\n" + item.getLocation();
	}

	protected ScheduleEvent(Parcel in) {
		item = (ScheduleItem) in.readValue(getClass().getClassLoader());
		setStartTime((Calendar) in.readValue(getClass().getClassLoader()));
		setEndTime((Calendar) in.readValue(getClass().getClassLoader()));
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeValue(item);
		dest.writeValue(getStartTime());
		dest.writeValue(getEndTime());
	}

	public ScheduleItem getItem() {
		return item;
	}

	@Override
	public int describeContents() {
		return 0;
	}

	public static final Creator<ScheduleEvent> CREATOR = new Creator<ScheduleEvent>() {

		@Override
		public ScheduleEvent createFromParcel(Parcel in) {
			return new ScheduleEvent(in);
		}

		@Override
		public ScheduleEvent[] newArray(int size) {
			return new ScheduleEvent[size];
		}

	};

}
