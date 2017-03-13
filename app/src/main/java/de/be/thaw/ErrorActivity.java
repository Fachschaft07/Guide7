package de.be.thaw;

import android.content.Intent;
import android.support.v7.app.AppCompatActivity;
import android.os.Bundle;
import android.widget.TextView;

import de.be.thaw.exception.ExceptionHandler;

public class ErrorActivity extends AppCompatActivity {

	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		setContentView(R.layout.activity_error);

		Intent intent = getIntent();
		String errorMessage = intent.getStringExtra(ExceptionHandler.ERROR_EXTRA);

		TextView errorView = (TextView) findViewById(R.id.errorView);
		errorView.setText(errorMessage);
	}
}
