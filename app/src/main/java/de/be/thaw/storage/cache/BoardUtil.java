package de.be.thaw.storage.cache;

import android.content.Context;
import android.util.Log;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.FileFilter;
import java.io.FileWriter;
import java.io.IOException;

import de.be.thaw.model.noticeboard.BoardEntry;

/**
 * Created by Benjamin Eder on 12.03.2017.
 */

public class BoardUtil {

	private static final String TAG = "BoardUtil";

	private static final String BOARD_FILE = "board_storage";

	/**
	 * Store Board Entties in cache.
	 * @param entries
	 * @param context
	 */
	public static void store(BoardEntry[] entries, Context context) throws IOException {
		ObjectMapper mapper = new ObjectMapper();
		String entriesJSON = mapper.writeValueAsString(entries);

		File boardStorage = new File(context.getFilesDir(), BOARD_FILE + ".json");
		FileWriter writer = new FileWriter(boardStorage, false);

		writer.write(entriesJSON); // Write Entries to file.

		writer.close();

		Log.i(TAG, "Stored Board entries to file.");
	}

	/**
	 * Retrieve stored board entries from file.
	 * @param context
	 * @return
	 */
	public static BoardEntry[] retrieve(Context context) throws IOException {
		File boardStorage = new File(context.getFilesDir(), BOARD_FILE + ".json");

		if (boardStorage.exists()) {
			ObjectMapper mapper = new ObjectMapper();

			BoardEntry[] entries = mapper.readValue(boardStorage, BoardEntry[].class);

			Log.i(TAG, "Retrieved stored Board entries from file.");
			return entries;
		} else {
			return null;
		}
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
				return file.getName().contains(BOARD_FILE);
			}

		});

		for (File file : cacheFiles) {
			file.delete();
		}

		Log.i(TAG, "Cleared Board entry cache files.");
	}

}
