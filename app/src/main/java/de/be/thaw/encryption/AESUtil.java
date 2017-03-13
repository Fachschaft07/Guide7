package de.be.thaw.encryption;

import java.security.SecureRandom;

import javax.crypto.Cipher;
import javax.crypto.KeyGenerator;
import javax.crypto.SecretKey;
import javax.crypto.spec.SecretKeySpec;

/**
 * Utility class giving support by encrypting or decrypting using AES.
 * <p>
 * Created by Benjamin Eder on 13.02.2017.
 */
public class AESUtil {

    private final static String HEX = "0123456789ABCDEF";

    private final static byte[] KEY = new byte[] {20, -74, 43, 53, 8, 32, -67, -111, 90, 68, -85, -7, -85, -54, -83, -65};

    /**
     * Encrypt some plaintext using AES.
     *
     * @param plaintext
     * @return
     * @throws Exception
     */
    public static String encrypt(String plaintext) throws Exception {
        byte[] rawKey = KEY;
        byte[] result = encrypt(rawKey, plaintext.getBytes());

        return toHex(result);
    }

    /**
     * Decrypt some encrypted message using AES.
     *
     * @param encrypted
     * @return
     * @throws Exception
     */
    public static String decrypt(String encrypted) throws Exception {
        byte[] rawKey = KEY;
        byte[] enc = toByte(encrypted);
        byte[] result = decrypt(rawKey, enc);

        return new String(result);
    }

    /**
     * Encrypt some plaintext using AES.
     *
     * @param seed
     * @param plaintext
     * @return
     * @throws Exception
     */
    public static String encrypt(String seed, String plaintext) throws Exception {
        byte[] rawKey = getRawKey(seed.getBytes());
        byte[] result = encrypt(rawKey, plaintext.getBytes());

        return toHex(result);
    }

    /**
     * Decrypt some encrypted message using AES.
     *
     * @param seed
     * @param encrypted
     * @return
     * @throws Exception
     */
    public static String decrypt(String seed, String encrypted) throws Exception {
        byte[] rawKey = getRawKey(seed.getBytes());
        byte[] enc = toByte(encrypted);
        byte[] result = decrypt(rawKey, enc);

        return new String(result);
    }

    /**
     * Get raw Key.
     *
     * @param seed
     * @return
     * @throws Exception
     */
    private static byte[] getRawKey(byte[] seed) throws Exception {
        KeyGenerator keyGen = KeyGenerator.getInstance("AES");
        SecureRandom sr = SecureRandom.getInstance("SHA1PRNG");
        sr.setSeed(seed);

        keyGen.init(128, sr);

        SecretKey secretKey = keyGen.generateKey();

        byte[] raw = secretKey.getEncoded();

        return raw;
    }

    /**
     * Encrypt the passed cleartext Byte array with the passed raw key.
     *
     * @param raw
     * @param clear
     * @return
     * @throws Exception
     */
    private static byte[] encrypt(byte[] raw, byte[] clear) throws Exception {
        SecretKeySpec secretKeySpec = new SecretKeySpec(raw, "AES");

        Cipher cipher = Cipher.getInstance("AES");
        cipher.init(Cipher.ENCRYPT_MODE, secretKeySpec);

        byte[] encrypted = cipher.doFinal(clear);

        return encrypted;
    }

    /**
     * Decrypt the passed encrypted Byte array with the passed raw key.
     *
     * @param raw
     * @param encrypted
     * @return
     * @throws Exception
     */
    private static byte[] decrypt(byte[] raw, byte[] encrypted) throws Exception {
        SecretKeySpec secretKeySpec = new SecretKeySpec(raw, "AES");

        Cipher cipher = Cipher.getInstance("AES");
        cipher.init(Cipher.DECRYPT_MODE, secretKeySpec);

        byte[] decrypted = cipher.doFinal(encrypted);

        return decrypted;
    }

    /**
     * Convert the passed String to Hex.
     *
     * @param string
     * @return
     */
    public static String toHex(String string) {
        return toHex(string.getBytes());
    }

    /**
     * Convert Hex code to String.
     *
     * @param hex
     * @return
     */
    public static String fromHex(String hex) {
        return new String(toByte(hex));
    }

    /**
     * Convert hex String to byte Array.
     * @param hexString
     * @return
     */
    public static byte[] toByte(String hexString) {
        int length = hexString.length() / 2;
        byte[] result = new byte[length];

        for (int i = 0; i < length; i++) {
            result[i] = Integer.valueOf(hexString.substring(2 * i, 2 * i + 2), 16).byteValue();
        }

        return result;
    }

    /**
     * Convert byte array to hex string.
     * @param buffer
     * @return
     */
    public static String toHex(byte[] buffer) {
        if (buffer == null) {
            return "";
        }

        StringBuffer result = new StringBuffer(2 * buffer.length);

        for (int i = 0; i < buffer.length; i++) {
            appendHex(result, buffer[i]);
        }

        return result.toString();
    }

    /**
     * Append hex code.
     * @param sb
     * @param b
     */
    private static void appendHex(StringBuffer sb, byte b) {
        sb.append(HEX.charAt((b >> 4) & 0x0f)).append(HEX.charAt(b & 0x0f));
    }

}
