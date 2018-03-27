package de.be.thaw.util.job.jobs;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.v4.app.NotificationCompat;

import com.evernote.android.job.Job;
import com.evernote.android.job.JobManager;
import com.evernote.android.job.JobRequest;
import com.evernote.android.job.util.support.PersistableBundleCompat;

import java.io.IOException;
import java.util.Calendar;

import de.be.thaw.MainActivity;
import de.be.thaw.R;
import de.be.thaw.cache.AppointmentUtil;
import de.be.thaw.model.appointments.Appointment;
import de.be.thaw.util.Preference;

/**
 * Job aiming to notify the user about upcoming appointments.
 *
 * Created by Benjamin Eder on 25.04.2017.
 */
public class UpcomingAppointmentNotificationJob extends Job {

	public static final String TAG = "UpcomingAppointmentNotificationJob";
	public static final int NOTIFICATION_ID = 3;

	/**
	 * Key for an appointments content saved in the background jobs extras to be shown in a notification.
	 */
	private static final String CONTENT_KEY = "content";

	/**
	 * Key for an appointments timespan stored in the background jobs extras.
	 */
	private static final String TIMESPAN_KEY = "timeSpan";

	@NonNull
	@Override
	protected Result onRunJob(Params params) {
		// Check if params already contain infos for an upcoming event.
		if (params.getExtras() != null) {
			PersistableBundleCompat extras = params.getExtras();

			String timeSpan = extras.getString(TIMESPAN_KEY, null);
			String content = extras.getString(CONTENT_KEY, null);

			if (timeSpan != null && content != null) {
				issueNotification(timeSpan, content);
			}
		}

		Appointment[] appointments = null;
		try {
			appointments = AppointmentUtil.retrieve(getContext());
		} catch (IOException e) {
			e.printStackTrace();
			return Result.FAILURE;
		}

		if (appointments == null) {
			return Result.FAILURE;
		}

		// Get next appointment.
		Calendar now = Calendar.getInstance();

		Appointment nextAppointment = null;
		long shortestDiff = -1;
		for (Appointment appointment : appointments) {
			if (appointment.hasSpecificDate()) {
				long difference = appointment.getDate().getTimeInMillis() - now.getTimeInMillis();
				if (difference > 0 && (shortestDiff > difference || shortestDiff == -1)) {
					shortestDiff = difference;
					nextAppointment = appointment;
				}
			}
		}

		if (nextAppointment == null) {
			return Result.FAILURE;
		}

		// Schedule new notification for the next appointment.
		PersistableBundleCompat extras = new PersistableBundleCompat();
		extras.putString(TIMESPAN_KEY, nextAppointment.getTimeSpan());
		extras.putString(CONTENT_KEY, nextAppointment.getDescription());

		Calendar jobCal = Calendar.getInstance();
		jobCal.setTime(nextAppointment.getDate().getTime());

		jobCal.set(Calendar.DAY_OF_YEAR, jobCal.get(Calendar.DAY_OF_YEAR) - 1);
		jobCal.set(Calendar.HOUR_OF_DAY, 12); // Twelve o'clock!

		long startMs = jobCal.getTimeInMillis() - now.getTimeInMillis();
		long endMs = startMs + 60_000L;

		// Build & Schedule Job.
		new JobRequest.Builder(TAG).setExtras(extras)
				.setExecutionWindow(startMs, endMs)
				.build()
				.schedule();

		return Result.SUCCESS;
	}

	/**
	 * Issue notification that an upcoming appointment is approaching.
	 */
	private void issueNotification(String timeSpan, String content) {
		Intent resultIntent = new Intent(getContext(), MainActivity.class);
		resultIntent.putExtra(MainActivity.CALL_FRAGMENT_EXTRA, R.id.drawer_action_appointments);

		PendingIntent resultPendingIntent =
				PendingIntent.getActivity(
						getContext(),
						0,
						resultIntent,
						PendingIntent.FLAG_UPDATE_CURRENT
				);

		NotificationCompat.Builder notificationBuilder =
				new NotificationCompat.Builder(getContext(), getContext().getString(R.string.channelId))
						.setSmallIcon(R.drawable.notification_icon)
						.setContentTitle(getContext().getResources().getString(R.string.upcomingAppointmentNotificationTitle))
						.setContentText(timeSpan + "\n" + content)
						.setContentIntent(resultPendingIntent)
						.setDefaults(Notification.DEFAULT_SOUND | Notification.DEFAULT_VIBRATE | Notification.DEFAULT_LIGHTS)
						.setAutoCancel(true)
						.setPriority(NotificationCompat.PRIORITY_DEFAULT);

		NotificationManager notificationManager = (NotificationManager) getContext().getSystemService(Context.NOTIFICATION_SERVICE);
		notificationManager.notify(NOTIFICATION_ID, notificationBuilder.build());
	}

	/**
	 * Schedule the job to be executed.
	 */
	public static void scheduleJob() {
		// Schedule immediately.
		new JobRequest.Builder(TAG).setExact(1_000L)
				.setUpdateCurrent(true)
				.build()
				.schedule();
	}

	/**
	 * Cancel this job.
	 */
	public static void cancelJob() {
		JobManager.instance().cancelAllForTag(TAG);
	}

	/**
	 * Return whether this job is activated (Activatable via settings by user).
	 * @return
	 */
	public static boolean isActivated(Context context) {
		return Preference.UPCOMING_APPOINTMENT_NOTIFICATION_ENABLED.getBoolean(context);
	}

}
