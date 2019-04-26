import 'package:guide7/connect/appointment/appointment_repository.dart';
import 'package:guide7/connect/appointment/hm_appointment_repository.dart';
import 'package:guide7/connect/credential/local_credentials_repository.dart';
import 'package:guide7/connect/credential/local_username_password_credential_repository.dart';
import 'package:guide7/connect/free_rooms/free_rooms_repository.dart';
import 'package:guide7/connect/free_rooms/zpa_free_rooms_repository.dart';
import 'package:guide7/connect/hm_people/hm_people_repository.dart';
import 'package:guide7/connect/hm_people/hm_people_repository_impl.dart';
import 'package:guide7/connect/login/zpa/zpa_login_repository.dart';
import 'package:guide7/connect/meal_plan/meal_plan_repository.dart';
import 'package:guide7/connect/meal_plan/openmensa/openmensa_repository.dart';
import 'package:guide7/connect/notice_board/html_crawling/html_crawling_notice_board_repository.dart';
import 'package:guide7/connect/notice_board/notice_board_repository.dart';
import 'package:guide7/connect/repository_interface.dart';
import 'package:guide7/connect/week_plan/week_plan_repository.dart';
import 'package:guide7/connect/week_plan/week_plan_repository_impl.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';

/// Default repository implementation of the app.
class DefaultRepository implements RepositoryI {
  @override
  LocalCredentialsRepository<UsernamePasswordCredentials> getLocalCredentialsRepository() => LocalUsernamePasswordCredentialsRepository();

  @override
  ZPALoginRepository getZPALoginRepository() => ZPALoginRepository();

  @override
  NoticeBoardRepository getNoticeBoardRepository() => HTMLCrawlingNoticeBoardRepository();

  @override
  HMPeopleRepository getHMPeopleRepository() => HMPeopleRepositoryImpl();

  @override
  FreeRoomsRepository getFreeRoomsRepository() => ZPAFreeRoomsRepository();

  @override
  AppointmentRepository getAppointmentRepository() => HMAppointmentRepository();

  @override
  WeekPlanRepository getWeekPlanRepository() => WeekPlanRepositoryImpl();

  @override
  MealPlanRepository getMealPlanRepository() => OpenMensaRepository();
}
