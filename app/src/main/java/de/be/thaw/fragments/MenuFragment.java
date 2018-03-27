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

import java.io.IOException;
import java.util.ArrayList;
import java.util.Calendar;
import java.util.List;

import de.be.thaw.R;
import de.be.thaw.cache.MenuUtil;
import de.be.thaw.connect.parser.canteen.MenuParser;
import de.be.thaw.connect.studentenwerk.StudentenwerkConnection;
import de.be.thaw.model.canteen.Meal;
import de.be.thaw.model.canteen.Menu;

public class MenuFragment extends Fragment implements MainFragment {

	private static final String TAG = "MenuFragment";

	/**
	 * Object containing the items for the list view.
	 */
	private ArrayAdapter<Menu> menuAdapter;

	/**
	 * Layout responsible for pull to onRefresh.
	 */
	private SwipeRefreshLayout swipeContainer;

	public MenuFragment() {
		// Required empty public constructor
	}

	/**
	 * Use this factory method to create a new instance of
	 * this fragment using the provided parameters.
	 *
	 * @return
	 */
	public static MenuFragment newInstance() {
		MenuFragment fragment = new MenuFragment();

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

	@Override
	public boolean isAddable() {
		return false;
	}

	/**
	 * Refresh Fragment.
	 */
	public void onRefresh() {
		new GetMenuTask(getContext()).execute();
	}

	@Override
	public void onAdd() {
		// Do nothing
	}

	@Override
	public void onConfigurationChanged(Configuration newConfig) {
		super.onConfigurationChanged(newConfig);
	}


	@Override
	public View onCreateView(LayoutInflater inflater, ViewGroup container, Bundle savedInstanceState) {
		// Inflate the layout for this fragment
		View view = inflater.inflate(R.layout.fragment_menu, container, false);

		menuAdapter = new MenuArrayAdapter(getActivity());

		// Initialize Views
		swipeContainer = view.findViewById(R.id.menulist_swipe_layout);
		swipeContainer.setOnRefreshListener(new SwipeRefreshLayout.OnRefreshListener() {

			@Override
			public void onRefresh() {
				MenuFragment.this.onRefresh();
			}

		});
		swipeContainer.setColorSchemeResources(android.R.color.holo_blue_bright,
				android.R.color.holo_green_light,
				android.R.color.holo_orange_light,
				android.R.color.holo_red_light);

		ListView boardList = view.findViewById(R.id.menulist);
		boardList.setAdapter(menuAdapter);

		// Initialize board list
		updateMenu(null);

		return view;
	}

	/**
	 * Update the menu entries.
	 *
	 * @param menus
	 */
	private void updateMenu(Menu[] menus) {
		if (menus == null) { // Retrieve from Storage
			try {
				menus = MenuUtil.retrieve(getActivity());
			} catch (IOException e) {
				e.printStackTrace();
			}

			if (menus == null) { // When there are still no menus -> Update from Server
				onRefresh();
			}
		} else { // Store
			try {
				MenuUtil.store(menus, getActivity());
			} catch (IOException e) {
				e.printStackTrace();
			}
		}

		if (menus != null) {
			// Only add menus which are in the present or future (Nobody wants to know what has been
			// in the menu of yesterday.. ;D
			List<Menu> menuList = new ArrayList<>();

			Calendar now = Calendar.getInstance();
			now.set(Calendar.HOUR_OF_DAY, 0);
			now.set(Calendar.MINUTE, 0);
			now.set(Calendar.SECOND, 0);
			now.set(Calendar.MILLISECOND, 0);

			for (Menu menu : menus) {
				Calendar menuCalendar = Calendar.getInstance();
				menuCalendar.setTime(menu.getDate());

				if (menuCalendar.getTimeInMillis() - now.getTimeInMillis() >= 0) { // Check if present or future day
					menuList.add(menu);
				}
			}

			// Apply menus
			menuAdapter.clear();
			menuAdapter.addAll(menuList);
		}
	}

	/**
	 * Async task to get all menus.
	 */
	private class GetMenuTask extends AsyncTask<Void, Integer, Menu[]> {

		private ProgressDialog progress;
		private Context context;
		private Exception e;

		public GetMenuTask(Context context) {
			this.context = context;

			progress = new ProgressDialog(context);
			progress.setIndeterminate(true);
			progress.setMessage(context.getResources().getString(R.string.searchingForCanteenMenus));
		}

		@Override
		protected void onPreExecute() {
			super.onPreExecute();

			if (!swipeContainer.isRefreshing()) {
				progress.show();
			}
		}

		@Override
		protected Menu[] doInBackground(Void... params) {
			StudentenwerkConnection connection = new StudentenwerkConnection();

			Menu[] menus = null;
			try {
				menus = connection.getMenus();
			} catch (Exception e) {
				e.printStackTrace();
				this.e = e;
			}

			return menus;
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
		protected void onPostExecute(Menu[] menus) {
			super.onPostExecute(menus);

			if (progress.isShowing()) {
				progress.dismiss();
			}

			swipeContainer.setRefreshing(false);

			if (e != null) {
				new AlertDialog.Builder(context).setMessage(context.getResources().getString(R.string.canteenMenuLoadingError)).show();
			}

			if (menus != null) {
				updateMenu(menus);
			}
		}

	}

	/**
	 * Custom adapter to display menu entries.
	 */
	private class MenuArrayAdapter extends ArrayAdapter<Menu> {

		private final Context context;

		public MenuArrayAdapter(Context context) {
			super(context, -1);
			this.context = context;
		}

		@NonNull
		@Override
		public View getView(int position, View convertView, ViewGroup parent) {
			final Menu menu = getItem(position);

			LayoutInflater inflater = (LayoutInflater) context.getSystemService(Context.LAYOUT_INFLATER_SERVICE);
			View view = inflater.inflate(R.layout.menu_entry, parent, false);

			LinearLayout linearLayout = (LinearLayout) view.findViewById(R.id.menu_entry_layout);
			TextView dateView = (TextView) view.findViewById(R.id.menu_entry_date);

			// Set Contents
			dateView.setText(MenuParser.DATE_FORMAT.format(menu.getDate()));

			for (Meal meal : menu.getMeals()) {
				View mealView = inflater.inflate(R.layout.menu_meal_entry, linearLayout, false);
				linearLayout.addView(mealView);

				TextView mealLabel = (TextView) mealView.findViewById(R.id.meal_label);
				mealLabel.setText(meal.getName() + " - " + meal.getPrice());

				IconTextView iconView = (IconTextView) mealView.findViewById(R.id.meal_entry_icon);

				switch (meal.getMealInfo()) {
					case MEAT:
						iconView.setTextColor(getContext().getResources().getColor(android.R.color.holo_red_dark));
						break;

					case MEATLESS:
						iconView.setTextColor(getContext().getResources().getColor(android.R.color.holo_orange_dark));
						break;

					case VEGAN:
						iconView.setTextColor(getContext().getResources().getColor(android.R.color.holo_green_dark));
						break;

					default:
						break;
				}
			}

			return view;
		}

	}

}
