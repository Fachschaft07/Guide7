import 'package:meta/meta.dart';

/// Logout response from ZPA web service.
class ZPALogoutResponse {
  /// Error code received from logout.
  final int errorCode;

  /// Create new ZPA logout response.
  ZPALogoutResponse({@required this.errorCode});

  /// Create ZPA logout response from JSON.
  factory ZPALogoutResponse.fromJson(Map<String, dynamic> json) {
    return ZPALogoutResponse(errorCode: json["error_code"]);
  }
}
