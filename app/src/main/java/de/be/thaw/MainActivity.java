package de.be.thaw;

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
import android.support.v7.widget.Toolbar;
import android.view.Menu;
import android.view.MenuItem;

import com.joanzapata.iconify.IconDrawable;
import com.joanzapata.iconify.Iconify;
import com.joanzapata.iconify.fonts.FontAwesomeIcons;
import com.joanzapata.iconify.fonts.FontAwesomeModule;

import java.io.IOException;
import java.security.KeyManagementException;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.CertificateException;

import de.be.thaw.auth.Authentication;
import de.be.thaw.auth.CertificateUtil;
import de.be.thaw.exception.ExceptionHandler;
import de.be.thaw.fragments.InfoFragment;
import de.be.thaw.fragments.NoticeBoardFragment;
import de.be.thaw.fragments.MainFragment;
import de.be.thaw.fragments.RoomSearchFragment;
import de.be.thaw.fragments.SettingsFragment;
import de.be.thaw.fragments.WeekPlanFragment;

public class MainActivity extends AppCompatActivity implements NavigationView.OnNavigationItemSelectedListener {

	/**
	 * Key used to store the currently selected item in the instance.
	 */
	private static final String SELECTED_ITEM = "de.be.thaw.selectedItem";

	/**
	 * The initially shown fragment/menu item.
	 */
	private static final int INITIAL_FRAGMENT = R.id.drawer_action_blackboard;

	/**
	 * URL to the Data Policy.
	 */
	private static final String DATA_POLICY_URL = "https://sites.google.com/view/datapolicyguide7/";

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

		if (savedInstanceState == null) {
			// Set Start Fragment
			selectInitialFragment();
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

		initializeIcons(navigationView.getMenu());
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
			setIcon(menu, R.id.drawer_action_roomsearch, FontAwesomeIcons.fa_search, R.color.drawer_icon_color);
			//setIcon(menu, R.id.drawer_action_settings, FontAwesomeIcons.fa_cogs, R.color.drawer_icon_color);

			setIcon(menu, R.id.drawer_action_datapolicy, FontAwesomeIcons.fa_paragraph, R.color.drawer_icon_color);
			setIcon(menu, R.id.drawer_action_info, FontAwesomeIcons.fa_info_circle, R.color.drawer_icon_color);

			setIcon(menu, R.id.drawer_action_logout, FontAwesomeIcons.fa_sign_out, R.color.drawer_icon_color);
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

				case R.id.drawer_action_roomsearch:
					RoomSearchFragment roomSearchFragment = RoomSearchFragment.newInstance();
					selectItem(roomSearchFragment, item.getTitle());
					break;

				/*case R.id.drawer_action_settings:
					SettingsFragment settingsFragment = SettingsFragment.newInstance();
					selectItem(settingsFragment, item.getTitle());
					break;*/

				case R.id.drawer_action_datapolicy:
					Intent browserIntent = new Intent(Intent.ACTION_VIEW, Uri.parse(DATA_POLICY_URL));
					startActivity(browserIntent);
					break;

				case R.id.drawer_action_info:
					InfoFragment infoFragment = InfoFragment.newInstance();
					selectItem(infoFragment, item.getTitle());
					break;

				case R.id.drawer_action_logout:
					performLogout();
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
		Authentication.clearCredential(this);

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
		onNavigationItemSelected(navigationView.getMenu().findItem(INITIAL_FRAGMENT));
	}

}
