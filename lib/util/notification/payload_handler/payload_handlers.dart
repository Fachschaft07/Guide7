import 'package:guide7/util/notification/payload_handler/appointment_payload_handler.dart';
import 'package:guide7/util/notification/payload_handler/notice_board_payload_handler.dart';
import 'package:guide7/util/notification/payload_handler/payload_handler.dart';
import 'package:guide7/util/notification/payload_handler/week_plan_payload_handler.dart';

/// Class holding all payload handlers available.
class PayloadHandlers {
  /// List of all payload handlers available.
  static const List<PayloadHandler> payloadHandlers = [
    NoticeBoardPayloadHandler(),
    AppointmentPayloadHandler(),
    WeekPlanPayloadHandler(),
  ];
}
