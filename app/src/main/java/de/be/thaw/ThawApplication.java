package de.be.thaw;

import android.app.Application;

import com.evernote.android.job.JobManager;

import de.be.thaw.util.job.ThawJobCreator;

/**
 * Created by Benjamin Eder on 17.03.2017.
 */

public class ThawApplication extends Application {

	@Override
	public void onCreate() {
		super.onCreate();
		JobManager.create(this).addJobCreator(new ThawJobCreator());
	}

}
