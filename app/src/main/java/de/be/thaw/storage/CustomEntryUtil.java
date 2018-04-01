package de.be.thaw.storage;

import android.content.Context;
import android.util.Log;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.FileWriter;
import java.io.IOException;
import java.util.ArrayList;
import java.util.Arrays;
import java.util.List;

import de.be.thaw.model.schedule.custom.CustomScheduleItem;

/**
 * Utility class giving access to store and retrieve to/from file.
 */

public class CustomEntryUtil {

	private static final String TAG = "CustomEntryUtil";
	private static final String CUSTOM_ENTRY_FILE = "custom_entry_storage";
	private static final String LOG_MESSAGE_STORED = "Stored custom schedule entries to file.";
	private static final String LOG_MESSAGE_RETRIEVED = "Retrieved stored custom schedule entries from file.";
	private static final String LOG_MESSAGE_APPENDED = "Appended custom schedule entries to file";
	private static final String LOG_MESSAGE_CLEARED = "Cleared Schedule storage files.";
	private static final String LOG_MESSAGE_REMOVED_SINGLE = "Removed custom schedule entry.";
	private static final String LOG_MESSAGE_REMOVED_MULTIPLE = "Removed custom schedule entries.";

	public static void store(List<CustomScheduleItem> items, Context context) throws IOException {
		if (context != null) {
			ObjectMapper mapper = new ObjectMapper();
			String entryJson = mapper.writeValueAsString(items.toArray(new CustomScheduleItem[items.size()]));
			File entryStorage = new File(context.getFilesDir(), CUSTOM_ENTRY_FILE);
			FileWriter writer = new FileWriter(entryStorage, false);
			writer.write(entryJson);
			writer.close();

			Log.i(TAG, LOG_MESSAGE_STORED);
		}
	}

	public static List<CustomScheduleItem> retrieve(Context context) throws IOException {
		if (context != null) {
			File entryStorage = new File(context.getFilesDir(), CUSTOM_ENTRY_FILE);

			if (entryStorage.exists()) {
				ObjectMapper mapper = new ObjectMapper();
				CustomScheduleItem[] items = mapper.readValue(entryStorage, CustomScheduleItem[].class);

				List<CustomScheduleItem> itemList = Arrays.asList(items);

				Log.i(TAG, LOG_MESSAGE_RETRIEVED);

				return itemList;
			}
		}
		return new ArrayList<>();
	}

	public static void append(List<CustomScheduleItem> items, Context context) throws IOException {
		if (context != null) {
			List<CustomScheduleItem> itemList = retrieve(context);
			List<CustomScheduleItem> list = new ArrayList<>(itemList);
			list.addAll(items);
			store(list, context);

			Log.i(TAG, LOG_MESSAGE_APPENDED);
		}
	}

	public static void removeSingleEntry(String uid, Context context) throws IOException {
		if (context != null) {
			List<CustomScheduleItem> items = retrieve(context);
			for (int i = 0; i < items.size(); i++) {
				if (items.get(i).getUID().equals(uid)) {
					items.remove(i);
					Log.i(TAG, LOG_MESSAGE_REMOVED_SINGLE);
					break;
				}
			}
			store(items, context);
		}
	}

	public static void removeEntries(String uid, Context context) throws IOException {
		if (context != null) {
			List<CustomScheduleItem> items = retrieve(context);
			for (int i = items.size(); i > 0; --i) {
				if (items.get(i).getParentUID().equals(uid)) {
					items.remove(i);
				}
			}
			store(items, context);
			Log.i(TAG, LOG_MESSAGE_REMOVED_MULTIPLE);
		}
	}

	public static void clear(Context context) {
		if (context != null) {
			File entryFile = new File(context.getFilesDir(), CUSTOM_ENTRY_FILE);
			entryFile.delete();
			Log.i(TAG, LOG_MESSAGE_CLEARED);
		}
	}
}
