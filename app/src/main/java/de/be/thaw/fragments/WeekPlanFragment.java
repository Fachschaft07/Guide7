package de.be.thaw.fragments;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.RectF;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v7.app.AlertDialog;
import android.support.v7.preference.PreferenceManager;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;

import com.alamkanak.weekview.DateTimeInterpreter;
import com.alamkanak.weekview.MonthLoader;
import com.alamkanak.weekview.WeekView;
import com.alamkanak.weekview.WeekViewEvent;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;
import java.util.concurrent.ExecutionException;

import de.be.thaw.EventDetailActivity;
import de.be.thaw.R;
import de.be.thaw.auth.Authentication;
import de.be.thaw.auth.Credential;
import de.be.thaw.cache.ScheduleUtil;
import de.be.thaw.model.ScheduleEvent;
import de.be.thaw.model.schedule.Schedule;
import de.be.thaw.model.schedule.ScheduleDay;
import de.be.thaw.model.schedule.ScheduleItem;
import de.be.thaw.ui.AlertDialogManager;
import de.be.thaw.ui.ProgressDialogManager;
import de.be.thaw.ui.weekview.WeeklyLoader;
import de.be.thaw.util.ThawUtil;
import de.be.thaw.util.TimeUtil;
import de.be.thaw.connect.zpa.ZPAConnection;
import de.be.thaw.connect.zpa.exception.ZPABadCredentialsException;
import de.be.thaw.connect.zpa.exception.ZPALoginFailedException;

public class WeekPlanFragment extends Fragment implements MainFragment {

	private static final String TAG = "WeekPlanFragment";
	private static final double START_HOUR = 7.0;
	private static final String DATE_CACHE = "de.be.thaw.dateCache";

	/**
	 * Amount of displayable days.
	 */
	private int displayableDays = -1;

	private WeekView weekView;

	private ProgressDialogManager progressDialogManager;
	private AlertDialogManager alertDialogManager;

	public WeekPlanFragment() {
		// Required empty public constructor
	}

	/**
	 * Use this factory method to create a new instance of
	 * this fragment using the provided parameters.
	 *
	 * @return A new instance of fragment WeekPlanFragment.
	 */
	public static WeekPlanFragment newInstance() {
		WeekPlanFragment fragment = new WeekPlanFragment();
		return fragment;
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		ProgressDialog progressDialog = new ProgressDialog(getActivity());
		progressDialog.setIndeterminate(true);
		progressDialog.setMessage(getResources().getString(R.string.loadingMessage));

		progressDialogManager = new ProgressDialogManager(progressDialog);
		alertDialogManager = new AlertDialogManager(new AlertDialog.Builder(getActivity()).create());
	}

	@Override
	public boolean isRefreshable() {
		return true;
	}

	/**
	 * Refresh Schedule.
	 */
	public void refresh() {
		// Clear Schedule Cache
		ScheduleUtil.clear(getActivity());

		weekView.notifyDatasetChanged(); // Causes Loader to reload!
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		// Cache old visible day
		ThawUtil.cachedDate = weekView.getFirstVisibleDay();

		super.onConfigurationChanged(newConfig);
	}

