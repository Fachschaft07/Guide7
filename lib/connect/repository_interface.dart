import 'package:guide7/connect/appointment/appointment_repository.dart';
import 'package:guide7/connect/credential/local_credentials_repository.dart';
import 'package:guide7/connect/free_rooms/free_rooms_repository.dart';
import 'package:guide7/connect/hm_people/hm_people_repository.dart';
import 'package:guide7/connect/login/zpa/zpa_login_repository.dart';
import 'package:guide7/connect/notice_board/notice_board_repository.dart';
import 'package:guide7/connect/week_plan/week_plan_repository.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';

/// Repository interface.
abstract class RepositoryI {
  /// Get local credentials repository.
  LocalCredentialsRepository<UsernamePasswordCredentials> getLocalCredentialsRepository();

  /// Get login repository for the ZPA services.
  ZPALoginRepository getZPALoginRepository();

  /// Get repository holding notice board entries.
  NoticeBoardRepository getNoticeBoardRepository();

  /// Get repository providing information about people working at the munich university of applied sciences.
  HMPeopleRepository getHMPeopleRepository();

  /// Get repository providing free/available rooms.
  FreeRoomsRepository getFreeRoomsRepository();

  /// Get repository providing appointments.
  AppointmentRepository getAppointmentRepository();

  /// Get repository providing week plan events.
  WeekPlanRepository getWeekPlanRepository();
}
