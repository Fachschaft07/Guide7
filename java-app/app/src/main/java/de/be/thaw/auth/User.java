package de.be.thaw.auth;

import com.fasterxml.jackson.annotation.JsonCreator;
import com.fasterxml.jackson.annotation.JsonProperty;

/**
 * A User representation.
 * <p>
 * Created by Benjamin Eder on 01.05.2017.
 */
public class User {

	/**
	 * Users name.
	 */
	@JsonProperty("name")
	private String name;

	/**
	 * Users group (e. g. IF1A).
	 */
	@JsonProperty("group")
	private String group;

	/**
	 * Credentials to log in ZPA.
	 */
	@JsonProperty("credential")
	private final Credential credential;

	/**
	 * Copy constructor.
	 *
	 * @param copy the user to copy.
	 */
	public User(User copy) {
		this.name = copy.getName();
		this.group = copy.getGroup();
		this.credential = copy.getCredential();
	}

	/**
	 * Create new User.
	 * Note: This is also used by jackson to preserve the immutablilty of a credential.
	 *
	 * @param name       The name of the user.
	 * @param group      The group of the user (e. g. IF1A).
	 * @param credential The credential used to login to ZPA.
	 */
	@JsonCreator
	public User(@JsonProperty("name") String name,
				@JsonProperty("group") String group,
				@JsonProperty("credential") Credential credential) {
		this.name = name;
		this.group = group;
		this.credential = credential;
	}

	/**
	 * Get Name of the user.
	 *
	 * @return
	 */
	public String getName() {
		return name;
	}

	/**
	 * Set the name of the user.
	 *
	 * @param name new name.
	 */
	public void setName(String name) {
		this.name = name;
	}

	/**
	 * Get group of this user (e. g. IF1A).
	 *
	 * @return
	 */
	public String getGroup() {
		return group;
	}

	/**
	 * Set group of this user.
	 *
	 * @param group
	 */
	public void setGroup(String group) {
		this.group = group;
	}

	/**
	 * Get credential for ZPA login.
	 *
	 * @return
	 */
	public Credential getCredential() {
		return credential;
	}

	@Override
	public String toString() {
		return "User \"" + name + "\" (" + group + ")";
	}

}
