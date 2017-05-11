package de.be.thaw.auth;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * Credentials consisting of a username and password.
 * <p>
 * Created by Benjamin Eder on 12.02.2017.
 */
public class Credential {

	/**
	 * The Username.
	 */
	@JsonProperty("username")
	private final String username;

	/**
	 * The password.
	 */
	@JsonProperty("password")
	private final String password;

	/**
	 * Create new credential.
	 * This is also used by jackson to create an immutable instance.
	 *
	 * @param username The username of the credential.
	 * @param password The password of the credential.
	 */
	@JsonCreator
	public Credential(@JsonProperty("username") String username,
					  @JsonProperty("password") String password) {
		if (username == null || password == null) {
			throw new NullPointerException("Credential username or password cannot be null.");
		}

		this.username = username;
		this.password = password;
	}

	/**
	 * Get the credentials username.
	 *
	 * @return
	 */
	public String getUsername() {
		return username;
	}

	/**
	 * Get the credentials password.
	 *
	 * @return
	 */
	public String getPassword() {
		return password;
	}

}
