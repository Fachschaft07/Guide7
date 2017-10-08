package de.be.thaw.fragments;


import android.content.DialogInterface;
import android.os.Bundle;
import android.support.v7.app.AlertDialog;
import android.support.v7.preference.Preference;
import android.support.v7.preference.PreferenceFragmentCompat;

import de.be.thaw.R;
import de.be.thaw.util.ThawUtil;

public class SettingsFragment extends PreferenceFragmentCompat {

	public SettingsFragment() {
		// Required empty public constructor
	}

	public static SettingsFragment newInstance() {
		SettingsFragment fragment = new SettingsFragment();
		return fragment;
	}

	@Override
	public void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);

		Preference button = findPreference(de.be.thaw.util.Preference.CLEAR_CACHE.getKey());
		button.setOnPreferenceClickListener(new Preference.OnPreferenceClickListener() {

			@Override
			public boolean onPreferenceClick(Preference preference) {
				ThawUtil.clearCaches(getContext());

				AlertDialog.Builder builder = new AlertDialog.Builder(getContext()).setMessage(R.string.clearCacheSuccessMessage);
				builder.setCancelable(false)
						.setPositiveButton(R.string.ok, new DialogInterface.OnClickListener() {

							@Override
							public void onClick(DialogInterface dialog, int id) {
								dialog.dismiss();
							}

						});

				builder.show();

				return true;
			}

		});
	}

	@Override
	public void onCreatePreferences(Bundle savedInstanceState, String rootKey) {
		addPreferencesFromResource(R.xml.app_preferences);
	}

}
