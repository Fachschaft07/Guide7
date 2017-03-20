package de.be.thaw.fragments;

import android.app.Activity;
import android.app.DatePickerDialog;
import android.app.ProgressDialog;
import android.app.TimePickerDialog;
import android.content.res.Configuration;
import android.os.AsyncTask;
import android.os.Bundle;
import android.support.annotation.NonNull;
import android.support.v4.app.Fragment;
import android.support.v7.app.AlertDialog;
import android.view.LayoutInflater;
import android.view.View;
import android.view.ViewGroup;
import android.widget.ArrayAdapter;
import android.widget.DatePicker;
import android.widget.EditText;
import android.widget.ListView;
import android.widget.TextView;
import android.widget.TimePicker;

import java.text.DateFormat;
import java.text.SimpleDateFormat;
import java.util.Calendar;

import de.be.thaw.R;
import de.be.thaw.model.freerooms.Room;
import de.be.thaw.connect.zpa.ZPAConnection;

public class RoomSearchFragment extends Fragment implements MainFragment {

	private static final String TAG = "RoomSearchFragment";

	private static final DateFormat dateFormat = new SimpleDateFormat("dd.MM.yyyy");
	private static final DateFormat timeFormat = new SimpleDateFormat("HH:mm");

	/**
	 * Object containing the items for the list view.
	 */
	private ArrayAdapter<Room> roomAdapter;

	/**
	 * Calendar where the currently set Date is stored.
	 */
	private Calendar currentDate;

	/**
	 * Calendar where the currently set From time is stored.
	 */
	private Calendar currentFrom;

	/**
	 * Calendar where the currently set To time is stored.
	 */
	private Calendar currentTo;

	private EditText dateTextField;
	private EditText fromTextField;
	private EditText toTextField;

	public RoomSearchFragment() {
		// Required empty public constructor
	}

	/**
	 * Use this factory method to create a new instance of
	 * this fragment using the provided parameters.
	 *
	 * @return A new instance of fragment RoomSearchFragment.
	 */
	public static RoomSearchFragment newInstance() {
		RoomSearchFragment fragment = new RoomSearchFragment();

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
		Calendar start = Calendar.getInstance();
		Calendar end = Calendar.getInstance();

		start.set(currentDate.get(Calendar.YEAR), currentDate.get(Calendar.MONTH), currentDate.get(Calendar.DAY_OF_MONTH), currentFrom.get(Calendar.HOUR_OF_DAY), currentFrom.get(Calendar.MINUTE));
		end.set(currentDate.get(Calendar.YEAR), currentDate.get(Calendar.MONTH), currentDate.get(Calendar.DAY_OF_MONTH), currentTo.get(Calendar.HOUR_OF_DAY), currentTo.get(Calendar.MINUTE));

		new RoomSearchTask(roomAdapter, getActivity()).execute(start, end);
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
	}


	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		// Inflate the layout for this fragment
		View view = inflater.inflate(R.layout.fragment_search_rooms, container, false);

		roomAdapter = new RoomArrayAdapter(getActivity());

		// Initialize Views
		ListView roomList = (ListView) view.findViewById(R.id.freeRoomListView);
		roomList.setAdapter(roomAdapter);


