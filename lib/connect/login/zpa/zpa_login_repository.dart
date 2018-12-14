import 'dart:convert';
import 'dart:io';

import 'package:guide7/connect/login/zpa/response/zpa_login_response.dart';
import 'package:guide7/connect/login/zpa/response/zpa_logout_response.dart';
import 'package:guide7/connect/login/zpa/util/zpa_variables.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';
import 'package:http/http.dart' as http;

import 'package:guide7/connect/login/login_repository.dart';
import 'package:meta/meta.dart';

/// Login repository to login to the ZPA system.
class ZPALoginRepository implements LoginRepository<UsernamePasswordCredentials, ZPALoginResponse> {
  /// The last login response from ZPA.
  ZPALoginResponse _lastLoginResponse;

  @override
  Future<ZPALoginResponse> tryLogin(UsernamePasswordCredentials credentials) async {
    try {
      final _CSRFTokenResponse csrfTokenResponse = await _getCSRFToken();

      HttpClient client = HttpClient();
      HttpClientRequest clientRequest = await client.postUrl(Uri.parse("${ZPAVariables.url}/login/ws_login/"));

      clientRequest.headers.contentType = ContentType("application", "x-www-form-urlencoded");
      clientRequest.write("csrfmiddlewaretoken=${csrfTokenResponse.csrfToken}&username=${credentials.username}&password=${credentials.password}");

      HttpClientResponse httpResponse = await clientRequest.close();

      if (httpResponse.statusCode == 200) {
        // Fetch cookie from response
        Cookie cookie = httpResponse.cookies.firstWhere((c) => c.name == "sessionid");

        if (cookie == null) {
          return null;
        }

        String cookieStr = "sessionid=${cookie.value}";
        String body = await httpResponse.transform(utf8.decoder).reduce((str1, str2) => str1 + str2);

        ZPALoginResponse loginResponse = ZPALoginResponse.fromJson(json.decode(body), cookieStr);

        bool success = loginResponse.errorCode == 0;

        if (success) {
          _lastLoginResponse = loginResponse;
        }

        return success ? loginResponse : null;
      } else {
        return null;
      }
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> tryLogout(ZPALoginResponse login) async {
    _lastLoginResponse = null;

    try {
      final http.Response response = await http.post("${ZPAVariables.url}/login/ws_logout", headers: {"cookie": login.cookie}).catchError((e) => throw (e));

      if (response.statusCode == 200) {
        ZPALogoutResponse logoutResponse = ZPALogoutResponse.fromJson(json.decode(response.body));

        return logoutResponse.errorCode == 0;
      } else {
        return false;
      }
    } catch (e) {
      return false;
    }
  }

  /// Get the CSRF token needed to login to ZPA.
  Future<_CSRFTokenResponse> _getCSRFToken() async {
    try {
      final response = await http.get("${ZPAVariables.url}/login/ws_get_csrf_token").catchError((e) => throw (e));

      if (response.statusCode == 200) {
        return _CSRFTokenResponse.fromJson(json.decode(response.body));
      } else {
        throw Exception("Could not get CSRF token.");
      }
    } catch (e) {
      throw Exception("Could not connect to ZPA.");
    }
  }

  @override
  ZPALoginResponse getLogin() => _lastLoginResponse;

  @override
  bool isLoggedIn() => _lastLoginResponse != null;
}

/// CSRF token call response from ZPA.
class _CSRFTokenResponse {
  /// The retrieved CSRF token.
  final String csrfToken;

  /// Create new CSRF token response.
  _CSRFTokenResponse({@required this.csrfToken});

  /// Create CSRF token response from JSON.
  factory _CSRFTokenResponse.fromJson(Map<String, dynamic> json) {
    return _CSRFTokenResponse(
      csrfToken: json["csrfmiddlewaretoken"],
    );
  }
}
