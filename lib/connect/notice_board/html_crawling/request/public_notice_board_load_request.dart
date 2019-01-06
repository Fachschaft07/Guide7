import 'package:guide7/connect/login/zpa/util/zpa_variables.dart';
import 'package:guide7/connect/notice_board/html_crawling/request/notice_board_load_request.dart';
import 'package:http/http.dart' as http;

/// Load request for public notice board entries.
class PublicNoticeBoardLoadRequest implements NoticeBoardLoadRequest {
  /// Resource where to find the notice board entries.
  static const String _resource = "public/notice_board/";

  @override
  Future<http.Response> doRequest() async {
    return await http.get("${ZPAVariables.url}/$_resource");
  }
}
