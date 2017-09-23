package de.be.thaw;

import android.content.SharedPreferences;
import android.net.Uri;
import android.support.v4.app.FragmentManager;
import android.content.Intent;
import android.os.Bundle;
import android.support.v4.app.Fragment;
import android.support.design.widget.NavigationView;
import android.support.v4.view.GravityCompat;
import android.support.v4.widget.DrawerLayout;
import android.support.v7.app.ActionBarDrawerToggle;
import android.support.v7.app.AppCompatActivity;
import android.support.v7.preference.PreferenceManager;
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;
import android.view.View;
import android.widget.LinearLayout;
import android.widget.RelativeLayout;
import android.widget.TextView;

import com.joanzapata.iconify.IconDrawable;
import com.joanzapata.iconify.Iconify;
import com.joanzapata.iconify.fonts.FontAwesomeIcons;
import com.joanzapata.iconify.fonts.FontAwesomeModule;
import com.joanzapata.iconify.widget.IconButton;
import com.joanzapata.iconify.widget.IconTextView;

import org.w3c.dom.Text;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.CertificateException;

import de.be.thaw.auth.Auth;
import de.be.thaw.auth.CertificateUtil;
import de.be.thaw.auth.User;
import de.be.thaw.auth.exception.AuthException;
import de.be.thaw.auth.exception.NoUserStoredException;
import de.be.thaw.cache.AppointmentUtil;
import de.be.thaw.cache.BoardUtil;
import de.be.thaw.cache.MenuUtil;
import de.be.thaw.cache.ScheduleUtil;
import de.be.thaw.exception.ExceptionHandler;
import de.be.thaw.fragments.AppointmentFragment;
import de.be.thaw.fragments.InfoFragment;
import de.be.thaw.fragments.MenuFragment;
import de.be.thaw.fragments.NoticeBoardFragment;
import de.be.thaw.fragments.MainFragment;
import de.be.thaw.fragments.RoomSearchFragment;
import de.be.thaw.fragments.SettingsFragment;
import de.be.thaw.fragments.WeekPlanFragment;
import de.be.thaw.util.ThawUtil;
import de.be.thaw.util.job.jobs.StaticWeekPlanNotificationJob;
import de.be.thaw.util.job.jobs.UpcomingAppointmentNotificationJob;
import de.be.thaw.util.job.jobs.UpdateNoticeBoardJob;

