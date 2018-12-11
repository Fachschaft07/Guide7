package de.be.thaw.ui;

import android.app.Activity;
import android.support.design.widget.Snackbar;

/**
 * Snackbar which can be used to load multiple weeks in the WeekView without popping up twice.
 *
 * Created by Benjamin Eder on 22.04.2017.
 */
public class LoadSnackbar {

	private final Snackbar snackbar;

	private int shownCount = 0;

	public LoadSnackbar(Snackbar snackbar) {
		this.snackbar = snackbar;
	}

	public void show() {
		if (!snackbar.isShownOrQueued()) {
			snackbar.show();
		}

		synchronized (this) {
			shownCount++;
		}
	}

	public void dismiss() {
		synchronized (this) {
			shownCount--;
		}

		if (shownCount == 0 && snackbar.isShownOrQueued()) {
			snackbar.dismiss();
		}
	}

}
