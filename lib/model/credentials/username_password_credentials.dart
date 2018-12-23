import 'package:guide7/model/credentials/credentials.dart';
import 'package:meta/meta.dart';

/// Simple credentials which can be used to authenticate the user by username and password.
class UsernamePasswordCredentials implements Credentials {
  /// Name of the user.
  final String username;

  /// Password of the user.
  final String password;

  /// Create new credentials.
  UsernamePasswordCredentials({
    @required this.username,
    @required this.password,
  });
}
