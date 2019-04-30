import 'dart:async';

import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/storage/route/route_storage.dart';
import 'package:guide7/util/notification/payload_handler/payload_handler.dart';

/// Payload handler opening the week plan view.
class WeekPlanPayloadHandler implements PayloadHandler {
  /// Anticipated payload.
  static const String payload = "week_plan";

  /// Constant constructor.
  const WeekPlanPayloadHandler();

  @override
  Future<bool> handle(String payload) async {
    if (payload == WeekPlanPayloadHandler.payload) {
      if (App.navigatorKey != null && App.navigatorKey.currentState != null) {
        await App.navigatorKey.currentState.pushNamed(AppRoutes.weekPlan);
      } else {
        RouteStorage().write(AppRoutes.weekPlan);
      }

      return true;
    }

    return false;
  }
}
