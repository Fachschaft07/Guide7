import 'dart:async';

import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/storage/route/route_storage.dart';
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
      if (App.navigatorKey != null && App.navigatorKey.currentState != null) {
        await App.navigatorKey.currentState.pushNamed(AppRoutes.noticeBoard);
      } else {
        RouteStorage().write(AppRoutes.noticeBoard);
      }

      return true;
    }

    return false;
  }
}
