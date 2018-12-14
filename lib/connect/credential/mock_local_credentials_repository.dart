import 'package:guide7/connect/credential/local_credentials_repository.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';

/// Local credentials repository used for tests.
class MockLocalCredentialsRepository implements LocalCredentialsRepository<UsernamePasswordCredentials> {
  /// Locally cached credentials.
  static UsernamePasswordCredentials _credentials;

  @override
  Future<UsernamePasswordCredentials> loadLocalCredentials() {
    return Future.value(_credentials);
  }

  @override
  Future<void> storeLocalCredentials(UsernamePasswordCredentials credentials) {
    _credentials = credentials;

    return Future.value();
  }
}
