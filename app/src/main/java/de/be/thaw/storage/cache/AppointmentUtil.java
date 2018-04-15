package de.be.thaw.storage.cache;

import android.content.Context;
import android.util.Log;

import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.File;
import java.io.FileFilter;
import java.io.FileWriter;
import java.io.IOException;

import de.be.thaw.model.appointments.Appointment;

/**
 * Created by Benjamin Eder on 12.03.2017.
 */
public class AppointmentUtil {

	private static final String TAG = "AppointmentUtil";

	private static final String APPOINTMENT_FILE = "appointment_storage";

	/**
	 * Store Appointments in cache.
	 *
	 * @param appointments
	 * @param context
	 */
	public static void store(Appointment[] appointments, Context context) throws IOException {
		ObjectMapper mapper = new ObjectMapper();
		String appointmentsJSON = mapper.writeValueAsString(appointments);

		File appointmentStorage = new File(context.getFilesDir(), APPOINTMENT_FILE + ".json");
		FileWriter writer = new FileWriter(appointmentStorage, false);

		writer.write(appointmentsJSON); // Write appointments to file.

		writer.close();

		Log.i(TAG, "Stored Appointment entries to file.");
	}

	/**
	 * Retrieve stored appointments from file.
	 *
	 * @param context
	 * @return
	 */
	public static Appointment[] retrieve(Context context) throws IOException {
		File storage = new File(context.getFilesDir(), APPOINTMENT_FILE + ".json");

		if (storage.exists()) {
			ObjectMapper mapper = new ObjectMapper();

			Appointment[] appointments = mapper.readValue(storage, Appointment[].class);

			Log.i(TAG, "Retrieved stored Appointment entries from file.");
			return appointments;
		} else {
			return null;
		}
	}

	/**
	 * Clear Cache Files.
	 *
	 * @param context
	 */
	public static void clear(Context context) {
		File internalDir = context.getFilesDir();

		// Get all cache files
		File[] cacheFiles = internalDir.listFiles(new FileFilter() {

			@Override
			public boolean accept(File file) {
				return file.getName().contains(APPOINTMENT_FILE);
			}

		});

		for (File file : cacheFiles) {
			file.delete();
		}

		Log.i(TAG, "Cleared Appointment entry cache files.");
	}

}
