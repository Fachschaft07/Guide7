package de.be.thaw.encryption;

/**
 * Created by Benjamin Eder on 14.03.2017.
 */

public class SecretKeyGen {

	private static final class InstanceHolder {
		static final SecretKeyGen INSTANCE = new SecretKeyGen();
	}

	public static SecretKeyGen getInstance() {
		return InstanceHolder.INSTANCE;
	}

	private SecretKeyGen() {

	}

	static {
		System.loadLibrary("native-lib");
	}

	public native byte[] getSecretKey();

}
