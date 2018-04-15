package de.be.thaw.util;

import android.content.Context;
import android.support.v7.preference.PreferenceManager;

/**
 * Get settings from the application preferences.
 *
 * Created by Benjamin Eder on 07.10.2017.
 */
public enum Preference {

	DISPLAYED_DAYS("displayedDaysPrefKey", "2"),
	WEEK_PLAN_CHANGE_NOTIFICATION_ENABLED("weekPlanChangeNotificationKey", true),
	STATIC_WEEK_PLAN_NOTIFICATION_ENABLED("staticScheduleNotificationKey", false),
	SHOW_CANCELLED_EVENTS("showCancelledEvents", true),
	NOTICE_BOARD_CHANGE_NOTIFICATION_ENABLED("noticeboardNotificationKey", true),
	UPCOMING_APPOINTMENT_NOTIFICATION_ENABLED("upcomingAppointmentNotification", false),
	CLEAR_CACHE("clearCacheKey", null),
	CLEAR_CUSTOM("clearCustomEntriesKey", null);

	/**
	 * Key of the preference.
	 */
	private final String key;

	/**
	 * Default value of the preference.
	 */
	private final Object defaultValue;

	/**
	 * Create new enumeration item.
	 * @param key of the preference
	 * @param defaultValue of the preference
	 */
	Preference(String key, Object defaultValue) {
		this.key = key;
		this.defaultValue = defaultValue;
	}

	/**
	 * Get key of preference.
	 * @return key of preference
	 */
	public String getKey() {
		return key;
	}

	/**
	 * Get boolean value for the preference.
	 *
	 * @param context to fetch preferences for
	 * @return the boolean value of the preference
	 */
	public boolean getBoolean(Context context) {
		return PreferenceManager.getDefaultSharedPreferences(context).getBoolean(key, (boolean) defaultValue);
	}

	/**
	 * Get integer value for the preference.
	 *
	 * @param context to fetch preferences for
	 * @return the integer value of the preference
	 */
	public int getInteger(Context context) {
		return Integer.parseInt(PreferenceManager.getDefaultSharedPreferences(context).getString(key, (String) defaultValue));
	}

	/**
	 * Get preference by key.
	 *
	 * @param key of the preference
	 * @return the preference with the passed key or <code>null</code>.
	 */
	public static Preference of(String key) {
		for (Preference p : values()) {
			if (p.getKey().equals(key)) {
				return p;
			}
		}

		return null;
	}

}
