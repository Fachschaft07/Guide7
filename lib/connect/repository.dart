import 'package:guide7/connect/credential/local_credentials_repository.dart';
import 'package:guide7/connect/impl/default_repository.dart';
import 'package:guide7/connect/login/zpa/zpa_login_repository.dart';
import 'package:guide7/connect/notice_board/notice_board_repository.dart';
import 'package:guide7/connect/repository_interface.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';
import 'package:guide7/util/functional_interfaces.dart';

/// Repository factory used to fetch repositories for various resources.
/// Since it is used all over the application it is implemented as a singleton.
class Repository implements RepositoryI {
  /// Repository instance.
  static final Repository _instance = Repository._internal();

  /// Delegated repository implementation to use.
  static RepositoryI _delegate;

  /// Cached instance of the local credential repository.
  LocalCredentialsRepository<UsernamePasswordCredentials> _localCredentialsRepository;

  /// Cached instance of the ZPA login repository instance.
  ZPALoginRepository _zpaLoginRepository;

  /// Cached instance of the notice board repository.
  NoticeBoardRepository _noticeBoardRepository;

  /// Retrieve the Repository instance.
  factory Repository() {
    if (_delegate == null) {
      _delegate = DefaultRepository();
    }

    return _instance;
  }

  /// Internal constructor.
  Repository._internal();

  /// Set the repository implementation to use for further repository calls.
  static setRepositoryImplementation(RepositoryI implementation) => Repository._delegate = implementation;

  @override
  LocalCredentialsRepository<UsernamePasswordCredentials> getLocalCredentialsRepository() {
    if (_localCredentialsRepository == null) {
      _localCredentialsRepository = _delegate.getLocalCredentialsRepository();
    }

    return _localCredentialsRepository;
  }

  @override
  ZPALoginRepository getZPALoginRepository() {
    if (_zpaLoginRepository == null) {
      _zpaLoginRepository = _delegate.getZPALoginRepository();
    }

    return _zpaLoginRepository;
  }

  @override
  NoticeBoardRepository getNoticeBoardRepository() {
    if (_noticeBoardRepository == null) {
      _noticeBoardRepository = _delegate.getNoticeBoardRepository();
    }

    return _noticeBoardRepository;
  }
}