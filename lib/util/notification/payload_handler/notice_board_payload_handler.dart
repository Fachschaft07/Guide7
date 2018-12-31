import 'package:flutter/widgets.dart';
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
  Future<bool> handle(String payload, BuildContext context) async {
    if (payload == NoticeBoardPayloadHandler.payload) {
      await App.router.navigateTo(context, AppRoutes.noticeBoard);

      return true;
    }

    return false;
  }
}
