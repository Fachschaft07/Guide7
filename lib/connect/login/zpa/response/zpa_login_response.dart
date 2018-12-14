import 'package:meta/meta.dart';

/// Response you get from the ZPA login web service.
class ZPALoginResponse {
  /// CSRF token of the ZPA.
  final String csrfToken;

  /// Cookie used to authenticate with ZPA.
  final String cookie;

  /// Error code.
  final int errorCode;

  /// Create new ZPA response returned from login web service.
  ZPALoginResponse({@required this.csrfToken, @required this.cookie, @required this.errorCode});

  /// Create login response from JSON.
  factory ZPALoginResponse.fromJson(Map<String, dynamic> json, String cookie) {
    return ZPALoginResponse(
      cookie: cookie,
      csrfToken: json["csrfmiddlewaretoken"],
      errorCode: json["error_code"],
    );
  }
}
