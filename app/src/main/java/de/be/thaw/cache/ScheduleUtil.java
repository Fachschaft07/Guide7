package de.be.thaw.cache;

import android.app.Activity;
import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.FileFilter;
import java.io.FileWriter;
import java.io.IOException;

import de.be.thaw.model.schedule.Schedule;
import de.be.thaw.util.ThawUtil;

/**
 * Utility class giving access to store and retrive to/from file.
 *
 * Created by Benjamin Eder on 15.02.2017.
 */
public class ScheduleUtil {

	private static final String TAG = "ScheduleUtil";

	private static final String SCHEDULE_FILE = "schedule_storage";

	/**
	 * Store Schedule in cache.
	 * @param schedule
	 * @param activity
	 */
	public static void store(Schedule schedule, Activity activity, int year, int month) throws IOException {
		ObjectMapper mapper = new ObjectMapper();
		String scheduleJson = mapper.writeValueAsString(schedule);

		File scheduleStorage = new File(activity.getFilesDir(), getFileName(year, month));
		FileWriter writer = new FileWriter(scheduleStorage, false);

		writer.write(scheduleJson); // Write Schedule to file.

		writer.close();

		Log.i(TAG, "Stored Schedule to file. Year: " + year + " Month: " + month);
	}

	/**
	 * Retrieve stored schedule from file.
	 * @param activity
	 * @return
	 */
	public static Schedule retrieve(Activity activity, int year, int month) throws IOException {
		File scheduleStorage = new File(activity.getFilesDir(), getFileName(year, month));

		if (scheduleStorage.exists()) {
			ObjectMapper mapper = new ObjectMapper();
			Schedule schedule = mapper.readValue(scheduleStorage, Schedule.class);

			Log.i(TAG, "Retrieved stored Schedule from file. Year: " + year + " Month: " + month);
			return schedule;
		} else {
			return null;
		}
	}

	/**
	 * Get File name.
	 * @param year
	 * @param month
	 * @return
	 */
	private static String getFileName(int year, int month) {
		return SCHEDULE_FILE + "_" + year + "_" + month + ".json";
	}

	/**
	 * Clear Cache Files.
	 * @param activity
	 */
	public static void clear(Activity activity) {
		File internalDir = activity.getFilesDir();

		// Get all cache files
		File[] cacheFiles = internalDir.listFiles(new FileFilter() {

			@Override
			public boolean accept(File file) {
				return file.getName().contains(SCHEDULE_FILE);
			}

		});

		for (File file : cacheFiles) {
			file.delete();
		}

		Log.i(TAG, "Cleared Schedule cache files.");
	}

}
