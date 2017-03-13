package de.be.thaw.zpa.exception;

public class InvalidDateException extends Exception {

    /**
	 *
	 */
	private static final long serialVersionUID = 5439028174305874858L;

	public InvalidDateException() {
        super();
    }

    public InvalidDateException(String message) {
        super(message);
    }

    public InvalidDateException(String message, Throwable cause) {
        super(message, cause);
    }

    public InvalidDateException(Throwable cause) {
        super(cause);
    }
	
}
