package de.be.thaw.storage.cache;

import android.content.Context;
import android.util.Log;

import java.io.BufferedInputStream;
import java.io.BufferedOutputStream;
import java.io.ByteArrayOutputStream;
import java.io.File;
import java.io.FileFilter;
import java.io.FileInputStream;
import java.io.FileOutputStream;
import java.io.IOException;

import de.be.thaw.model.noticeboard.Portrait;

public class PortraitUtil {

	private static final String TAG = "PortraitUtil";

	private static final String PORTRAIT_FILE_ENDING = "portrait";

	/**
	 * Store Portrait in cache.
	 * @param portrait
	 * @param context
	 */
	public static void store(Portrait portrait, Context context) throws IOException {
		if (portrait.getData() != null && portrait.getData().length > 0) {
			File portraitStorage = new File(context.getFilesDir(), portrait.getId() + "." + PORTRAIT_FILE_ENDING);

			BufferedOutputStream bos = new BufferedOutputStream(new FileOutputStream(portraitStorage));
			bos.write(portrait.getData());
			bos.close();

			Log.i(TAG, "Stored portrait to file.");
		}
	}

	/**
	 * Retrieve stored portrait from file.
	 * @param context
	 * @param id
	 * @return
	 */
	public static Portrait retrieve(Context context, int id) throws IOException {
		File portraitStorage = new File(context.getFilesDir(), id + "." + PORTRAIT_FILE_ENDING);

		if (portraitStorage.exists()) {
			BufferedInputStream bis = new BufferedInputStream(new FileInputStream(portraitStorage));
			ByteArrayOutputStream baos = new ByteArrayOutputStream();

			int b;
			while ((b = bis.read()) != -1) {
				baos.write(b);
			}

			byte[] data = baos.toByteArray();

			bis.close();
			baos.close();

			return new Portrait(id, data);
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
				return file.getName().endsWith(PORTRAIT_FILE_ENDING);
			}

		});

		for (File file : cacheFiles) {
			file.delete();
		}

		Log.i(TAG, "Cleared portrait cache files.");
	}

}
