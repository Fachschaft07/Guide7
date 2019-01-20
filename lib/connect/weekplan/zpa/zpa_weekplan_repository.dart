import 'dart:convert';

import 'package:guide7/connect/login/zpa/response/zpa_login_response.dart';
import 'package:guide7/connect/login/zpa/util/zpa_variables.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/connect/weekplan/weekplan_repository.dart';
import 'package:guide7/connect/weekplan/zpa/parser/slot/slot_parser.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';
import 'package:guide7/model/weekplan/zpa/zpa_week_plan_event.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

/// Repository providing week plan events from the ZPA services.
class ZPAWeekPlanRepository implements WeekPlanRepository {
  /// Where to find the web service.
  static const String _resource = "/student/ws_get_week_plan";

  /// Date format used to call the web service with a correctly formatted date.
  static DateFormat _dateFormat = DateFormat("yyyy-MM-dd");

  /// Parser parsing ZPA week plan slots.
  static const SlotParser _slotParser = SlotParser();

  /// Constant constructor.
  const ZPAWeekPlanRepository();

  @override
  Future<List<WeekPlanEvent>> getEvents({
    bool fromServer,
    DateTime date,
  }) async {
    // TODO Implement caching.

    return await _loadEvents(date);
  }

  @override
  Future<void> clearCache() async {
    // TODO: implement clearCache
    return null;
  }

  /// Load events for the passed [date] from ZPA services.
  Future<List<WeekPlanEvent>> _loadEvents(DateTime date) async {
    String rawJson = await _fetchRawWeekPlanEvents(date);

    Map<String, dynamic> map = json.decode(rawJson);

    int errorCode = map["error_code"] != null ? map["error_code"] : -1;

    if (errorCode != 0) {
      throw Exception("Received bad error code $errorCode from ZPA");
    }

    List<ZPAWeekPlanEvent> events = List<ZPAWeekPlanEvent>();
    for (final jsonSlot in map["slots"]) {
      events.add(ZPAWeekPlanEvent(
        slot: _slotParser.parse(jsonSlot),
      ));
    }

    return events;
  }

  /// Fetch the raw Json containing the week plan events for the passed [date].
  Future<String> _fetchRawWeekPlanEvents(DateTime date) async {
    ZPALoginResponse loginResponse;
    try {
      loginResponse = await _zpaLogin();
    } catch (e) {
      throw Exception("Could not fetch week plan events as the ZPA login failed.");
    }

    http.Response response = await http.get(
      "${ZPAVariables.url}/$_resource/?date=${_dateFormat.format(date)}",
      headers: {"cookie": loginResponse.cookie},
    );

    if (response.statusCode != 200) {
      throw Exception("Bad status code ${response.statusCode}");
    }

    return response.body;
  }

  /// Do the login to the ZPA services.
  Future<ZPALoginResponse> _zpaLogin() async {
    Repository repo = Repository();

    ZPALoginResponse loginResponse = await repo.getZPALoginRepository().tryLogin(await repo.getLocalCredentialsRepository().loadLocalCredentials());

    if (loginResponse == null) {
      throw Exception("Login to ZPA failed.");
    }

    return loginResponse;
  }
}
