package de.be.thaw.util.job.jobs;

import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.Intent;
import android.support.annotation.NonNull;
import android.util.Log;

import com.evernote.android.job.Job;
import com.evernote.android.job.JobManager;
import com.evernote.android.job.JobRequest;

import de.be.thaw.widget.ScheduleWidgetProvider;

public class UpdateScheduleWidget extends Job {

    private static int runningJobId = -1;

    public static final String TAG = "UpdateScheduleWidgetJob";

    @NonNull
    @Override
    protected Result onRunJob(Params params) {
        Intent intent = new Intent(this.getContext(), ScheduleWidgetProvider.class);
        intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
        int[] ids = AppWidgetManager.getInstance(getContext())
                .getAppWidgetIds(new ComponentName(getContext(), ScheduleWidgetProvider.class));
        intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids);
        getContext().sendBroadcast(intent);
        runningJobId = -1;
        return Result.SUCCESS;
    }

    /**
     * Schedule new job instance, removing all currently scheduled jobs.
     * @param millisToWait start delay in milliseconds
     */
    public static synchronized void scheduleJob(long millisToWait) {
        if (runningJobId != -1) {
            JobManager.instance().cancelAllForTag(TAG);
            Log.i(TAG, "Cancelling jobs");
        }
        runningJobId = new JobRequest.Builder(TAG)
                .setExact(millisToWait)
                .build()
                .schedule();
        Log.i(TAG, "Scheduled new job");
    }
}
