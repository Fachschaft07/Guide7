package de.be.thaw.auth;

import android.app.Activity;
import android.util.Log;

import java.io.IOException;
import java.io.InputStream;
import java.security.KeyManagementException;
import java.security.KeyStore;
import java.security.KeyStoreException;
import java.security.NoSuchAlgorithmException;
import java.security.cert.Certificate;
import java.security.cert.CertificateException;
import java.security.cert.CertificateFactory;
import java.security.cert.X509Certificate;

import javax.net.ssl.HttpsURLConnection;
import javax.net.ssl.SSLContext;
import javax.net.ssl.TrustManagerFactory;

import de.be.thaw.R;

/**
 * Created by Benjamin Eder on 23.02.2017.
 */

public class CertificateUtil {

	public static boolean certificatesInitialized = false;

	/**
	 * Initialize Certificates needed for save connections.
	 *
	 * @throws CertificateException
	 * @throws IOException
	 * @throws KeyStoreException
	 * @throws NoSuchAlgorithmException
	 * @throws KeyManagementException
	 */
	public static void initCertificate(Activity activity) throws CertificateException, IOException, KeyStoreException, NoSuchAlgorithmException, KeyManagementException {
		if (!certificatesInitialized) {
			// Load CAs from an InputStream
			CertificateFactory cf = CertificateFactory.getInstance("X.509");

			InputStream is = activity.getResources().openRawResource(R.raw.zpa);
			Certificate zpaCert;
			try {
				zpaCert = cf.generateCertificate(is);
				Log.i("Login", "ca=" + ((X509Certificate) zpaCert).getSubjectDN());
			} finally {
				is.close();
			}

			is = activity.getResources().openRawResource(R.raw.w3);
			Certificate w3Cert;
			try {
				w3Cert = cf.generateCertificate(is);
				Log.i("Login", "ca=" + ((X509Certificate) w3Cert).getSubjectDN());
			} finally {
				is.close();
			}

			// Create a KeyStore containing our trusted CAs
			String keyStoreType = KeyStore.getDefaultType();
			KeyStore keyStore = KeyStore.getInstance(keyStoreType);
			keyStore.load(null, null);
			keyStore.setCertificateEntry("zpa", zpaCert);
			keyStore.setCertificateEntry("w3", w3Cert);

			// Create a TrustManager that trusts the CAs in our KeyStore
			String tmfAlgorithm = TrustManagerFactory.getDefaultAlgorithm();
			TrustManagerFactory tmf = TrustManagerFactory.getInstance(tmfAlgorithm);
			tmf.init(keyStore);

			// Create an SSLContext that uses our TrustManager
			SSLContext context = SSLContext.getInstance("TLS");
			context.init(null, tmf.getTrustManagers(), null);

			// Set as default ssl context.
			HttpsURLConnection.setDefaultSSLSocketFactory(context.getSocketFactory());

			certificatesInitialized = true;
		}
	}

}
