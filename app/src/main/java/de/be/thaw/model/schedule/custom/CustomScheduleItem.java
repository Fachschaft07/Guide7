package de.be.thaw.model.schedule.custom;

import java.util.Calendar;

import de.be.thaw.model.schedule.ScheduleItem;

/**
 * Represents a single entry of a custom entry.
 */

public class CustomScheduleItem extends ScheduleItem {

	private String parentUID;

	public CustomScheduleItem(CustomEntry entry, int uid) {
		super(entry.getTitle(), entry.getDescription(), entry.getUID() + uid);
		this.parentUID = entry.getUID();
		super.setTitle(entry.getTitle());
		super.setDescription(entry.getDescription());
		super.setLocation(entry.getLocation());
		super.setTimestamp(Calendar.getInstance().getTime());
	}

	public CustomScheduleItem() {
        super();
        // Default constructor for JSON Builder.
    }

	public String getParentUID() {
		return parentUID;
	}

	@Override
	public boolean isEventCancelled() {
		return false;
	}
}
