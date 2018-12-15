import 'package:guide7/model/notice_board/notice_board_entry.dart';

/// Repository interface for managing notice board entries.
abstract class NoticeBoardRepository {
  /// Fetch all notice board entries from remote source.
  Future<List<NoticeBoardEntry>> loadEntries();

  /// Get all cached notice board entries.
  Future<List<NoticeBoardEntry>> getCachedEntries();

  /// Check if notice board entries have been cached.
  Future<bool> hasCachedEntries();
}
