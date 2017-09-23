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
import java.util.ArrayList;
import java.util.List;

import de.be.thaw.model.schedule.Schedule;
import de.be.thaw.model.schedule.ScheduleItem;
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
	 * @param items
	 * @param context
	 */
	public static void store(List<ScheduleItem> items, Context context) throws IOException {
		if (context != null) {
			ObjectMapper mapper = new ObjectMapper();
			String scheduleJson = mapper.writeValueAsString(items.toArray(new ScheduleItem[items.size()]));

			File scheduleStorage = new File(context.getFilesDir(), SCHEDULE_FILE);
			FileWriter writer = new FileWriter(scheduleStorage, false);

			writer.write(scheduleJson); // Write Schedule to file.

			writer.close();

			Log.i(TAG, "Stored Schedule to file.");
		}
	}

	/**
	 * Retrieve stored schedule from file.
	 * @param context
	 * @return
	 */
	public static List<ScheduleItem> retrieve(Context context) throws IOException {
		if (context != null) {
			File scheduleStorage = new File(context.getFilesDir(), SCHEDULE_FILE);

			if (scheduleStorage.exists()) {
				ObjectMapper mapper = new ObjectMapper();
				ScheduleItem[] items = mapper.readValue(scheduleStorage, ScheduleItem[].class);

				List<ScheduleItem> itemList = new ArrayList<>();
				for (ScheduleItem item : items) {
					itemList.add(item);
				}

				Log.i(TAG, "Retrieved stored Schedule from file.");
				return itemList;
			}
		}

		return null;
	}

	/**
	 * Clear Cache Files.
	 * @param context
	 */
	public static void clear(Context context) {
		if (context != null) {
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

}
