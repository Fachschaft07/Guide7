import 'package:guide7/connect/notice_board/notice_board_repository.dart';
import 'package:guide7/model/notice_board/notice_board_entry.dart';

/// Notice board repository for testing purposes.
class MockNoticeBoardRepository implements NoticeBoardRepository {
  static List<NoticeBoardEntry> _entries = [
    NoticeBoardEntry(author: "Test Author", title: "Test Title", content: "Test Content", validFrom: DateTime(2018, 1, 1), validTo: DateTime(2018, 1, 2))
  ];

  @override
  Future<List<NoticeBoardEntry>> loadEntries() async => _entries;

  @override
  Future<List<NoticeBoardEntry>> getCachedEntries() async => _entries;

  @override
  Future<bool> hasCachedEntries() async => true;
}