public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener, SharedPreferences.OnSharedPreferenceChangeListener {

	/**
	 * Key used to store the currently selected item in the instance.
	 */
	private static final String SELECTED_ITEM = "de.be.thaw.selectedItem";

	/**
	 * The initially shown fragment/menu item.
	 */
	private static final int INITIAL_FRAGMENT = R.id.drawer_action_blackboard;

	/**
	 * Extra key to use when you want to call the MainActivity and
	 * initially show a specific fragment -> pass its drawer action id as integer.
	 * An example of an id is the INITIAL_FRAGMENT variable.
	 */
	public static final String CALL_FRAGMENT_EXTRA = "de.be.thaw.MainActivity.callFragmentExtra";

	/**
	 * URL to the Data Policy.
	 */
	private static final String DATA_POLICY_URL = "https://sites.google.com/view/guide7-privacy-statement/";

	private NavigationView navigationView;

	private int checkedItemId;
	private Fragment selectedFragment;
	private MenuItem refreshItem;

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		Thread.setDefaultUncaughtExceptionHandler(new ExceptionHandler(this));
		initializeCertificates();

		// Initialize GUI
		setContentView(R.layout.activity_main);
		Iconify.with(new FontAwesomeModule());

		initializeDrawer();
		initializeNavigation();
		initializeJobs();

		// Check if there is an initial fragment to call set in the extra.
		if (getIntent().hasExtra(CALL_FRAGMENT_EXTRA)) {
			selectFragmentById(getIntent().getIntExtra(CALL_FRAGMENT_EXTRA, INITIAL_FRAGMENT));
		} else if (savedInstanceState == null) {
			// Set Start Fragment
			selectInitialFragment();
		}
	}

	/**
	 * Method where you can define jobs to be run in the background.
	 */
	private void initializeJobs() {
		if (UpdateNoticeBoardJob.isActivated(this)) {
			// Recurring Task which updates the notice board!
			UpdateNoticeBoardJob.scheduleJob();
		}

		if (StaticWeekPlanNotificationJob.isActivated(this)) {
			StaticWeekPlanNotificationJob.scheduleJob();
		}

		if (UpcomingAppointmentNotificationJob.isActivated(this)) {
			UpcomingAppointmentNotificationJob.scheduleJob();
		}

		// Issue change listener to react to preference changes.
		PreferenceManager.getDefaultSharedPreferences(this).registerOnSharedPreferenceChangeListener(this);
	}

	@Override
	public void onSharedPreferenceChanged(SharedPreferences sharedPreferences, String key) {
		if (key.equals("noticeboardNotificationKey")) {
			boolean activated = sharedPreferences.getBoolean(key, true);

			if (activated) {
				UpdateNoticeBoardJob.scheduleJob();
			} else {
				UpdateNoticeBoardJob.cancelJob();
			}
		} else if (key.equals("staticScheduleNotificationKey")) {
			boolean activated = sharedPreferences.getBoolean(key, false);

			if (activated) {
				StaticWeekPlanNotificationJob.scheduleJob();
			} else {
				StaticWeekPlanNotificationJob.cancelJob(this);
			}
		} else if (key.equals("upcomingAppointmentNotification")) {
			boolean activated = sharedPreferences.getBoolean(key, false);

			if (activated) {
				UpcomingAppointmentNotificationJob.scheduleJob();
			} else {
				UpcomingAppointmentNotificationJob.cancelJob();
			}
		}
	}

	/**
	 * Initialize Drawer.
	 */
	private void initializeDrawer() {
		Toolbar toolbar = (Toolbar) findViewById(R.id.toolbar);
		setSupportActionBar(toolbar);

		DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
		ActionBarDrawerToggle toggle = new ActionBarDrawerToggle(this, drawer, toolbar, R.string.navigation_drawer_open, R.string.navigation_drawer_close);
		toggle.syncState();
	}

	/**
	 * Initialize Navigation View.
	 */
	private void initializeNavigation() {
		navigationView = (NavigationView) findViewById(R.id.nav_view);
		navigationView.setNavigationItemSelectedListener(this);

		// Get logged in user.
		try {
			final User user = Auth.getInstance().getCurrentUser(this);

			final IconTextView drawerHeaderText = (IconTextView) navigationView.getHeaderView(0).findViewById(R.id.nav_header_text);

			drawerHeaderText.post(new Runnable() {

				@Override
				public void run() {
					drawerHeaderText.setText("{fa-user} " + getResources().getString(R.string.welcome) + " " + user.getName() + " (" + user.getGroup() + ")");
				}

			});

			// Modify drawer header to not overlap the status bar.
			LinearLayout layout = (LinearLayout) navigationView.getHeaderView(0).findViewById(R.id.nav_header_layout);
			LinearLayout.LayoutParams layoutParams = (LinearLayout.LayoutParams) layout.getLayoutParams();
			layoutParams.setMargins(layoutParams.leftMargin, getStatusBarHeight(), layoutParams.rightMargin, layoutParams.bottomMargin);
			layout.setLayoutParams(layoutParams);

			IconButton signoutButton = (IconButton) navigationView.getHeaderView(0).findViewById(R.id.nav_header_signout);
			signoutButton.setOnClickListener(new View.OnClickListener() {

				@Override
				public void onClick(View view) {
					performLogout();
				}

			});
		} catch (NoUserStoredException e) {
			e.printStackTrace();
		}

		initializeIcons(navigationView.getMenu());
	}



	/**
	 * Get height of the status bar.
	 *
	 * @return
	 */
	private int getStatusBarHeight() {
		int result = 0;
		int resourceId = getResources().getIdentifier("status_bar_height", "dimen", "android");
		if (resourceId > 0) {
			result = getResources().getDimensionPixelSize(resourceId);
		}
		return result;
	}

	/**
	 * Set Icons for the Drawer Menu.
	 *
	 * @param menu
	 */
	private void initializeIcons(Menu menu) {
		if (menu != null) {
			setIcon(menu, R.id.drawer_action_blackboard, FontAwesomeIcons.fa_newspaper_o, R.color.drawer_icon_color);
			setIcon(menu, R.id.drawer_action_schedule, FontAwesomeIcons.fa_table, R.color.drawer_icon_color);
			setIcon(menu, R.id.drawer_action_appointments, FontAwesomeIcons.fa_calendar, R.color.drawer_icon_color);
			setIcon(menu, R.id.drawer_action_menu, FontAwesomeIcons.fa_cutlery, R.color.drawer_icon_color);
			setIcon(menu, R.id.drawer_action_roomsearch, FontAwesomeIcons.fa_search, R.color.drawer_icon_color);
			setIcon(menu, R.id.drawer_action_settings, FontAwesomeIcons.fa_cogs, R.color.drawer_icon_color);

			setIcon(menu, R.id.drawer_action_datapolicy, FontAwesomeIcons.fa_paragraph, R.color.drawer_icon_color);
			setIcon(menu, R.id.drawer_action_info, FontAwesomeIcons.fa_info_circle, R.color.drawer_icon_color);
		}
	}

	/**
	 * Set Font Awesome Icon for Menu Item.
	 *
	 * @param menu
	 * @param itemId
	 * @param icon
	 */
	private void setIcon(Menu menu, int itemId, FontAwesomeIcons icon, int colorId) {
		menu.findItem(itemId).setIcon(new IconDrawable(this, icon).colorRes(colorId).actionBarSize());
	}

	/**
	 * Try to initialize all Certificates.
	 */
	private void initializeCertificates() {
		try {
			CertificateUtil.initCertificate(this);
		} catch (CertificateException e) {
			e.printStackTrace();
		} catch (KeyStoreException e) {
			e.printStackTrace();
		} catch (IOException e) {
			e.printStackTrace();
		} catch (NoSuchAlgorithmException e) {
			e.printStackTrace();
		} catch (KeyManagementException e) {
			e.printStackTrace();
		}
	}

	@Override
	public void onBackPressed() {
		DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
		if (drawer.isDrawerOpen(GravityCompat.START)) {
			drawer.closeDrawer(GravityCompat.START);
		} else {
			super.onBackPressed();
		}
	}

	@Override
	public boolean onCreateOptionsMenu(Menu menu) {
		// Inflate the menu; this adds items to the action bar if it is present.
		getMenuInflater().inflate(R.menu.main, menu);

		// Set Icons
		setIcon(menu, R.id.action_refresh, FontAwesomeIcons.fa_refresh, R.color.actionBar_icon_color);

		refreshItem = menu.findItem(R.id.action_refresh);

		updateMenuItems();

		return true;
	}

	@Override
	public boolean onOptionsItemSelected(MenuItem item) {
		// Handle action bar item clicks here. The action bar will
		// automatically handle clicks on the Home/Up button, so long
		// as you specify a parent activity in AndroidManifest.xml.
		int id = item.getItemId();

		switch (id) {
			case R.id.action_refresh:
				if (getCurrentFragment() != null) {
					if (getCurrentFragment() instanceof MainFragment) {
						((MainFragment) getCurrentFragment()).refresh();
					}
				}
				break;

			default:
		}

		return super.onOptionsItemSelected(item);
	}

	@SuppressWarnings("StatementWithEmptyBody")
	@Override
	public boolean onNavigationItemSelected(MenuItem item) {
		// Handling navigation view item clicks here.
		int id = item.getItemId();

		if (id != checkedItemId) {
			if (item.isCheckable()) {
				checkedItemId = id;
				item.setChecked(true);
			} else {
				checkedItemId = -1;
			}

			switch (id) {
				case R.id.drawer_action_blackboard:
					NoticeBoardFragment noticeBoardFragment = NoticeBoardFragment.newInstance();
					selectItem(noticeBoardFragment, item.getTitle());
					break;

				case R.id.drawer_action_schedule:
					WeekPlanFragment weekPlanFragment = WeekPlanFragment.newInstance();
					selectItem(weekPlanFragment, item.getTitle());
					break;

				case R.id.drawer_action_appointments:
					AppointmentFragment appointmentFragment = AppointmentFragment.newInstance();
					selectItem(appointmentFragment, item.getTitle());
					break;

				case R.id.drawer_action_roomsearch:
					RoomSearchFragment roomSearchFragment = RoomSearchFragment.newInstance();
					selectItem(roomSearchFragment, item.getTitle());
					break;

				case R.id.drawer_action_menu:
					MenuFragment menuFragment = MenuFragment.newInstance();
					selectItem(menuFragment, item.getTitle());
					break;

				case R.id.drawer_action_settings:
					SettingsFragment settingsFragment = SettingsFragment.newInstance();
					selectItem(settingsFragment, item.getTitle());
					break;

				case R.id.drawer_action_datapolicy:
					Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(DATA_POLICY_URL));
					startActivity(browserIntent);
					break;

				case R.id.drawer_action_info:
					InfoFragment infoFragment = InfoFragment.newInstance();
					selectItem(infoFragment, item.getTitle());
					break;

				default:
					break;
			}
		}

		DrawerLayout drawer = (DrawerLayout) findViewById(R.id.drawer_layout);
		drawer.closeDrawer(GravityCompat.START);
		return true;
	}

	/**
	 * Update the actiovation state of menu items.
	 */
	private void updateMenuItems() {
		if (refreshItem != null && getCurrentFragment() != null) {
			if (getCurrentFragment() instanceof MainFragment) {
				refreshItem.setVisible(true);
				refreshItem.setEnabled(((MainFragment) getCurrentFragment()).isRefreshable());
			} else {
				refreshItem.setVisible(false);
			}
		}
	}

	/**
	 * Swap a fragment in the content view.
	 *
	 * @param fragment
	 * @param title
	 */
	private void selectItem(Fragment fragment, CharSequence title) {
		// Insert the fragment by replacing any existing fragment
		FragmentManager fragmentManager = getSupportFragmentManager();
		fragmentManager.beginTransaction().replace(R.id.content_frame, fragment).commit();

		selectedFragment = fragment;

		// Update the title
		setTitle(title);

		updateMenuItems();
	}

	@Override
	protected void onSaveInstanceState(Bundle outState) {
		super.onSaveInstanceState(outState);

		if (checkedItemId != -1) {
			outState.putInt(SELECTED_ITEM, checkedItemId);
		}
	}

	@Override
	protected void onRestoreInstanceState(Bundle savedInstanceState) {
		super.onRestoreInstanceState(savedInstanceState);

		// Restore title with checked item
		checkedItemId = savedInstanceState.getInt(SELECTED_ITEM, -1);
		if (checkedItemId != -1) {
			MenuItem checked = navigationView.getMenu().findItem(checkedItemId);
			setTitle(checked.getTitle());
		}

		// Update Menu Items
		updateMenuItems();
	}

	/**
	 * Get the currently selected Fragment.
	 * @return
	 */
	private Fragment getCurrentFragment() {
		if (selectedFragment == null) {
			selectedFragment = getSupportFragmentManager().findFragmentById(R.id.content_frame);
		}

		return selectedFragment;
	}

	/**
	 * Perform Logout.
	 */
	private void performLogout() {
		// Logout
		try {
			Auth.getInstance().clearCurrentUser(this);
		} catch (AuthException e) {
			e.printStackTrace();
		}

		// Clear caches
		ThawUtil.clearChaches(this);

		// Return to Login Activity
		Intent intent = new Intent(this, LoginActivity.class);
		intent.putExtra(LoginActivity.AUTO_LOGIN_EXTRA, false);
		startActivity(intent);

		finish(); // End this activity.
	}

	/**
	 * Select the Initial Fragment.
	 */
	private void selectInitialFragment() {
		selectFragmentById(INITIAL_FRAGMENT);
	}

	/**
	 * Select an fragment by its id.
	 * @param fragmentDrawerActionId
	 */
	private void selectFragmentById(int fragmentDrawerActionId) {
		onNavigationItemSelected(navigationView.getMenu().findItem(fragmentDrawerActionId));
	}

}
