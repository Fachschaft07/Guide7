package de.be.thaw.auth.exception;

/**
 * Exception thrown in the Auth Service.
 * 
 * Created by Benjamin Eder on 01.05.2017.
 */
public class AuthException extends Exception {

	public AuthException() {
		super();
	}

	public AuthException(String message) {
		super(message);
	}

	public AuthException(String message, Throwable cause) {
		super(message, cause);
	}

	public AuthException(Throwable cause) {
		super(cause);
	}

}
