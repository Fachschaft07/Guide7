import 'dart:async';

import 'package:guide7/connect/notice_board/html_crawling/request/notice_board_load_request.dart';
import 'package:guide7/connect/notice_board/html_crawling/request/personal_notice_board_load_request.dart';
import 'package:guide7/connect/notice_board/html_crawling/request/public_notice_board_load_request.dart';
import 'package:guide7/connect/notice_board/parser/notice_board_html_parser.dart';
import 'package:guide7/storage/notice_board/notice_board_storage.dart';
import 'package:guide7/util/parser/parser.dart';
import 'package:guide7/util/zpa.dart';
import 'package:http/http.dart' as http;

import 'package:guide7/connect/notice_board/notice_board_repository.dart';
import 'package:guide7/model/notice_board/notice_board_entry.dart';

/// Notice board repository fetching entries from ZPA services.
class HTMLCrawlingNoticeBoardRepository implements NoticeBoardRepository {
  /// Parser converting HTML to notice board entries.
  static const Parser<String, List<NoticeBoardEntry>> _noticeBoardParser = NoticeBoardHtmlParser();

  @override
  Future<List<NoticeBoardEntry>> loadEntries() async {
    NoticeBoardLoadRequest loadRequest = await _hasCredentials() ? PersonalNoticeBoardLoadRequest() : PublicNoticeBoardLoadRequest();

    http.Response httpResponse = await loadRequest.doRequest();

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

  /// Check if credentials are available.
  Future<bool> _hasCredentials() async {
    return await ZPA.isLoggedIn();
  }
}
