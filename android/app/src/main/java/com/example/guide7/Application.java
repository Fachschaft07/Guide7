import com.transistorsoft.flutter.backgroundfetch.BackgroundFetchPlugin;

public class Application extends FlutterApplication implements PluginRegistrantCallback {
	@Override
	public void onCreate() {
		super.onCreate();
		BackgroundFetchPlugin.setPluginRegistrant(this);
	}

	@Override
	public void registerWith(PluginRegistry registry) {
		GeneratedPluginRegistrant.registerWith(registry);
	}
}