import 'package:http/http.dart' as http;

/// Load request for the notice board html crawler repository.
abstract class NoticeBoardLoadRequest {
  /// Get the request to parse notice board entries from.
  Future<http.Response> doRequest();
}
