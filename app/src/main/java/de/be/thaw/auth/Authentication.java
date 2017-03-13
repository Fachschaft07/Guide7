package de.be.thaw.auth;

import android.app.Activity;
import android.app.AlertDialog;
import android.content.Context;
import android.content.DialogInterface;
import android.content.SharedPreferences;
import android.content.res.Resources;
import android.util.Log;

import java.security.SecureRandom;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.spec.SecretKeySpec;

import de.be.thaw.encryption.AESUtil;
import de.be.thaw.util.ThawUtil;

/**
 * Authentication utility class providing methods for easy credential fetching and storing.
 * <p>
 * Created by Benjamin Eder on 12.02.2017.
 */
public class Authentication {

	private static final String TAG = "Authentication";

	private static final String USERNAME_KEY = "thaw.username";
	private static final String PASSWORD_KEY = "thaw.password";

	/**
	 * Save Credential to shared preferences.
	 *
	 * @param activity
	 * @param credential
	 */
	public static void saveCredential(Activity activity, Credential credential) {
		SharedPreferences sharedPref = activity.getSharedPreferences(ThawUtil.SHARED_PREFS, Context.MODE_PRIVATE);

		String encryptedUsername = null;
		String encryptedPassword = null;

		if (credential != null) {
			try {
				encryptedUsername = AESUtil.encrypt(credential.getUsername());
				encryptedPassword = AESUtil.encrypt(credential.getPassword());
			} catch (Exception e) {
				Log.e(TAG, "Could not encrypt username and/or password.");
			}
		}

		SharedPreferences.Editor editor = sharedPref.edit();
		editor.putString(USERNAME_KEY, encryptedUsername);
		editor.putString(PASSWORD_KEY, encryptedPassword);

		editor.commit(); // Save Preferences.
	}

	/**
	 * Fetch credential from shared preferences.
	 *
	 * @param activity
	 * @return The stored credentials (ATTENTION: Might be empty. Check by calling isEmpty() on Credentials)
	 */
	public static Credential getCredential(Activity activity) {
		SharedPreferences sharedPref = activity.getSharedPreferences(ThawUtil.SHARED_PREFS, Context.MODE_PRIVATE);

		String encryptedUsername = sharedPref.getString(USERNAME_KEY, "");
		String encryptedPassword = sharedPref.getString(PASSWORD_KEY, "");

		String username = null;
		String password = null;
		try {
			username = AESUtil.decrypt(encryptedUsername);
			password = AESUtil.decrypt(encryptedPassword);
		} catch (Exception e) {
			Log.e(TAG, "Could not decrypt username and/or password.");
		}

		return new Credential(username, password);
	}

	/**
	 * Clear credentials from storage
	 *
	 * @param activity
	 */
	public static void clearCredential(Activity activity) {
		saveCredential(activity, null);
	}

}
