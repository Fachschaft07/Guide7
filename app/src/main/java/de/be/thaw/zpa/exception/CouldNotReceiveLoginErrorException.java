package de.be.thaw.zpa.exception;

public class CouldNotReceiveLoginErrorException extends Exception {

	/**
	 *
	 */
	private static final long serialVersionUID = -22783527453585123L;

    public CouldNotReceiveLoginErrorException() {
        super();
    }

    public CouldNotReceiveLoginErrorException(String message) {
        super(message);
    }

    public CouldNotReceiveLoginErrorException(String message, Throwable cause) {
        super(message, cause);
    }

    public CouldNotReceiveLoginErrorException(Throwable cause) {
        super(cause);
    }
	
}
