import 'package:connectivity/connectivity.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/model/notice_board/notice_board_entry.dart';
import 'package:guide7/util/notification/notification_manager.dart';
import 'package:guide7/util/notification/payload_handler/notice_board_payload_handler.dart';
import 'package:guide7/util/scheduler/task/background_task.dart';

/// Background task to refresh the notice board.
class NoticeBoardTask implements BackgroundTask {
  /// Constant constructor.
  const NoticeBoardTask();

  @override
  Future<void> execute() async {
    /// Check that internet connection is available first.
    var connectivityResult = await (new Connectivity().checkConnectivity());
    if (connectivityResult == ConnectivityResult.none) {
      return null;
    }

    var repository = Repository();
    var noticeBoardRepo = repository.getNoticeBoardRepository();

    // Compare cached entries and entries from server.
    if (!(await noticeBoardRepo.hasCachedEntries())) {
      return null;
    }

    List<NoticeBoardEntry> cached = await noticeBoardRepo.getCachedEntries();
    List<NoticeBoardEntry> fresh = await noticeBoardRepo.loadEntries();

    if (_hasNewEntries(cached, fresh)) {
      NotificationManager().showNotification(
        title: "Schwarzes Brett Update!",
        content: "Es gibt neue Einträge auf dem Schwarzen Brett.",
        payload: NoticeBoardPayloadHandler.payload,
      );
    }

    NotificationManager().showNotification(
      title: "TEST!",
      content: "Einfach so",
      payload: NoticeBoardPayloadHandler.payload,
    );
  }

  /// Check if there are new entries in [fresh] compared to [cached].
  bool _hasNewEntries(List<NoticeBoardEntry> cached, List<NoticeBoardEntry> fresh) {
    Set<NoticeBoardEntry> oldEntriesLookup = Set.of(cached);

    // Check for new entries in fresh compared to cached.
    return fresh.where((entry) => !oldEntriesLookup.contains(entry)).isNotEmpty;
  }
}
