package de.be.thaw.storage.cache;

import android.content.Context;
import android.util.Log;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.FileFilter;
import java.io.FileWriter;
import java.io.IOException;

import de.be.thaw.model.canteen.Menu;

/**
 * Created by Benjamin Eder on 12.03.2017.
 */
public class MenuUtil {

	private static final String TAG = "MenuUtil";

	private static final String MENU_FILE = "menu_storage";

	/**
	 * Store Menus in cache.
	 * @param menus
	 * @param context
	 */
	public static void store(Menu[] menus, Context context) throws IOException {
		ObjectMapper mapper = new ObjectMapper();
		String menusJSON = mapper.writeValueAsString(menus);

		File menuStorage = new File(context.getFilesDir(), MENU_FILE + ".json");
		FileWriter writer = new FileWriter(menuStorage, false);

		writer.write(menusJSON); // Write menus to file.

		writer.close();

		Log.i(TAG, "Stored Menu entries to file.");
	}

	/**
	 * Retrieve stored menus from file.
	 * @param context
	 * @return
	 */
	public static Menu[] retrieve(Context context) throws IOException {
		File menuStorage = new File(context.getFilesDir(), MENU_FILE + ".json");

		if (menuStorage.exists()) {
			ObjectMapper mapper = new ObjectMapper();

			Menu[] menus = mapper.readValue(menuStorage, Menu[].class);

			Log.i(TAG, "Retrieved stored Menu entries from file.");
			return menus;
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
				return file.getName().contains(MENU_FILE);
			}

		});

		for (File file : cacheFiles) {
			file.delete();
		}

		Log.i(TAG, "Cleared Menu entry cache files.");
	}

}
