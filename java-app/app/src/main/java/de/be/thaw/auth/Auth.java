package de.be.thaw.auth;

import android.content.Context;
import android.content.SharedPreferences;
import android.util.Log;

import com.fasterxml.jackson.core.JsonProcessingException;
import com.fasterxml.jackson.databind.ObjectMapper;

import java.io.IOException;

import de.be.thaw.auth.exception.AuthException;
import de.be.thaw.auth.exception.NoUserStoredException;
import de.be.thaw.auth.exception.UserStoreException;
import de.be.thaw.encryption.AESUtil;
import de.be.thaw.model.schedule.Schedule;
import de.be.thaw.util.ThawUtil;

/**
 * Singleton responsible for holding the current authentication state
 * (meaning the currently logged in user).
 * <p>
 * This implementation is implicitely synchronized so calling <code>getInstance()</code>
 * is thread safe.
 * <p>
 * As mentioned above, this service holds the user for this application, meaning it offers a way
 * to easily retrieve the current user from cache (It is stored encrypted in the shared preferences).
 * <p>
 * Created by Benjamin Eder on 01.05.2017.
 */
public class Auth {

	/**
	 * Tag used for logging.
	 */
	private static final String TAG = "AuthService";

	/**
	 * Key for the user stored in the applications shared preferences.
	 */
	private static final String USER_KEY = "thaw.user";

	/**
	 * The current user.
	 * This is used so that the user hasn't to be retrieved from shared preferences over and over.
	 */
	private User currentUser;

	/**
	 * Private class getting initialized implicitely by the classloader when accessing the surrounding class.
	 */
	private static final class InstanceHolder {

		/**
		 * Singleton is only created once implicitely by the classloader!
		 */
		static final Auth INSTANCE = new Auth();

	}

	/**
	 * Private constructor.
	 * This is a singleton and should not be able to be constructed from a remote caller.
	 */
	private Auth() {
		// Do nothing.
	}

	/**
	 * Get Instance of the Auth Service.<br>
	 * <b>This is thread safe!</b>
	 *
	 * @return
	 */
	public static Auth getInstance() {
		return InstanceHolder.INSTANCE;
	}

	/**
	 * Get the current use.
	 *
	 * @param context
	 * @return the current user.
	 */
	public User getCurrentUser(Context context) throws NoUserStoredException {
		synchronized (this) {
			if (currentUser == null) {
				currentUser = retrieveUser(context);
			}
		}

		return new User(currentUser);
	}

	/**
	 * Set the current user.
	 *
	 * @param context to fetch the shared preferences for (where the user is saved).
	 * @param user    the user to set as current.
	 * @throws UserStoreException    in case the user couldn't be stored.
	 * @throws NoUserStoredException in case the stored user couldn't be read properly.
	 */
	public void setCurrentUser(Context context, User user) throws UserStoreException, NoUserStoredException {
		synchronized (this) {
			// Save user.
			saveUser(context, user);

			// Retrieve stored User.
			currentUser = retrieveUser(context);
		}
	}

	/**
	 * Clear current user.
	 *
	 * @param context
	 * @throws AuthException in case it could not be cleared.
	 */
	public void clearCurrentUser(Context context) throws AuthException {
		synchronized (this) {
			clearUser(context);
			currentUser = null;
		}
	}

	/**
	 * Save a user.
	 *
	 * @param context The current application context used to store the user in the shared preferences.
	 * @param user    The user to save.
	 * @throws UserStoreException in case the user could not be saved.
	 */
	private void saveUser(Context context, User user) throws UserStoreException {
		if (user == null) {
			throw new UserStoreException("User object mustn't be null.");
		}

		// Map User object to json.
		ObjectMapper mapper = new ObjectMapper();
		String userJSON = null;
		try {
			userJSON = mapper.writeValueAsString(user);
		} catch (JsonProcessingException e) {
			throw new UserStoreException(e);
		}

		// Encrypt user json.
		String encryptedUser = null;
		try {
			encryptedUser = AESUtil.encrypt(userJSON);
		} catch (Exception e) {
			throw new UserStoreException(e);
		}

		// Retrieve shared preferences by passed context.
		SharedPreferences sharedPref = context.getSharedPreferences(ThawUtil.SHARED_PREFS, Context.MODE_PRIVATE);

		// Store in shared preferences.
		SharedPreferences.Editor editor = sharedPref.edit();
		editor.putString(USER_KEY, encryptedUser);

		// Try to save preferences.
		if (!editor.commit()) {
			throw new UserStoreException("User could not be saved in shared preferences.");
		}
	}


	/**
	 * Retrieve a user from shared preferences.
	 *
	 * @param context The current application context to access the applications shared preferences.
	 * @return The stored user.
	 * @throws NoUserStoredException in case no user could be retrieved from shared preferences.
	 */
	private User retrieveUser(Context context) throws NoUserStoredException {
		// Get shared preferences from context.
		SharedPreferences sharedPref = context.getSharedPreferences(ThawUtil.SHARED_PREFS, Context.MODE_PRIVATE);

		// Try to retrieve stored encrypted user.
		String encryptedUser = sharedPref.getString(USER_KEY, "");
		if (encryptedUser.isEmpty()) {
			throw new NoUserStoredException("No user is currently stored (Shared preferences returned empty string).");
		}

		String userJSON = null;
		try {
			userJSON = AESUtil.decrypt(encryptedUser);
		} catch (Exception e) {
			throw new NoUserStoredException("The encrypted user could not be decrypted.", e);
		}

		// Try to parse the user json.
		ObjectMapper mapper = new ObjectMapper();
		try {
			User user = mapper.readValue(userJSON, User.class);

			return user;
		} catch (IOException e) {
			throw new NoUserStoredException("The user string could not be parsed.", e);
		}
	}

	/**
	 * Clear user from the shared preferences.
	 *
	 * @param context The current application context to access the applications shared preferences.
	 * @throws AuthException in case the user could not be deleted.
	 */
	private void clearUser(Context context) throws AuthException {
		// Get shared preferences from context.
		SharedPreferences sharedPref = context.getSharedPreferences(ThawUtil.SHARED_PREFS, Context.MODE_PRIVATE);

		// Store in shared preferences.
		SharedPreferences.Editor editor = sharedPref.edit();
		editor.remove(USER_KEY);

		if (!editor.commit()) {
			throw new AuthException("Could not clear the stored user.");
		}
	}

}
