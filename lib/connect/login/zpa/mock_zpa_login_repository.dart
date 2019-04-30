import 'dart:async';

import 'package:guide7/connect/login/zpa/response/zpa_login_response.dart';
import 'package:guide7/connect/login/zpa/zpa_login_repository.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';

/// Test login repository for the ZPA services.
class MockZPALoginRepository implements ZPALoginRepository {

  static ZPALoginResponse _loginResponse = ZPALoginResponse(csrfToken: "csrfToken", cookie: "sessionid=cookiestring", errorCode: 0);

  @override
  Future<ZPALoginResponse> tryLogin(UsernamePasswordCredentials credentials) async => _loginResponse;

  @override
  Future<bool> tryLogout(ZPALoginResponse response) async => true;

  @override
  ZPALoginResponse getLogin() => _loginResponse;

  @override
  bool isLoggedIn() => true;
}
