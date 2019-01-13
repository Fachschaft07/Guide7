import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/connect/weekplan/weekplan_repository.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';
import 'package:guide7/ui/view/week_plan/event/week_plan_event_widget.dart';
import 'package:flutter_pagewise/flutter_pagewise.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:intl/intl.dart';
import 'package:sticky_headers/sticky_headers.dart';
import 'package:auto_size_text/auto_size_text.dart';

/// View showing the week plan of the student.
class WeekPlanView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WeekPlanViewState();
}

/// State of the week plan view.
class _WeekPlanViewState extends State<WeekPlanView> {
  /// Background color of the date badge.
  static const Color _dateBackgroundColor = Color(0xFFF9F9F9);

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

    DateFormat weekDayFormat = DateFormat.E(Localizations.localeOf(context).languageCode);
    DateFormat dayFormat = DateFormat.d(Localizations.localeOf(context).languageCode);
    DateFormat monthFormat = DateFormat.MMM(Localizations.localeOf(context).languageCode);

    Size size = MediaQuery.of(context).size;
    double fixedColumnWidth;
    if (MediaQuery.of(context).orientation == Orientation.portrait) {
      fixedColumnWidth = size.width / 5;
    } else {
      fixedColumnWidth = size.width / 9;
    }
    double eventColumnWidth = size.width - fixedColumnWidth;

    return PagewiseListView(
      pageSize: 7,
      padding: EdgeInsets.all(15.0),
      itemBuilder: (BuildContext context, dayInfo, int index) {
        return StickyHeaderBuilder(
            overlapHeaders: true,
            builder: (BuildContext context, double stuckAmount) {
              stuckAmount = 1.0 - stuckAmount.clamp(0.0, 1.0);

              return Container(
                width: fixedColumnWidth,
                height: fixedColumnWidth,
                decoration: BoxDecoration(color: _dateBackgroundColor, borderRadius: BorderRadius.circular(10.0)),
                margin: EdgeInsets.only(bottom: 5),
                child: Container(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          AutoSizeText(
                            weekDayFormat.format(dayInfo.date).toUpperCase(),
                            style: TextStyle(color: Colors.black54),
                          ),
                          AutoSizeText(
                            dayFormat.format(dayInfo.date),
                            minFontSize: 25.0,
                          ),
                        ],
                      ),
                      RotatedBox(
                        quarterTurns: 3,
                        child: AutoSizeText(
                          monthFormat.format(dayInfo.date),
                          style: TextStyle(color: CustomColors.slateGrey),
                          minFontSize: 16.0,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
            content: Container(
              margin: EdgeInsets.only(left: fixedColumnWidth),
              width: eventColumnWidth,
              constraints: BoxConstraints(minHeight: 150),
              child: dayInfo.events.isEmpty
                  ? Center(
                      child: Column(
                        children: <Widget>[
                          Icon(
                            Icons.thumb_up,
                            color: CustomColors.slateGrey,
                          ),
                          Text(
                            "Keine Einträge",
                            style: TextStyle(
                              fontFamily: "NotoSerifTC",
                              color: CustomColors.slateGrey,
                            ),
                          ),
                        ],
                      ),
                    )
                  : Container(
                      padding: EdgeInsets.only(bottom: 20.0),
                      child: Column(
                        children: List.generate(dayInfo.events.length, (index) {
                          return Container(
                            child: WeekPlanEventWidget(
                              event: dayInfo.events[index],
                            ),
                          );
                        }),
                      ),
                    ),
            ));
      },
      pageFuture: (int pageIndex) {
        return _fetchWeekEvents(now.add(Duration(days: 7 * pageIndex)));
      },
    );
  }

  /// Fetch all events in a week defined by the passed [date].
  Future<List<_DayInfo>> _fetchWeekEvents(DateTime date) async {
    int distanceToMonday = date.weekday - 1;
    DateTime monday = DateTime(date.year, date.month, date.day - distanceToMonday);

    Repository repo = Repository();
    WeekPlanRepository weekPlanRepository = repo.getWeekPlanRepository();

    List<WeekPlanEvent> events = await weekPlanRepository.getEvents(
      fromServer: true,
      date: monday,
    );

    // Map events to weekdays.
    Map<int, _DayInfo> weekdayMapping = Map();
    for (int i = 0; i < 7; i++) {
      weekdayMapping[i + 1] = _DayInfo(monday.add(Duration(days: i)));
    }

    for (WeekPlanEvent event in events) {
      int weekday = event.start.weekday;

      weekdayMapping[weekday].events.add(event);
    }

    List<_DayInfo> result = weekdayMapping.values.toList(growable: false);

    /// Sort events per day.
    for (_DayInfo info in result) {
      info.events.sort((event1, event2) => event1.start.compareTo(event2.start));
    }

    return result;
  }
}

class _DayInfo {
  final DateTime date;
  final List<WeekPlanEvent> events = List<WeekPlanEvent>();

  _DayInfo(this.date);
}
