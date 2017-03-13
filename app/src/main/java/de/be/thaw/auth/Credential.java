package de.be.thaw.auth;

/**
 * Created by Benjamin Eder on 12.02.2017.
 */

public class Credential {

    private final String username;
    private final String password;

    public Credential(String username, String password) {
        this.username = username;
        this.password = password;
    }

    public String getUsername() {
        return username;
    }

    public String getPassword() {
        return password;
    }

    public boolean isEmpty() {
        return username == null || username.isEmpty() || password == null || password.isEmpty();
    }

    public boolean hasUsername() {
        return username != null;
    }

    public boolean hasPassword() {
        return password != null;
    }

}
