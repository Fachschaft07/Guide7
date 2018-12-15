import 'package:guide7/connect/credential/local_credentials_repository.dart';
import 'package:guide7/connect/login/zpa/zpa_login_repository.dart';
import 'package:guide7/connect/notice_board/notice_board_repository.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';

/// Repository interface.
abstract class RepositoryI {
  /// Get local credentials repository.
  LocalCredentialsRepository<UsernamePasswordCredentials> getLocalCredentialsRepository();

  /// Get login repository for the ZPA services.
  ZPALoginRepository getZPALoginRepository();

  /// Get repository holding notice board entries.
  NoticeBoardRepository getNoticeBoardRepository();
}
