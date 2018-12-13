import 'package:guide7/model/notice_board/notice_board_entry.dart';

/// Repository interface for managing notice board entries.
abstract class NoticeBoardRepository {
  /// Get all stored notice board entries.
  Future<List<NoticeBoardEntry>> getEntries();

  /// Set notice board entries to store.
  Future<void> setEntries(List<NoticeBoardEntry> entries);
}
