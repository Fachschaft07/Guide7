package de.be.thaw.auth.exception;

/**
 * Exception thrown when a user has not yet been stored.
 *
 * Created by Benjamin Eder on 01.05.2017.
 */
public class NoUserStoredException extends AuthException {

	public NoUserStoredException() {
		super();
	}

	public NoUserStoredException(String message) {
		super(message);
	}

	public NoUserStoredException(String message, Throwable cause) {
		super(message, cause);
	}

	public NoUserStoredException(Throwable cause) {
		super(cause);
	}

}
