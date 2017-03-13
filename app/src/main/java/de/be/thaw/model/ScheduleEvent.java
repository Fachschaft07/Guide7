package de.be.thaw.model;

import android.os.Parcel;
import android.os.Parcelable;

import com.alamkanak.weekview.WeekViewEvent;

import java.util.Calendar;
import java.util.Date;

import de.be.thaw.model.schedule.ScheduleItem;
import de.be.thaw.util.ThawUtil;

/**
 * Created by Benjamin Eder on 13.02.2017.
 */
public class ScheduleEvent extends WeekViewEvent implements Parcelable {

	private static int ID_COUNTER = 0;

	public ScheduleEvent(ScheduleItem item) {
		setId(ID_COUNTER);
		ID_COUNTER++;

		setName(item.getTitle());

		setLocation(item.getDescription());

		Calendar startTime = Calendar.getInstance();
		startTime.setTime(item.getStart());
		setStartTime(startTime);

		Calendar endTime = Calendar.getInstance();
		endTime.setTime(item.getEnd());
		setEndTime(endTime);
	}

	protected ScheduleEvent(Parcel in) {
		setName(in.readString());
		setLocation(in.readString());
		setStartTime((Calendar) in.readValue(getClass().getClassLoader()));
		setEndTime((Calendar) in.readValue(getClass().getClassLoader()));
	}

	@Override
	public void writeToParcel(Parcel dest, int flags) {
		dest.writeString(getName());
		dest.writeString(getLocation());
		dest.writeValue(getStartTime());
		dest.writeValue(getEndTime());
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
