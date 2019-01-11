import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/connect/weekplan/weekplan_repository.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';
import 'package:guide7/ui/common/line_separator.dart';
import 'package:guide7/ui/view/week_plan/event/week_plan_event_widget.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';

/// View showing the week plan of the student.
class WeekPlanView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WeekPlanViewState();
}

/// State of the week plan view.
class _WeekPlanViewState extends State<WeekPlanView> {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Column(
          children: <Widget>[
            _buildAppBar(),
            Expanded(
              child: _buildContent(),
            ),
          ],
        ),
      );

  /// Build the views app bar.
  Widget _buildAppBar() => AppBar(
        title: Text(AppLocalizations.of(context).weekPlan),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.white,
      );

  /// Build the views content.
  Widget _buildContent() {
    DateTime now = DateTime.now();

    DateFormat dateFormat = DateFormat.MMMEd(Localizations.localeOf(context).languageCode);

    return PagewiseListView(
      pageSize: 7,
      padding: EdgeInsets.all(15.0),
      itemBuilder: (BuildContext context, dayInfo, int index) {
        return StickyHeader(
          header: Container(
            padding: EdgeInsets.symmetric(vertical: 5, horizontal: 25),
            decoration: BoxDecoration(color: Colors.white),
            child: LineSeparator(
              title: dateFormat.format(dayInfo.date),
            ),
          ),
          content: dayInfo.events.isEmpty
              ? Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 20),
                  child: Center(
                    child: Text(
                      "Keine Einträge",
                      style: TextStyle(
                        fontFamily: "NotoSerifTC",
                        color: CustomColors.slateGrey,
                      ),
                    ),
                  ),
                )
              : Container(
                  padding: EdgeInsets.only(bottom: 20.0),
                  child: Column(
                    children: List.generate(dayInfo.events.length, (index) {
                      return Container(
                        padding: EdgeInsets.only(left: 60),
                        child: WeekPlanEventWidget(
                          event: dayInfo.events[index],
                        ),
                      );
                    }),
                  ),
                ),
        );
      },
      pageFuture: (int pageIndex) {
        return _fetchWeekEvents(now.add(Duration(days: 7 * pageIndex)));
      },
    );
  }

  /// Fetch all events in a week defined by the passed [date].
  Future<List<DayInfo>> _fetchWeekEvents(DateTime date) async {
    int distanceToMonday = date.weekday - 1;
    DateTime monday = DateTime(date.year, date.month, date.day - distanceToMonday);

    Repository repo = Repository();
    WeekPlanRepository weekPlanRepository = repo.getWeekPlanRepository();

    List<WeekPlanEvent> events = await weekPlanRepository.getEvents(
      fromServer: true,
      date: monday,
    );

    // Map events to weekdays.
    Map<int, DayInfo> weekdayMapping = Map();
    for (int i = 0; i < 7; i++) {
      weekdayMapping[i + 1] = DayInfo(monday.add(Duration(days: i)));
    }

    for (WeekPlanEvent event in events) {
      int weekday = event.start.weekday;

      weekdayMapping[weekday].events.add(event);
    }

    return weekdayMapping.values.toList(growable: false);
  }
}

class DayInfo {
  final DateTime date;
  final List<WeekPlanEvent> events = List<WeekPlanEvent>();

  DayInfo(this.date);
}
