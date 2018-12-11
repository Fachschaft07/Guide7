package de.be.thaw;

import android.content.Intent;
import android.icu.text.DateFormat;
import android.icu.text.SimpleDateFormat;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.util.Log;
import android.view.MenuItem;
import android.widget.TextView;

import de.be.thaw.model.ScheduleEvent;
import de.be.thaw.util.ThawUtil;
import de.be.thaw.util.TimeUtil;

public class EventDetailActivity extends AppCompatActivity {

	public static final String EXTRA_NAME = "de.be.thaw.eventExtra";

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_event_detail);

		Intent intent = getIntent();
		ScheduleEvent event = intent.getParcelableExtra(EXTRA_NAME);

		TextView nameView = (TextView) findViewById(R.id.eventName);
		TextView locationView = (TextView) findViewById(R.id.locationView);
		TextView timeView = (TextView) findViewById(R.id.timeView);

		nameView.setText(event.getName());
		locationView.setText(event.getLocation());
		timeView.setText(TimeUtil.getTimeString(event.getStartTime()) + " - " + TimeUtil.getTimeString(event.getEndTime()));
	}

}
