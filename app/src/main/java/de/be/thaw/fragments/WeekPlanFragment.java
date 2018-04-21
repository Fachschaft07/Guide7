package de.be.thaw.fragments;

import android.app.Activity;
import android.app.ProgressDialog;
import android.appwidget.AppWidgetManager;
import android.content.ComponentName;
import android.content.DialogInterface;
import android.content.Intent;
import android.content.res.Configuration;
import android.graphics.RectF;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.design.widget.Snackbar;
import android.support.v4.app.Fragment;
import android.support.v7.app.AlertDialog;
import android.support.v7.preference.PreferenceManager;
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

import de.be.thaw.CreateCustomEntryActivity;
import de.be.thaw.EventDetailActivity;
import de.be.thaw.R;
import de.be.thaw.auth.Auth;
import de.be.thaw.auth.Credential;
import de.be.thaw.auth.exception.NoUserStoredException;
import de.be.thaw.model.schedule.custom.CustomEntry;
import de.be.thaw.model.schedule.custom.CustomScheduleItem;
import de.be.thaw.model.schedule.custom.CustomScheduler;
import de.be.thaw.storage.CustomEntryUtil;
import de.be.thaw.storage.cache.ScheduleUtil;
import de.be.thaw.connect.zpa.ZPAConnection;
import de.be.thaw.connect.zpa.exception.ZPABadCredentialsException;
import de.be.thaw.connect.zpa.exception.ZPALoginFailedException;
import de.be.thaw.model.ScheduleEvent;
import de.be.thaw.model.schedule.ScheduleItem;
import de.be.thaw.ui.AlertDialogManager;
import de.be.thaw.ui.LoadSnackbar;
import de.be.thaw.util.Preference;
import de.be.thaw.util.ThawUtil;
import de.be.thaw.util.TimeUtil;
import de.be.thaw.widget.ScheduleWidgetProvider;

public class WeekPlanFragment extends Fragment implements MainFragment {

	private static final String TAG = "WeekPlanFragment";
	private static final double START_HOUR = 7.0;
	private static final String DATE_CACHE = "de.be.thaw.dateCache";

	/**
	 * Amount of displayable days.
	 */
	private int displayableDays = -1;

	private WeekView weekView;

	private LoadSnackbar loadSnackbar;
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
		return new WeekPlanFragment();
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		ProgressDialog progressDialog = new ProgressDialog(getActivity());
		progressDialog.setIndeterminate(true);
		progressDialog.setMessage(getResources().getString(R.string.loadingMessage));

