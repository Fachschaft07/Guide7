package de.be.thaw.connect.zpa.exception;

public class ZPALoginFailedException extends Exception {

    /**
	 * 
	 */
	private static final long serialVersionUID = 5439028174305874858L;

	public ZPALoginFailedException() {
        super();
    }

    public ZPALoginFailedException(String message) {
        super(message);
    }

    public ZPALoginFailedException(String message, Throwable cause) {
        super(message, cause);
    }

    public ZPALoginFailedException(Throwable cause) {
        super(cause);
    }
	
}
