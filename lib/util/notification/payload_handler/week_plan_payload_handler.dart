import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
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
      await App.router.navigateTo(null, AppRoutes.weekPlan, clearStack: true, replace: true);

      return true;
    }

    return false;
  }
}
