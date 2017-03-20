package de.be.thaw.connect.zpa.exception;

public class ZPABadCredentialsException extends Exception {

    /**
	 *
	 */
	private static final long serialVersionUID = 5439028174305874858L;

	public ZPABadCredentialsException() {
        super();
    }

    public ZPABadCredentialsException(String message) {
        super(message);
    }

    public ZPABadCredentialsException(String message, Throwable cause) {
        super(message, cause);
    }

    public ZPABadCredentialsException(Throwable cause) {
        super(cause);
    }
	
}
