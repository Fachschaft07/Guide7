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
import de.be.thaw.MainActivity;
import de.be.thaw.R;
import de.be.thaw.auth.Auth;
import de.be.thaw.auth.Credential;
import de.be.thaw.auth.exception.NoUserStoredException;
import de.be.thaw.connect.zpa.ZPAConnection;
import de.be.thaw.model.noticeboard.BoardEntry;
import de.be.thaw.storage.cache.BoardUtil;
import de.be.thaw.util.Preference;

import java.io.IOException;
import java.util.ArrayList;
import java.util.HashSet;
import java.util.List;
import java.util.Set;
import java.util.concurrent.TimeUnit;

/**
 * Recurring Task which is checking for Notice board changes by updating and
 * comparing.
 *
 * Created by Benjamin Eder on 17.03.2017.
 */
public class UpdateNoticeBoardJob extends Job {

	public static final String TAG = "UpdateNoticeBoardJob";
	public static final int NOTIFICATION_ID = 1;

	@NonNull
	@Override
	protected Result onRunJob(Params params) {
		// Fetch new notice board entries!
		Credential credential = null;
		try {
			credential = Auth.getInstance().getCurrentUser(getContext()).getCredential();
		} catch (NoUserStoredException e) {
			e.printStackTrace();
		}

		BoardEntry[] entries = null;
		try {
			ZPAConnection connection = new ZPAConnection(credential.getUsername(), credential.getPassword());
			entries = connection.getBoardNews();
		} catch (Exception e) {
			e.printStackTrace();
			return Result.FAILURE;
		}

		// Compare old and new entries
		BoardEntry[] oldEntries = null;
		try {
			oldEntries = BoardUtil.retrieve(getContext());
		} catch (IOException e) {
			e.printStackTrace();
			return Result.FAILURE;
		}

		Set<BoardEntry> oldEntryLookup = new HashSet<>();
		for (BoardEntry e : oldEntries) {
			oldEntryLookup.add(e);
		}

		// Check for new ones or changed ones.
		List<BoardEntry> newEntries = new ArrayList<>();
		for (BoardEntry entry : entries) {
			if (!oldEntryLookup.contains(entry)) {
				newEntries.add(entry);
			}
		}

		if (!newEntries.isEmpty()) {
			// Update notice board file
			try {
				BoardUtil.store(entries, getContext());
			} catch (IOException e) {
				return Result.FAILURE;
			}

			// Issue notification that the notice board changed.
			issueNotification(newEntries);
		}

		return Result.SUCCESS;
	}

	/**
	 * Issue notification that the notice board changed!
	 * @param newEntries
	 */
	private void issueNotification(List<BoardEntry> newEntries) {
		Intent resultIntent = new Intent(getContext(), MainActivity.class);
		resultIntent.putExtra(MainActivity.CALL_FRAGMENT_EXTRA, R.id.drawer_action_blackboard);

		PendingIntent resultPendingIntent =
				PendingIntent.getActivity(
						getContext(),
						0,
						resultIntent,
						PendingIntent.FLAG_UPDATE_CURRENT
				);

		String text;
		if (newEntries.size() == 1) {
			text = newEntries.get(0).getTitle();
		} else {
			text = newEntries.size() + " " + getContext().getResources().getString(R.string.noticeBoardChangedNotificationMessage);
		}

		NotificationCompat.Builder notificationBuilder =
				new NotificationCompat.Builder(getContext(), getContext().getString(R.string.channelChanges))
						.setSmallIcon(R.drawable.notification_icon)
						.setContentTitle(getContext().getResources().getString(R.string.noticeBoardChangedNotificationTitle))
						.setContentText(text)
						.setContentIntent(resultPendingIntent)
						.setDefaults(Notification.DEFAULT_SOUND | Notification.DEFAULT_VIBRATE | Notification.DEFAULT_LIGHTS)
						.setAutoCancel(true)
						.setStyle(new NotificationCompat.BigTextStyle()
								.bigText(text))
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
		return Preference.NOTICE_BOARD_CHANGE_NOTIFICATION_ENABLED.getBoolean(context);
	}

}
