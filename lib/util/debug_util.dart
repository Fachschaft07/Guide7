/// Utility class for debugging the app.
class DebugUtil {
  /// Check if app is running in debug mode.
  static bool get isDebugMode {
    bool inDebugMode = false;

    // Assert statements are only executed in debug mode.
    assert(inDebugMode = true);

    return inDebugMode;
  }
}
