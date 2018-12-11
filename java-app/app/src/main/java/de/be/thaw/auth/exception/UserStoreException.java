package de.be.thaw.auth.exception;

/**
 * Exception thrown when a user could not be stored.
 * 
 * Created by Benjamin Eder on 01.05.2017.
 */
public class UserStoreException extends AuthException {

	public UserStoreException() {
		super();
	}

	public UserStoreException(String message) {
		super(message);
	}

	public UserStoreException(String message, Throwable cause) {
		super(message, cause);
	}

	public UserStoreException(Throwable cause) {
		super(cause);
	}

}
