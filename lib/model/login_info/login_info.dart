import 'package:meta/meta.dart';

/// Additional info the login dialog generates.
class LoginInfo {
  /// Whether the login has been skipped.
  final bool skippedLogin;

  /// Create login info
  LoginInfo({
    @required this.skippedLogin,
  });
}
