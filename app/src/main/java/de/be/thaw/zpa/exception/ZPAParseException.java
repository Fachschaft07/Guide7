package de.be.thaw.zpa.exception;

public class ZPAParseException extends Exception {

    /**
	 * 
	 */
	private static final long serialVersionUID = 5439028174305874858L;

	public ZPAParseException() {
        super();
    }

    public ZPAParseException(String message) {
        super(message);
    }

    public ZPAParseException(String message, Throwable cause) {
        super(message, cause);
    }

    public ZPAParseException(Throwable cause) {
        super(cause);
    }
	
}
