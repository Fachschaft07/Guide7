import 'dart:async';

import 'package:guide7/connect/credential/local_username_password_credential_repository.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';

/// Utilities for the ZPA student services.
class ZPA {
  /// Check if user is currently logged in.
  static Future<bool> isLoggedIn() async {
    // Check if credentials are present.
    Repository repo = Repository();
    LocalUsernamePasswordCredentialsRepository credentialsRepository = repo.getLocalCredentialsRepository();

    UsernamePasswordCredentials credentials = await credentialsRepository.loadLocalCredentials();

    return credentials.username != null && credentials.password != null;
  }
}
