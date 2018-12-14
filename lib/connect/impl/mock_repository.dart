import 'package:guide7/connect/credential/local_credentials_repository.dart';
import 'package:guide7/connect/credential/mock_local_credentials_repository.dart';
import 'package:guide7/connect/login/zpa/mock_zpa_login_repository.dart';
import 'package:guide7/connect/login/zpa/zpa_login_repository.dart';
import 'package:guide7/connect/repository_interface.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';

/// Repository implementation used for tests.
class MockRepository implements RepositoryI {
  @override
  LocalCredentialsRepository<UsernamePasswordCredentials> getLocalCredentialsRepository() => MockLocalCredentialsRepository();

  @override
  ZPALoginRepository getZPALoginRepository() => MockZPALoginRepository();
}