		dateTextField = (EditText) view.findViewById(R.id.editDate);
		currentDate = Calendar.getInstance();
		dateTextField.setText(dateFormat.format(currentDate.getTime()));
		dateTextField.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				onDateSelectClicked(v);
			}

		});

		fromTextField = (EditText) view.findViewById(R.id.editFrom);
		fromTextField.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				onFromSelectClicked(v);
			}

		});
		currentFrom = Calendar.getInstance();
		fromTextField.setText(timeFormat.format(currentFrom.getTime()));

		toTextField = (EditText) view.findViewById(R.id.editTo);
		toTextField.setOnClickListener(new View.OnClickListener() {

			@Override
			public void onClick(View v) {
				onToSelectClicked(v);
			}

		});
		currentTo = Calendar.getInstance();
		currentTo.add(Calendar.HOUR_OF_DAY, 1);
		toTextField.setText(timeFormat.format(currentTo.getTime()));


		// Refresh List
		refresh();

		return view;
	}

	/**
	 * What to do when the date selection component has been clicked.
	 *
	 * @param view
	 */
	public void onDateSelectClicked(View view) {
		// Launch Date Picker Dialog to select new Date.
		new DatePickerDialog(getActivity(), new DatePickerDialog.OnDateSetListener() {

			@Override
			public void onDateSet(DatePicker view, int year, int month, int dayOfMonth) {
				currentDate.set(year, month, dayOfMonth);

				// Update Date Textfield
				dateTextField.setText(dateFormat.format(currentDate.getTime()));
			}

		}, currentDate.get(Calendar.YEAR), currentDate.get(Calendar.MONTH), currentDate.get(Calendar.DAY_OF_MONTH)).show();
	}

	/**
	 * What to do when the From Textfield has been clicked.
	 *
	 * @param view
	 */
	public void onFromSelectClicked(View view) {
		new TimePickerDialog(getActivity(), new TimePickerDialog.OnTimeSetListener() {

			@Override
			public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
				currentFrom.set(Calendar.HOUR_OF_DAY, hourOfDay);
				currentFrom.set(Calendar.MINUTE, minute);

				// Update textfield
				fromTextField.setText(timeFormat.format(currentFrom.getTime()));
			}

		}, currentFrom.get(Calendar.HOUR_OF_DAY), currentDate.get(Calendar.MINUTE), true).show();
	}

	/**
	 * What to do when the To Textfield has been clicked.
	 *
	 * @param view
	 */
	public void onToSelectClicked(View view) {
		new TimePickerDialog(getActivity(), new TimePickerDialog.OnTimeSetListener() {

			@Override
			public void onTimeSet(TimePicker view, int hourOfDay, int minute) {
				currentTo.set(Calendar.HOUR_OF_DAY, hourOfDay);
				currentTo.set(Calendar.MINUTE, minute);

				// Update textfield
				toTextField.setText(timeFormat.format(currentTo.getTime()));
			}

		}, currentTo.get(Calendar.HOUR_OF_DAY), currentTo.get(Calendar.MINUTE), true).show();
	}

	/**
	 * Async Task to search for free rooms.
	 */
	private class RoomSearchTask extends AsyncTask<Calendar, Integer, Room[]> {

		private ArrayAdapter<Room> roomAdapter;
		private ProgressDialog progress;
		private Activity activity;
		private Exception e;

		public RoomSearchTask(ArrayAdapter<Room> roomAdapter, Activity activity) {
			this.roomAdapter = roomAdapter;
			this.activity = activity;

			progress = new ProgressDialog(activity);
			progress.setIndeterminate(true);
			progress.setMessage(activity.getResources().getString(R.string.searchingForRoomMessage));
		}

		@Override
		protected void onPreExecute() {
			super.onPreExecute();
			progress.show();
		}

		@Override
		protected Room[] doInBackground(Calendar... params) {
			ZPAConnection connection = new ZPAConnection(); // Get Public area ZPA Connection.

			Calendar start = params[0];
			Calendar end = params[1];

			Room[] rooms = null;
			try {
				rooms = connection.getFreeRooms(start, end);
			} catch (Exception e) {
				e.printStackTrace();
				this.e = e;
			}

			return rooms;
		}

		@Override
		protected void onCancelled() {
			super.onCancelled();

			if (progress.isShowing()) {
				progress.dismiss();
			}
		}

		@Override
		protected void onPostExecute(Room[] rooms) {
			super.onPostExecute(rooms);

			if (progress.isShowing()) {
				progress.dismiss();
			}

			if (e != null) {
				new AlertDialog.Builder(activity).setMessage(activity.getResources().getString(R.string.roomSearchError)).show();
			}

			if (rooms != null) {
				roomAdapter.clear();
				roomAdapter.addAll(rooms);
			}
		}
	}

	/**
	 * Custom Room adapter to display rooms having internationalization.
	 */
	private class RoomArrayAdapter extends ArrayAdapter<Room> {

		public RoomArrayAdapter(Activity activity) {
			super(activity, android.R.layout.simple_list_item_1);
		}

		@NonNull
		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			TextView view = (TextView) super.getView(position, convertView, parent);

			final Room item = getItem(position);
			view.setText(item.getName() + " / " + getActivity().getResources().getString(R.string.seats) + ": " + item.getSeats());

			return view;
		}
	}

}
