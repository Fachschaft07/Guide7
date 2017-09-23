package de.be.thaw.fragments;

import android.app.Activity;
import android.app.ProgressDialog;
import android.content.Context;
import android.content.res.Configuration;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AlertDialog;
import android.text.Editable;
import android.text.Spanned;
import android.text.TextWatcher;
import android.text.method.LinkMovementMethod;
import android.util.Log;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.Button;
import android.widget.EditText;
import android.widget.Filter;
import android.widget.Filterable;
import android.widget.ListView;
import android.widget.TextView;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import de.be.thaw.R;
import de.be.thaw.cache.AppointmentUtil;
import de.be.thaw.connect.fk07.FK07Connection;
import de.be.thaw.connect.parser.fk07.AppointmentsParser;
import de.be.thaw.model.appointments.Appointment;
import de.be.thaw.util.ThawUtil;

public class AppointmentFragment extends Fragment implements MainFragment {

	private static final String TAG = "AppointmentFragment";

	/**
	 * Object containing the items for the list view.
	 */
	private AppointmentAdapter appointmentAdapter;

	/**
	 * Layout responsible for pull to refresh.
	 */
	private SwipeRefreshLayout swipeContainer;

	private EditText filterField;

	public AppointmentFragment() {
		// Required empty public constructor
	}

	/**
	 * Use this factory method to create a new instance of
	 * this fragment using the provided parameters.
	 *
	 * @return
	 */
	public static AppointmentFragment newInstance() {
		AppointmentFragment fragment = new AppointmentFragment();

		return fragment;
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
	}

	@Override
	public boolean isRefreshable() {
		return true;
	}

	/**
	 * Refresh Fragment.
	 */
	public void refresh() {
		new GetAppointmentsTask(getContext()).execute();
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
	}

	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		// Inflate the layout for this fragment
		View view = inflater.inflate(R.layout.fragment_appointments, container, false);

		appointmentAdapter = new AppointmentAdapter(getActivity());

