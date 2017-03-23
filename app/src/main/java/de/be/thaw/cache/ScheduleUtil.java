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
	 * @param context
	 * @param year
	 * @param month
	 * @param week
	 */
	public static void store(Schedule schedule, Context context, int year, int month, int week) throws IOException {
		ObjectMapper mapper = new ObjectMapper();
		String scheduleJson = mapper.writeValueAsString(schedule);

		File scheduleStorage = new File(context.getFilesDir(), getFileName(year, month, week));
		FileWriter writer = new FileWriter(scheduleStorage, false);

		writer.write(scheduleJson); // Write Schedule to file.

		writer.close();

		Log.i(TAG, "Stored Schedule to file. Year: " + year + " Month: " + month + " Week: " + week);
	}

	/**
	 * Retrieve stored schedule from file.
	 * @param context
	 * @param year
	 * @param month
	 * @param week
	 * @return
	 */
	public static Schedule retrieve(Context context, int year, int month, int week) throws IOException {
		File scheduleStorage = new File(context.getFilesDir(), getFileName(year, month, week));

		if (scheduleStorage.exists()) {
			ObjectMapper mapper = new ObjectMapper();
			Schedule schedule = mapper.readValue(scheduleStorage, Schedule.class);

			Log.i(TAG, "Retrieved stored Schedule from file. Year: " + year + " Month: " + month + " Week: " + week);
			return schedule;
		} else {
			return null;
		}
	}

	/**
	 * Get File name.
	 * @param year
	 * @param month
	 * @param week
	 * @return
	 */
	private static String getFileName(int year, int month, int week) {
		return SCHEDULE_FILE + "_" + year + "_" + month + "_" + week + ".json";
	}

	/**
	 * Clear Cache Files.
	 * @param context
	 */
	public static void clear(Context context) {
		File internalDir = context.getFilesDir();

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
