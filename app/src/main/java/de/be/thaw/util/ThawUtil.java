package de.be.thaw.util;

import android.os.Build;
import android.text.Html;
import android.text.Spanned;

import java.text.SimpleDateFormat;
import java.util.Calendar;

/**
 * Created by Benjamin Eder on 14.02.2017.
 */
public class ThawUtil {

	public static final String SHARED_PREFS = "de.be.thaw.prefs";

	public static Calendar cachedDate = null;

	/**
	 * Create a Spanned Object for showing HTML in a TextView.
	 * Simply use <code>setText()</code> of the TextView to the returned Spanned Object.
	 *
	 * @param str
	 * @return
	 */
	public static Spanned fromHTML(String str) {
		if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N) { // Below Nougat
			return Html.fromHtml(str);
		} else { // Nougat or above
			return Html.fromHtml(str, Html.FROM_HTML_MODE_COMPACT);
		}
	}

}
