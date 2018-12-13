import 'package:guide7/connect/credential/local_credentials_repository.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';

/// Repository interface.
abstract class RepositoryI {
  /// Get local credentials repository.
  LocalCredentialsRepository<UsernamePasswordCredentials> getLocalCredentialsRepository();
}
