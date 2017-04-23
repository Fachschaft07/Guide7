package de.be.thaw.fragments;

import android.app.ProgressDialog;
import android.content.Context;
import android.content.res.Configuration;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v4.widget.SwipeRefreshLayout;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.LinearLayout;
import android.widget.ListView;
import android.widget.TextView;

import com.joanzapata.iconify.widget.IconTextView;

import org.w3c.dom.Text;

import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import de.be.thaw.R;
import de.be.thaw.cache.AppointmentUtil;
import de.be.thaw.connect.fk07.FK07Connection;
import de.be.thaw.connect.parser.canteen.MenuParser;
import de.be.thaw.connect.parser.fk07.AppointmentsParser;
import de.be.thaw.model.appointments.Appointment;
import de.be.thaw.model.canteen.Meal;
import de.be.thaw.model.canteen.Menu;

public class AppointmentFragment extends Fragment implements MainFragment {

	private static final String TAG = "AppointmentFragment";

	/**
	 * Object containing the items for the list view.
	 */
	private ArrayAdapter<Appointment> arrayAdapter;

	/**
	 * Layout responsible for pull to refresh.
	 */
	private SwipeRefreshLayout swipeContainer;

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

		arrayAdapter = new AppointmentArrayAdapter(getActivity());

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
		boardList.setAdapter(arrayAdapter);

		// Initialize board list
		updateAppointments(null);

		return view;
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
			now.set(Calendar.DAY_OF_MONTH, 1);
			now.set(Calendar.HOUR_OF_DAY, 0);
			now.set(Calendar.MINUTE, 0);
			now.set(Calendar.SECOND, 0);
			now.set(Calendar.MILLISECOND, 0);

			for (Appointment appointment : appointments) {
				Calendar appointmentMonth =  appointment.getMonth();

				if (appointmentMonth.getTimeInMillis() - now.getTimeInMillis() >= 0) { // Check if present or future month
					appointmentList.add(appointment);
				}
			}

			// Apply appointments
			arrayAdapter.clear();
			arrayAdapter.addAll(appointmentList);
		}
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
		protected void onPostExecute(Appointment[] appointments) {
			super.onPostExecute(appointments);

			if (progress.isShowing()) {
				progress.dismiss();
			}

			swipeContainer.setRefreshing(false);

			if (e != null) {
				new AlertDialog.Builder(context).setMessage(context.getResources().getString(R.string.appointmentLoadingError)).show();
			}

			if (appointments != null) {
				updateAppointments(appointments);
			}
		}

	}

	/**
	 * Custom adapter to display menu entries.
	 */
	private class AppointmentArrayAdapter extends ArrayAdapter<Appointment> {

		private final Context context;

		public AppointmentArrayAdapter(Context context) {
			super(context, -1);
			this.context = context;
		}

		@NonNull
		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			final Appointment appointment = getItem(position);

			LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			View view = inflater.inflate(R.layout.appointment_entry, parent, false);

			TextView monthView = (TextView) view.findViewById(R.id.appointment_entry_month);
			TextView timeSpanView = (TextView) view.findViewById(R.id.appointment_entry_timeSpan);
			TextView descriptionView = (TextView) view.findViewById(R.id.appointment_entry_description);

			monthView.setText(AppointmentsParser.MONTH_YEAR_FORMAT.format(appointment.getMonth().getTime()));
			timeSpanView.setText(appointment.getTimeSpan());
			descriptionView.setText(appointment.getDescription());

			return view;
		}

	}

}
