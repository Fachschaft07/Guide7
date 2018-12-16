import 'package:guide7/connect/login/zpa/util/zpa_variables.dart';
import 'package:guide7/connect/notice_board/parser/notice_board_html_parser.dart';
import 'package:guide7/storage/notice_board/notice_board_storage.dart';
import 'package:guide7/util/parser/parser.dart';
import 'package:http/http.dart' as http;

import 'package:guide7/connect/login/zpa/response/zpa_login_response.dart';
import 'package:guide7/connect/notice_board/notice_board_repository.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/model/notice_board/notice_board_entry.dart';

/// Notice board repository fetching entries from ZPA services.
class HTMLCrawlingNoticeBoardRepository implements NoticeBoardRepository {
  /// Resource where to find the notice board entries.
  static const String _resource = "student/notice_board/";

  /// Parser converting HTML to notice board entries.
  static const Parser<String, List<NoticeBoardEntry>> _noticeBoardParser = NoticeBoardHtmlParser();

  @override
  Future<List<NoticeBoardEntry>> loadEntries() async {
    ZPALoginResponse loginResponse;
    try {
      loginResponse = await _zpaLogin();
    } catch (e) {
      throw Exception("Could not fetch notice board entries as the ZPA login failed.");
    }

    http.Response httpResponse = await http.get("${ZPAVariables.url}/$_resource", headers: {"cookie": loginResponse.cookie});

    if (httpResponse.statusCode == 200) {
      try {
        List<NoticeBoardEntry> entries = _noticeBoardParser.parse(httpResponse.body);

        // Cache values.
        await _storeEntries(entries);

        return entries;
      } catch (e) {
        throw Exception("Could not parse notice board entries.");
      }
    } else {
      throw Exception("Could not fetch notice board entries due to bad status code.");
    }
  }

  @override
  Future<List<NoticeBoardEntry>> getCachedEntries() async {
    var storage = NoticeBoardStorage();
    return await storage.read();
  }

  @override
  Future<bool> hasCachedEntries() async {
    var storage = NoticeBoardStorage();
    return !(await storage.isEmpty());
  }

  /// Store entries in cache for later retrieval.
  Future<void> _storeEntries(List<NoticeBoardEntry> entries) async {
    var storage = NoticeBoardStorage();

    await storage.write(entries);
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