		// Initialize Views
		swipeContainer = (SwipeRefreshLayout) view.findViewById(R.id.boardlist_swipe_layout);
		swipeContainer.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {

			@Override
			public void onRefresh() {
				refresh();
			}

		});
		swipeContainer.setColorSchemeResources(android.R.color.holo_blue_bright,
				android.R.color.holo_green_light,
				android.R.color.holo_orange_light,
				android.R.color.holo_red_light);

		ListView boardList = (ListView) view.findViewById(R.id.boardlist);
		boardList.setAdapter(appointmentAdapter);


		final Button resetFilterButton = (Button) view.findViewById(R.id.appointment_filter_remove);
		resetFilterButton.setVisibility(Button.INVISIBLE);
		resetFilterButton.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View view) {
				onResetFilter(view);
			}

		});

		filterField = (EditText) view.findViewById(R.id.appointment_filter);
		filterField.addTextChangedListener(new TextWatcher() {

			@Override
			public void beforeTextChanged(CharSequence charSequence, int i, int i1, int i2) {

			}

			@Override
			public void onTextChanged(CharSequence charSequence, int i, int i1, int i2) {
				appointmentAdapter.getFilter().filter(charSequence);

				resetFilterButton.setVisibility(charSequence != null && charSequence.length() > 0 ? Button.VISIBLE : Button.INVISIBLE);
			}

			@Override
			public void afterTextChanged(Editable editable) {

			}

		});

		// Initialize board list
		updateAppointments(null);

		return view;
	}

	/**
	 * Reset the filter.
	 *
	 * @param view
	 */
	public void onResetFilter(View view) {
		filterField.setText("");
	}

	/**
	 * Update the appointment entries.
	 *
	 * @param appointments
	 */
	private void updateAppointments(Appointment[] appointments) {
		if (appointments == null) { // Retrieve from Storage
			try {
				appointments = AppointmentUtil.retrieve(getContext());
			} catch (IOException e) {
				e.printStackTrace();
			}

			if (appointments == null) { // When there are still no menus -> Update from Server
				refresh();
			}
		} else { // Store
			try {
				AppointmentUtil.store(appointments, getContext());
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		if (appointments != null) {
			// Only add apointments which are in the current month or future.
			List<Appointment> appointmentList = new ArrayList<>();

			Calendar now = Calendar.getInstance();
			resetCalendarToMonth(now);

			for (Appointment appointment : appointments) {
				Calendar appointmentMonth = appointment.getDate();
				resetCalendarToMonth(appointmentMonth);

				if (appointmentMonth.getTimeInMillis() - now.getTimeInMillis() >= 0) { // Check if present or future month
					appointmentList.add(appointment);
				}
			}

			// Apply appointments
			appointmentAdapter.clear();
			appointmentAdapter.addAll(appointmentList);
		}
	}

	/**
	 * Resets a passed calendar to have nothing but the year and month set.
	 * @param calendar
	 */
	private void resetCalendarToMonth(Calendar calendar) {
		calendar.set(Calendar.DAY_OF_MONTH, 1);
		calendar.set(Calendar.HOUR_OF_DAY, 0);
		calendar.set(Calendar.MINUTE, 0);
		calendar.set(Calendar.SECOND, 0);
		calendar.set(Calendar.MILLISECOND, 0);
	}

	/**
	 * Async task to get all appointments.
	 */
	private class GetAppointmentsTask extends AsyncTask<Void, Integer, Appointment[]> {

		private ProgressDialog progress;
		private Context context;
		private Exception e;

		public GetAppointmentsTask(Context context) {
			this.context = context;

			progress = new ProgressDialog(context);
			progress.setIndeterminate(true);
			progress.setMessage(context.getResources().getString(R.string.searchingForAppointments));
		}

		@Override
		protected void onPreExecute() {
			super.onPreExecute();

			if (!swipeContainer.isRefreshing()) {
				progress.show();
			}
		}

		@Override
		protected Appointment[] doInBackground(Void... params) {
			FK07Connection connection = new FK07Connection();

			Appointment[] appointments = null;
			try {
				appointments = connection.getAppointments();
			} catch (Exception e) {
				e.printStackTrace();
				this.e = e;
			}

			return appointments;
		}

		@Override
		protected void onCancelled() {
			super.onCancelled();

			if (progress.isShowing()) {
				progress.dismiss();
			}

			swipeContainer.setRefreshing(false);
		}

		@Override
		protected void onPostExecute(final Appointment[] appointments) {
			super.onPostExecute(appointments);

			if (progress.isShowing()) {
				progress.dismiss();
			}

			swipeContainer.setRefreshing(false);

			if (e != null) {
				new AlertDialog.Builder(context).setMessage(context.getResources().getString(R.string.appointmentLoadingError)).show();
			}

			if (appointments != null) {
				getActivity().runOnUiThread(new Runnable() {

					@Override
					public void run() {
						updateAppointments(appointments);
					}

				});
			}
		}

	}

	/**
	 * Custom adapter to display appointment entries.
	 */
	private class AppointmentAdapter extends ArrayAdapter<Appointment> implements Filterable {

		private final Context context;

		/**
		 * List holding all appointments.
		 */
		private List<Appointment> model = new ArrayList<>();

		/**
		 * Cache for parsed HTML contents.
		 */
		private Map<Integer, Spanned> contentChache = new HashMap<>();

		/**
		 * List of filtered indices.
		 */
		private List<Integer> filtered;

		private Filter filter;

		public AppointmentAdapter(Context context) {
			super(context, -1);
			this.context = context;
		}

		@Override
		public int getCount() {
			return filtered == null ? model.size() : filtered.size();
		}

		@Override
		public Appointment getItem(int index) {
			return filtered == null ? model.get(index) : model.get(filtered.get(index));
		}

		@Override
		public long getItemId(int index) {
			return index;
		}

		@NonNull
		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			ViewHolder holder = null;

			if (convertView == null) {
				holder = new ViewHolder();

				LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
				convertView = inflater.inflate(R.layout.appointment_entry, parent, false);

				holder.monthView = (TextView) convertView.findViewById(R.id.appointment_entry_month);
				holder.timeSpanView = (TextView) convertView.findViewById(R.id.appointment_entry_timeSpan);
				holder.descriptionView = (TextView) convertView.findViewById(R.id.appointment_entry_description);

				convertView.setTag(holder);

				/*
				 * Make HTML links clickable.
				 */
				holder.descriptionView.setMovementMethod(LinkMovementMethod.getInstance());
			} else {
				holder = (ViewHolder) convertView.getTag();
			}

			final Appointment appointment = getItem(position);

			holder.monthView.setText(AppointmentsParser.MONTH_YEAR_FORMAT.format(appointment.getDate().getTime()));
			holder.timeSpanView.setText(appointment.getTimeSpan());

			Spanned description = contentChache.get(position);
			if (description == null) {
				description = ThawUtil.fromHTML(appointment.getDescription());
				contentChache.put(position, description);
			}
			holder.descriptionView.setText(description);

			return convertView;
		}

		@NonNull
		@Override
		public Filter getFilter() {
			if (filter == null) {
				filter = new AppointmentFilter();
			}

			return filter;
		}

		/**
		 * Clear the Adapter model.
		 */
		public void clear() {
			model.clear();
		}

		/**
		 * Add all passed appointments to adapter.
		 *
		 * @param appointmentList
		 */
		public void addAll(List<Appointment> appointmentList) {
			model.addAll(appointmentList);
		}

		@Override
		public void notifyDataSetChanged() {
			super.notifyDataSetChanged();

			clearCache();
		}

		/**
		 * Clear cached contents.
		 */
		private void clearCache() {
			contentChache.clear();
		}

		/**
		 * View holder for appointment entries.
		 */
		private class ViewHolder {

			TextView monthView;
			TextView timeSpanView;
			TextView descriptionView;

		}

		/**
		 * Filter filtering appointments.
		 */
		private class AppointmentFilter extends Filter {

			@Override
			protected FilterResults performFiltering(CharSequence constraint) {
				FilterResults results = new FilterResults();

				if (constraint == null && constraint.length() == 0) {
					results.count = 0;
					results.values = null;
				} else {
					String filter = constraint.toString().toLowerCase();
					List<Integer> filteredIndices = new ArrayList<>();

					for (int i = 0; i < model.size(); i++) {
						Appointment appointment = model.get(i);

						if (appointment.getDescription().toLowerCase().contains(filter)
								|| appointment.getTimeSpan().toLowerCase().contains(filter)
								|| AppointmentsParser.MONTH_YEAR_FORMAT.format(appointment.getDate().getTime()).toLowerCase().contains(filter)) {
							filteredIndices.add(i);
						}
					}

					results.count = filteredIndices.size();
					results.values = filteredIndices;

					String debugTest = "Found results: \n";
					for (int result : filteredIndices) {
						debugTest += model.get(result).getDescription() + "\n";
					}

					Log.i("FILTERAPPOINTMENTS", debugTest);
				}

				return results;
			}

			@Override
			protected void publishResults(CharSequence charSequence, FilterResults filterResults) {
				Log.i("FILTERAPPOINTMENTS", charSequence + " -> " + filterResults.values);
				filtered = (List<Integer>) filterResults.values;
				notifyDataSetChanged();
			}

		}

	}

}
