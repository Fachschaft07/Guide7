package com.example.guide7;

import android.os.Bundle;
import io.flutter.app.FlutterActivity;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.PluginRegistry;
import com.transistorsoft.flutter.backgroundfetch.BackgroundFetchPlugin;

public class Application extends FlutterActivity implements PluginRegistry.PluginRegistrantCallback {
	@Override
	protected void onCreate(Bundle savedInstanceState) {
		super.onCreate(savedInstanceState);
		GeneratedPluginRegistrant.registerWith(this);
		BackgroundFetchPlugin.setPluginRegistrant(this);
	}

	@Override
	public void registerWith(PluginRegistry registry) {
		GeneratedPluginRegistrant.registerWith(registry);
	}
}