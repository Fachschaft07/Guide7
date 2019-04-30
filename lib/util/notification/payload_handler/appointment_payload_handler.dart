import 'dart:async';

import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/storage/route/route_storage.dart';
import 'package:guide7/util/notification/payload_handler/payload_handler.dart';

/// Payload handler opening the appointment view.
class AppointmentPayloadHandler implements PayloadHandler {
  /// Anticipated payload.
  static const String payload = "appointment";

  /// Constant constructor.
  const AppointmentPayloadHandler();

  @override
  Future<bool> handle(String payload) async {
    if (payload == AppointmentPayloadHandler.payload) {
      if (App.navigatorKey != null && App.navigatorKey.currentState != null) {
        await App.navigatorKey.currentState.pushNamed(AppRoutes.appointments);
      } else {
        RouteStorage().write(AppRoutes.appointments);
      }

      return true;
    }

    return false;
  }
}
