package de.be.thaw.encryption;

/**
 * Created by Benjamin Eder on 14.03.2017.
 */
public class SecretKeyGen {

	private static final byte[] KEY = new byte[] {0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15};

	private static final class InstanceHolder {
		static final SecretKeyGen INSTANCE = new SecretKeyGen();
	}

	public static SecretKeyGen getInstance() {
		return InstanceHolder.INSTANCE;
	}

	private SecretKeyGen() {
		// Hide constructor
	}

	public byte[] getSecretKey() {
		return KEY;
	}

}
