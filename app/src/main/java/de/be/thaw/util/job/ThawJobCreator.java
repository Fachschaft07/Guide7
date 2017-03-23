package de.be.thaw.util.job;

import com.evernote.android.job.Job;
import com.evernote.android.job.JobCreator;

import de.be.thaw.util.job.jobs.StaticWeekPlanNotificationJob;
import de.be.thaw.util.job.jobs.UpdateNoticeBoardJob;

/**
 * The Job Creator is mapping a Job Tag to a specific Job class.
 * <p>
 * Created by Benjamin Eder on 17.03.2017.
 */
public class ThawJobCreator implements JobCreator {

	@Override
	public Job create(String tag) {
		switch (tag) {
			case UpdateNoticeBoardJob.TAG:
				return new UpdateNoticeBoardJob();

			case StaticWeekPlanNotificationJob.TAG:
				return new StaticWeekPlanNotificationJob();

			// Add more here if you need another background job! :)

			default:
				return null;
		}
	}
}