		alertDialogManager = new AlertDialogManager(new AlertDialog.Builder(getActivity()).create());
	}

	@Override
	public boolean isRefreshable() {
		return true;
	}

	@Override
	public boolean isAddable() {
		return true;
	}

	/**
	 * Refresh Schedule.
	 */
	public void onRefresh() {
		try {
			refreshSchedule();
		} catch (ExecutionException | InterruptedException e) {
			e.printStackTrace();
		}

		weekView.notifyDatasetChanged(); // Causes Loader to reload!
		updateWidget();
	}

	@Override
	public void onAdd() {
		Intent intent = new Intent(getActivity(), CreateCustomEntryActivity.class);

		startActivityForResult(intent, 1);
	}

	@Override
	public void onActivityResult(int requestCode, int resultCode, Intent data) {
		super.onActivityResult(requestCode, resultCode, data);

		if (requestCode != 1 || data == null) {
			return;
		}
		CustomEntry ce = data.getParcelableExtra(CreateCustomEntryActivity.EXTRA_NAME);
		List<CustomScheduleItem> list = CustomScheduler.createScheduleItems(ce);
		try {
			CustomEntryUtil.append(list, getContext());
		} catch (Exception e) {
			e.printStackTrace();
		}
		weekView.notifyDatasetChanged();
		updateWidget();
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		// Cache old visible day
		ThawUtil.cachedDate = weekView.getFirstVisibleDay();

		super.onConfigurationChanged(newConfig);
	}

	@Override
	public void onSaveInstanceState(@NonNull Bundle outState) {
		super.onSaveInstanceState(outState);

		outState.putSerializable(DATE_CACHE, weekView.getFirstVisibleDay());
	}

	@Override
	public View onCreateView(@NonNull LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
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
			displayableDays = Preference.DISPLAYED_DAYS.getInteger(getContext());
			System.out.println("DISP" + displayableDays);
		}

		return displayableDays;
	}

	/**
	 * Whether to show cancelled events.
	 *
	 * @return
	 */
	private boolean showCancelledEvents() {
		return PreferenceManager.getDefaultSharedPreferences(getContext()).getBoolean("showCancelledEvents", true);
	}

	/**
	 * Get the appropriate color for a weekplan item.
	 *
	 * @param item
	 * @return
	 */
	private int getColorForItem(ScheduleItem item) {
		if (item.isEventCancelled()) {
			return getResources().getColor(R.color.eventColorCancelled);
		} if (item instanceof CustomScheduleItem) {
			return getResources().getColor(R.color.eventColorCustom);
		} else {
			// Default color
			return getResources().getColor(R.color.colorPrimary);
		}
	}

	/**
	 * Initialize Week Plan.
	 */
	private void initialize(View view) {
		// Get a reference for the week view in the layout.
		weekView = view.findViewById(R.id.weekView);

		// Initially go to start hour to hide earlier hours.
		weekView.goToHour(START_HOUR);
		weekView.setNumberOfVisibleDays(getDisplayableDays());

		weekView.setMonthChangeListener(new MonthLoader.MonthChangeListener() {

			@Override
			public List<? extends WeekViewEvent> onMonthChange(int newYear, int newMonth) {
				List<ScheduleItem> items = null;

				try {
					items = ScheduleUtil.retrieve(getContext());
					items.addAll(CustomEntryUtil.retrieve(getContext()));
				} catch (IOException e) {
					e.printStackTrace();
				}

				List<ScheduleEvent> events = new ArrayList<>();

				if (items != null && !items.isEmpty()) {
					for (ScheduleItem item : items) {
						// Restrict to items of the given month.
						if (item != null && item.getStart() != null && item.getStart().getMonth() == newMonth - 1) {
							ScheduleEvent event = new ScheduleEvent(item);
							event.setColor(getColorForItem(item));

							if (item.isEventCancelled()) {
								if (showCancelledEvents()) {
									events.add(event);
								}
							} else {
								events.add(event);
							}
						}
					}
				}

				return events;
			}

		});

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
				final ScheduleEvent se = (ScheduleEvent) event;
				if (se.getItem() instanceof CustomScheduleItem) {
					AlertDialog.Builder builder = new AlertDialog.Builder(getActivity());
					builder.setItems(R.array.custom_entry_options, new DialogInterface.OnClickListener() {
							public void onClick(DialogInterface dialog, int which) {
								try {
									if (which == 0) {
										CustomEntryUtil.removeSingleEntry(se.getItem().getUID(), getContext());

									} else {
										CustomEntryUtil.removeEntries(((CustomScheduleItem) se.getItem()).getParentUID(), getContext());
									}

								} catch (IOException e) {
									e.printStackTrace();
								}
								weekView.notifyDatasetChanged();
								updateWidget();
							}
					});
					builder.create().show();
				}
			}

		});

		loadSnackbar = new LoadSnackbar(Snackbar.make(getActivity().findViewById(R.id.content_frame), "Stundenplan wird heruntergeladen...", Snackbar.LENGTH_INDEFINITE));

		// Initialize Schedule.
		initializeSchedule();
	}

	/**
	 * Initialize schedule by loading cached events or load from server.
	 */
	private void initializeSchedule() {
		List<ScheduleItem> items;

		try {
			items = ScheduleUtil.retrieve(getContext());
		} catch (IOException e) {
			e.printStackTrace();
			return;
		}

		if (items.isEmpty()) {
			try {
				refreshSchedule();
			} catch (ExecutionException | InterruptedException e) {
				e.printStackTrace();
			}
		}
	}

	/**
	 * Notifying widgets of charged data set.
	 */
	private void updateWidget() {
		Intent intent = new Intent(this.getContext(), ScheduleWidgetProvider.class);
		intent.setAction(AppWidgetManager.ACTION_APPWIDGET_UPDATE);
		int[] ids = AppWidgetManager.getInstance(getContext())
				.getAppWidgetIds(new ComponentName(getActivity().getApplication(), ScheduleWidgetProvider.class));
		intent.putExtra(AppWidgetManager.EXTRA_APPWIDGET_IDS, ids);
		getActivity().sendBroadcast(intent);
	}

	/**
	 * Refresh Schedule
	 * @throws ExecutionException
	 * @throws InterruptedException
	 */
	private void refreshSchedule() throws ExecutionException, InterruptedException {
		new LoadScheduleTask(getActivity(), alertDialogManager, weekView, loadSnackbar).execute();
	}

	/**
	 * Task to load schedule asynchronously.
	 */
	private class LoadScheduleTask extends AsyncTask<Integer, Integer, List<ScheduleItem>> {

		private final AlertDialogManager alertDialogManager;

		private final WeekView weekView;
		private final LoadSnackbar snackbar;

		private final Activity activity;

		private Exception error;

		LoadScheduleTask(Activity activity, AlertDialogManager alertDialogManager, WeekView weekView, LoadSnackbar snackbar) {
			this.activity = activity;
			this.weekView = weekView;
			this.alertDialogManager = alertDialogManager;
			this.snackbar = snackbar;
		}

		@Override
		protected List<ScheduleItem> doInBackground(Integer... params) {
			Credential credential;
			try {
				credential = Auth.getInstance().getCurrentUser(getContext()).getCredential();
			} catch (NoUserStoredException e) {
				error = e;
				return null;
			}

			ZPAConnection connection;
			try {
				connection = new ZPAConnection(credential.getUsername(), credential.getPassword());
			} catch (Exception e) {
				error = e;
				return null;
			}

			List<ScheduleItem> items;
			try {
				items = connection.getRSSWeekplan();
			} catch (Exception e) {
				error = e;
				return null;
			}

			return items;
		}

		@Override
		protected void onPreExecute() {
			super.onPreExecute();

			snackbar.show();
		}

		@Override
		protected void onCancelled(List<ScheduleItem> items) {
			super.onCancelled(items);

			snackbar.dismiss();
		}

		@Override
		protected void onPostExecute(List<ScheduleItem> items) {
			super.onPostExecute(items);

			snackbar.dismiss();

			if (error != null) {
				// Show error
				String errorMessage = activity.getResources().getString(R.string.parseMonthPlanErrorMessage);
				if (error instanceof ZPABadCredentialsException) {
					errorMessage = activity.getResources().getString(R.string.badLoginMessage);
				} else if (error instanceof ZPALoginFailedException) {
					errorMessage = activity.getResources().getString(R.string.loginErrorMessage);
				}

				alertDialogManager.setMessage(errorMessage);
				alertDialogManager.show();
			}

			if (items != null) {
				// Write Schedule to Cache
				try {
					List<ScheduleItem> list = new ArrayList<>();
					for (ScheduleItem item : items) {
						if (!(item instanceof CustomScheduleItem)) {
							list.add(item);
						}
					}
					ScheduleUtil.store(list, activity);
				} catch (IOException e) {
					e.printStackTrace();
				}


				// Week View Callback
				weekView.notifyDatasetChanged();
				updateWidget();
			}
		}
	}
}
