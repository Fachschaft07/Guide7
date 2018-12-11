package de.be.thaw.connect.parser.exception;

public class ParseException extends Exception {

    /**
	 * 
	 */
	private static final long serialVersionUID = 5439028174305874858L;

	public ParseException() {
        super();
    }

    public ParseException(String message) {
        super(message);
    }

    public ParseException(String message, Throwable cause) {
        super(message, cause);
    }

    public ParseException(Throwable cause) {
        super(cause);
    }
	
}
