package de.be.thaw.ui;

import android.app.ProgressDialog;
import android.content.DialogInterface;
import android.support.v4.app.FragmentActivity;

import java.util.ArrayList;
import java.util.List;

/**
 * Created by Benjamin Eder on 15.02.2017.
 */
public class ProgressDialogManager {

	private final ProgressDialog dialog;

	private int dialogsShown = 0;

	private List<DialogInterface.OnCancelListener> addOnCancelListeners;

	public ProgressDialogManager(ProgressDialog dialog) {
		this.dialog = dialog;

		dialog.setOnCancelListener(new DialogInterface.OnCancelListener() {

			@Override
			public void onCancel(DialogInterface dialog) {
				if (addOnCancelListeners != null) {
					for (DialogInterface.OnCancelListener l : addOnCancelListeners) {
						l.onCancel(dialog);
					}
				}
			}

		});
	}

	public void show() {
		if (!dialog.isShowing()) {
			dialog.show();
		}

		dialogsShown++;
	}

	public void dismiss() {
		dialogsShown--;

		if (dialogsShown == 0 && dialog.isShowing()) {
			dialog.dismiss();
		}
	}

	public boolean isShowing() {
		return dialog.isShowing();
	}

	public void setMessage(String message) {
		dialog.setMessage(message);
	}

	public void setTitle(String title) {
		dialog.setTitle(title);
	}

	public void addOnCancelListener(DialogInterface.OnCancelListener listener) {
		if (addOnCancelListeners == null) {
			addOnCancelListeners = new ArrayList<>();
		}

		addOnCancelListeners.add(listener);
	}

}
