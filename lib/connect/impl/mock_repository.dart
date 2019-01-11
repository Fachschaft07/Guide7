import 'package:guide7/connect/appointment/appointment_repository.dart';
import 'package:guide7/connect/appointment/mock_appointment_repository.dart';
import 'package:guide7/connect/credential/local_credentials_repository.dart';
import 'package:guide7/connect/credential/mock_local_credentials_repository.dart';
import 'package:guide7/connect/free_rooms/free_rooms_repository.dart';
import 'package:guide7/connect/free_rooms/mock_free_rooms_repository.dart';
import 'package:guide7/connect/hm_people/hm_people_repository.dart';
import 'package:guide7/connect/hm_people/mock_hm_people_repository.dart';
import 'package:guide7/connect/login/zpa/mock_zpa_login_repository.dart';
import 'package:guide7/connect/login/zpa/zpa_login_repository.dart';
import 'package:guide7/connect/notice_board/mock_notice_board_repository.dart';
import 'package:guide7/connect/notice_board/notice_board_repository.dart';
import 'package:guide7/connect/repository_interface.dart';
import 'package:guide7/connect/weekplan/weekplan_repository.dart';
import 'package:guide7/connect/weekplan/zpa/mock_weekplan_repository.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';

/// Repository implementation used for tests.
class MockRepository implements RepositoryI {
  @override
  LocalCredentialsRepository<UsernamePasswordCredentials> getLocalCredentialsRepository() => MockLocalCredentialsRepository();

  @override
  ZPALoginRepository getZPALoginRepository() => MockZPALoginRepository();

  @override
  NoticeBoardRepository getNoticeBoardRepository() => MockNoticeBoardRepository();

  @override
  HMPeopleRepository getHMPeopleRepository() => MockHMPeopleRepository();

  @override
  FreeRoomsRepository getFreeRoomsRepository() => MockFreeRoomsRepository();

  @override
  AppointmentRepository getAppointmentRepository() => MockAppointmentRepository();

  @override
  WeekPlanRepository getWeekPlanRepository() => MockWeekPlanRepository();
}
