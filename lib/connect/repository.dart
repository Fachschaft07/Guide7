import 'package:guide7/connect/credential/local_credentials_repository.dart';
import 'package:guide7/connect/impl/default_repository.dart';
import 'package:guide7/connect/repository_interface.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';

/// Repository factory used to fetch repositories for various resources.
/// Since it is used all over the application it is implemented as a singleton.
class Repository implements RepositoryI {
  /// Repository instance.
  static final Repository _instance = new Repository();

  /// Delegated repository implementation to use.
  static RepositoryI _delegate;

  /// Retrieve the Repository instance.
  factory Repository() {
    if (_delegate == null) {
      _delegate = DefaultRepository();
    }

    return _instance;
  }

  /// Set the repository implementation to use for further repository calls.
  static setRepositoryImplementation(RepositoryI implementation) => Repository._delegate = implementation;

  /// Internal constructor.
  Repository._internal();

  @override
  LocalCredentialsRepository<UsernamePasswordCredentials> getLocalCredentialsRepository() => _delegate.getLocalCredentialsRepository();
}
