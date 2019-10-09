import 'dart:async';

import 'package:guide7/connect/login/zpa/response/zpa_login_response.dart';
import 'package:guide7/connect/login/zpa/util/zpa_variables.dart';
import 'package:guide7/connect/notice_board/html_crawling/request/notice_board_load_request.dart';
import 'package:guide7/connect/repository.dart';
import 'package:http/http.dart' as http;

/// Load request for personal notice board entries.
class PersonalNoticeBoardLoadRequest implements NoticeBoardLoadRequest {
  /// Resource where to find the notice board entries.
  static const String _resource = "student/notice_board/";

  @override
  Future<http.Response> doRequest() async {
    ZPALoginResponse loginResponse;
    try {
      loginResponse = await _zpaLogin();
    } catch (e) {
      throw Exception("Could not fetch notice board entries as the ZPA login failed.");
    }

    return await http.get("${ZPAVariables.url}/$_resource", headers: {"Cookie": loginResponse.cookie});
  }

  /// Do the login to the ZPA services.
  Future<ZPALoginResponse> _zpaLogin() async {
    Repository repo = Repository();

    ZPALoginResponse loginResponse = await repo.getZPALoginRepository().tryLogin(await repo.getLocalCredentialsRepository().loadLocalCredentials());

    if (loginResponse == null) {
      throw Exception("Login to ZPA failed.");
    }

    return loginResponse;
  }
}