	@Override
	public void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);

		outState.putSerializable(DATE_CACHE, weekView.getFirstVisibleDay());
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		// Inflate the layout for this fragment
		View view = inflater.inflate(R.layout.fragment_week_plan, container, false);

		initialize(view);


		// Restore last visible day.
		if (savedInstanceState != null) {
			Calendar lastVisibleDay = (Calendar) savedInstanceState.getSerializable(DATE_CACHE);

			if (lastVisibleDay != null) {
				weekView.goToDate(lastVisibleDay);
			}
		}

		return view;
	}

	/**
	 * Get Amount of displayable days from settings.
	 *
	 * @return
	 */
	private int getDisplayableDays() {
		if (displayableDays == -1) {
			displayableDays = Integer.parseInt(PreferenceManager.getDefaultSharedPreferences(getContext()).getString("displayedDaysPrefKey", "2"));
		}

		return displayableDays;
	}

	/**
	 * Initialize Week Plan.
	 */
	private void initialize(View view) {
		// Get a reference for the week view in the layout.
		weekView = (WeekView) view.findViewById(R.id.weekView);

		// Initially go to start hour to hide earlier hours.
		weekView.goToHour(START_HOUR);
		weekView.setNumberOfVisibleDays(getDisplayableDays());

		weekView.setWeekViewLoader(new WeeklyLoader(new ZPAWeekChangeListener()));

		// Set an action when any event is clicked.
		weekView.setOnEventClickListener(new WeekView.EventClickListener() {

			@Override
			public void onEventClick(WeekViewEvent event, RectF eventRect) {
				Intent intent = new Intent(getActivity(), EventDetailActivity.class);

				intent.putExtra(EventDetailActivity.EXTRA_NAME, (ScheduleEvent) event);

				startActivity(intent);
			}

		});

		// Set custom date time interpreter to interpret to current locale
		weekView.setDateTimeInterpreter(new DateTimeInterpreter() {

			@Override
			public String interpretDate(Calendar date) {
				if (getDisplayableDays() > 2) {
					return TimeUtil.getShortDateString(date);
				} else {
					return TimeUtil.getDateString(date);
				}
			}

			@Override
			public String interpretTime(int hour) {
				return String.format("%02d:00", hour);
			}

		});

		// Set long press listener for events.
		weekView.setEventLongPressListener(new WeekView.EventLongPressListener() {

			@Override
			public void onEventLongPress(WeekViewEvent event, RectF eventRect) {
				Snackbar.make(getActivity().findViewById(R.id.app_bar_main), event.getName(), Snackbar.LENGTH_SHORT).show();
			}

		});
	}

	/**
	 * Refresh Schedule for the passed month
	 *
	 * @param year
	 * @param month
	 * @param week
	 * @throws ExecutionException
	 * @throws InterruptedException
	 */
	private void refreshSchedule(int year, int month, int week) throws ExecutionException, InterruptedException {
		new LoadScheduleTask(getActivity(), alertDialogManager, progressDialogManager, weekView).execute(year, month, week);
	}

	/**
	 * Task to load schedule asynchronously.
	 */
	private class LoadScheduleTask extends AsyncTask<Integer, Integer, Schedule> {

		private final ProgressDialogManager progress;
		private final AlertDialogManager alertDialogManager;

		private final WeekView weekView;

		private final Activity activity;

		private Exception error;

		private int year;
		private int month;
		private int week;

		public LoadScheduleTask(Activity activity, AlertDialogManager alertDialogManager, ProgressDialogManager progress, WeekView weekView) {
			this.activity = activity;
			this.weekView = weekView;
			this.progress = progress;
			this.alertDialogManager = alertDialogManager;

			progress.addOnCancelListener(new DialogInterface.OnCancelListener() {

				@Override
				public void onCancel(DialogInterface dialog) {
					cancel(true);
				}

			});
		}

		@Override
		protected Schedule doInBackground(Integer... params) {
			year = params[0];
			month = params[1];
			week = params[2];

			Credential credential = Authentication.getCredential(getActivity());

			ZPAConnection connection = null;
			try {
				connection = new ZPAConnection(credential.getUsername(), credential.getPassword());
			} catch (Exception e) {
				e.printStackTrace();

				error = e;
			}

			Schedule schedule = null;
			if (connection != null) {
				try {
					schedule = connection.getWeekplan(year, month, week);
				} catch (Exception e) {
					e.printStackTrace();

					error = e;
				}
			}

			return schedule;
		}

		@Override
		protected void onPreExecute() {
			super.onPreExecute();
			progress.show();
		}

		@Override
		protected void onCancelled(Schedule schedule) {
			super.onCancelled(schedule);

			if (progress.isShowing()) {
				progress.cancel();
			}
		}

		@Override
		protected void onPostExecute(Schedule schedule) {
			super.onPostExecute(schedule);

			if (progress.isShowing()) {
				progress.dismiss();
			}

			if (error != null) {
				// Show error
				String errorMessage = activity.getResources().getString(R.string.parseMonthPlanErrorMessage);
				if (error instanceof ZPABadCredentialsException) {
					errorMessage = getResources().getString(R.string.badLoginMessage);
				} else if (error instanceof ZPALoginFailedException) {
					errorMessage = activity.getResources().getString(R.string.loginErrorMessage);
				}

				alertDialogManager.setMessage(errorMessage);
				alertDialogManager.show();
			}

			if (schedule != null) {
				// Write Schedule to Cache
				try {
					ScheduleUtil.store(schedule, getActivity(), year, month, week);
				} catch (IOException e) {
					e.printStackTrace();
				}


				// Week View Callback
				if (schedule != null) {
					weekView.notifyDatasetChanged();
				}
			}
		}
	}

	/**
	 * Month Changelistener to load months from ZPA.
	 */
	private class ZPAWeekChangeListener implements WeeklyLoader.WeekChangeListener {

		@Override
		public List<? extends WeekViewEvent> onWeekChange(int newYear, int newMonth, int newWeek) {
			ArrayList<ScheduleEvent> events = new ArrayList<>();

			Schedule schedule = null;
			try {
				schedule = ScheduleUtil.retrieve(getActivity(), newYear, newMonth, newWeek);
			} catch (IOException e) {
				e.printStackTrace();
			}

			if (schedule == null) {
				try {
					refreshSchedule(newYear, newMonth, newWeek);
				} catch (Exception e) {
					e.printStackTrace();
				}
			}

			if (schedule != null) {
				// Create Events
				for (ScheduleDay day : schedule.getWeekdays()) {
					if (day != null) {
						for (ScheduleItem item : day.getItems()) {
							if (item != null) {
								events.add(new ScheduleEvent(item));
							}
						}
					}
				}
			}

			return events;
		}

	}

}
