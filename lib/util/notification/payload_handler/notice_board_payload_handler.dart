import 'dart:async';

import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/util/notification/payload_handler/payload_handler.dart';

/// Payload handler opening the notice board view.
class NoticeBoardPayloadHandler implements PayloadHandler {
  /// Anticipated payload.
  static const String payload = "notice_board";

  /// Constant constructor.
  const NoticeBoardPayloadHandler();

  @override
  Future<bool> handle(String payload) async {
    if (payload == NoticeBoardPayloadHandler.payload) {
      await App.router.navigateTo(null, AppRoutes.noticeBoard, clearStack: true, replace: true);

      return true;
    }

    return false;
  }
}
