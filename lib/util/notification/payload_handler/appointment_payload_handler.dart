import 'dart:async';

import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
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
      await App.router.navigateTo(null, AppRoutes.appointments, clearStack: true, replace: true);

      return true;
    }

    return false;
  }
}
