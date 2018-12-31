package com.example.guide7;

import io.flutter.app.FlutterApplication;
import io.flutter.plugins.GeneratedPluginRegistrant;
import io.flutter.plugin.common.PluginRegistry;
import com.transistorsoft.flutter.backgroundfetch.BackgroundFetchPlugin;

public class Application extends FlutterApplication implements PluginRegistry.PluginRegistrantCallback {
	@Override
	public void onCreate() {
		super.onCreate();
		BackgroundFetchPlugin.setPluginRegistrant(this);
	}

	@Override
	public void registerWith(PluginRegistry pluginRegistry) {
		GeneratedPluginRegistrant.registerWith(pluginRegistry);
	}
}