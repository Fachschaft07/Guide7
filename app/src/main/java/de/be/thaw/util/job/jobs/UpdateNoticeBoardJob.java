package de.be.thaw.util.job.jobs;

import android.app.Notification;
import android.app.NotificationManager;
import android.app.PendingIntent;
import android.content.Context;
import android.content.Intent;
import android.graphics.Color;
import android.media.RingtoneManager;
import android.net.Uri;
import android.provider.Settings;
import android.support.annotation.NonNull;
import android.support.v4.app.NotificationCompat;
import android.util.Log;

import com.evernote.android.job.Job;
import com.evernote.android.job.JobRequest;

import java.io.IOException;
import java.util.HashSet;
import java.util.Set;
import java.util.concurrent.TimeUnit;

import de.be.thaw.MainActivity;
import de.be.thaw.R;
import de.be.thaw.cache.BoardUtil;
import de.be.thaw.model.noticeboard.BoardEntry;
import de.be.thaw.util.TimeUtil;
import de.be.thaw.zpa.ZPAConnection;

/**
 * Recurring Task which is checking for Notice board changes by updating and
 * comparing.
 *
 * Created by Benjamin Eder on 17.03.2017.
 */
public class UpdateNoticeBoardJob extends Job {

	public static final String TAG = "UpdateNoticeBoardJob";

	@NonNull
	@Override
	protected Result onRunJob(Params params) {
		// Fetch new notice board entries!
		ZPAConnection connection = new ZPAConnection();

		BoardEntry[] entries = null;
		try {
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

		// Move old Entries in an entry set for easy title comparison.
		Set<String> entrySet = new HashSet<>();
		for (BoardEntry entry : oldEntries) {
			entrySet.add(entry.getTitle());
		}

		// Check for new ones or changed ones.
		boolean noticeBoardChanged = false;
		for (BoardEntry entry : entries) {
			if (!entrySet.contains(entry.getTitle())) {
				noticeBoardChanged = true;
				break;
			}
		}

		if (noticeBoardChanged) {
			// Update notice board file
			try {
				BoardUtil.store(entries, getContext());
			} catch (IOException e) {
				return Result.FAILURE;
			}

			// Issue notification that the notice board changed.
			issueNotification();
		}

		return Result.SUCCESS;
	}

	/**
	 * Issue notification that the notice board changed!
	 */
	private void issueNotification() {
		Intent resultIntent = new Intent(getContext(), MainActivity.class);
		resultIntent.putExtra(MainActivity.CALL_FRAGMENT_EXTRA, R.id.drawer_action_blackboard);

		PendingIntent resultPendingIntent =
				PendingIntent.getActivity(
						getContext(),
						0,
						resultIntent,
						PendingIntent.FLAG_UPDATE_CURRENT
				);

		NotificationCompat.Builder notificationBuilder =
				new NotificationCompat.Builder(getContext())
						.setSmallIcon(R.drawable.notification_icon)
						.setContentTitle(getContext().getResources().getString(R.string.noticeBoardChangedNotificationTitle))
						.setContentText(getContext().getResources().getString(R.string.noticeBoardChangedNotificationMessage))
						.setContentIntent(resultPendingIntent)
						.setDefaults(Notification.DEFAULT_SOUND | Notification.DEFAULT_VIBRATE | Notification.DEFAULT_LIGHTS)
						.setAutoCancel(true);

		NotificationManager notificationManager = (NotificationManager) getContext().getSystemService(Context.NOTIFICATION_SERVICE);
		notificationManager.notify(1, notificationBuilder.build());
	}

	/**
	 * Schedule the job to be executed.
	 */
	public static void scheduleJob() {
		new JobRequest.Builder(UpdateNoticeBoardJob.TAG)
				.setPeriodic(TimeUnit.MINUTES.toMillis(60), TimeUnit.MINUTES.toMillis(10))
				.setRequiredNetworkType(JobRequest.NetworkType.CONNECTED)
				.setUpdateCurrent(true)
				.build()
				.schedule();
	}

}
