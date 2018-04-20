package de.be.thaw.util.job.jobs;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.support.v4.app.NotificationCompat;
import android.util.Log;
import com.evernote.android.job.Job;
import com.evernote.android.job.JobManager;
import com.evernote.android.job.JobRequest;
import de.be.thaw.MainActivity;
import de.be.thaw.R;
import de.be.thaw.auth.Auth;
import de.be.thaw.auth.Credential;
import de.be.thaw.auth.exception.NoUserStoredException;
import de.be.thaw.connect.zpa.ZPAConnection;
import de.be.thaw.model.ScheduleEvent;
import de.be.thaw.model.schedule.ScheduleItem;
import de.be.thaw.storage.cache.ScheduleUtil;
import de.be.thaw.util.Preference;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.concurrent.TimeUnit;

/**
 * Recurring Task which is checking for Notice board changes by updating and
 * comparing.
 *
 * Created by Benjamin Eder on 17.03.2017.
 */
public class UpdateScheduleJob extends Job {

	public static final String TAG = "UpdateScheduleJob";
	public static final int NOTIFICATION_ID = 4;

	@NonNull
	@Override
	protected Result onRunJob(Params params) {
		// Fetch new schedule items.
		Credential credential;
		try {
			credential = Auth.getInstance().getCurrentUser(getContext()).getCredential();
		} catch (NoUserStoredException e) {
			e.printStackTrace();
			return Result.FAILURE;
		}

		List<ScheduleItem> items;
		try {
			ZPAConnection connection = new ZPAConnection(credential.getUsername(), credential.getPassword());
			items = connection.getRSSWeekplan();
		} catch (Exception e) {
			e.printStackTrace();
			return Result.FAILURE;
		}

		// Get old items.
		List<ScheduleItem> old;
		try {
			old = ScheduleUtil.retrieve(getContext());
		} catch (IOException e) {
			e.printStackTrace();
			return Result.FAILURE;
		}

		if (!items.isEmpty() && old != null && !old.isEmpty()) {
			// Check for changed items.
			Map<String, ScheduleItem> oldLookup = new HashMap<>();
			for (ScheduleItem item : old) {
				oldLookup.put(item.getUID(), item);
			}

			List<ScheduleItem> newItems = new ArrayList<>();
			List<ScheduleItem> changedItems = new ArrayList<>();
			for (ScheduleItem item : items) {
				ScheduleItem corresponding = oldLookup.get(item.getUID());

				if (corresponding != null) {
					// Item was present the last time -> Check for equality.
					if (!item.equals(corresponding)) {
						// Item changed.
						changedItems.add(item);
					}
				} else {
					newItems.add(item);
				}
			}

			Log.i(TAG, "Found " + newItems.size() + " new items and " + changedItems.size() + " changed items.");

			if (!newItems.isEmpty() || !changedItems.isEmpty()) {
				// Update schedule storage.
				try {
					ScheduleUtil.store(items, getContext());
				} catch (IOException e) {
					return Result.FAILURE;
				}

				// Issue notification that the schedule changed.
				issueNotification(newItems, changedItems);
			}
		}

		return Result.SUCCESS;
	}

	/**
	 * Issue notification that the schedule changed!
	 *
	 * @param newItems new items from the schedule item update
	 * @param changedItems changed items from the schedule item update
	 */
	private void issueNotification(List<ScheduleItem> newItems, List<ScheduleItem> changedItems) {
		Intent resultIntent = new Intent(getContext(), MainActivity.class);
		resultIntent.putExtra(MainActivity.CALL_FRAGMENT_EXTRA, R.id.drawer_action_schedule);

		PendingIntent resultPendingIntent =
				PendingIntent.getActivity(
						getContext(),
						0,
						resultIntent,
						PendingIntent.FLAG_UPDATE_CURRENT
				);

		String title;
		String text;
		if (newItems.size() == 1 && changedItems.isEmpty()) {
			ScheduleEvent event = new ScheduleEvent(newItems.get(0));

			title = getContext().getResources().getString(R.string.newScheduleItem) + ": " + event.getName();
			text = event.getLocation();
		} else {
			title = getContext().getResources().getString(R.string.scheduleChangedTitle);
			text = newItems.size() + " " + getContext().getResources().getString(R.string.scheduleNewItems) + " & " + changedItems.size() + " " + getContext().getResources().getString(R.string.scheduleChangedItems);
		}

		NotificationCompat.Builder notificationBuilder =
				new NotificationCompat.Builder(getContext(), getContext().getString(R.string.channelChanges))
						.setSmallIcon(R.drawable.notification_icon)
						.setContentTitle(title)
						.setContentText(text)
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
		new JobRequest.Builder(TAG)
				.setPeriodic(TimeUnit.MINUTES.toMillis(60), TimeUnit.MINUTES.toMillis(10))
				.setRequiredNetworkType(JobRequest.NetworkType.CONNECTED)
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
		return Preference.WEEK_PLAN_CHANGE_NOTIFICATION_ENABLED.getBoolean(context);
	}

}
