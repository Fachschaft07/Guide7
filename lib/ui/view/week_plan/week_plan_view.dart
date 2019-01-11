import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/connect/weekplan/weekplan_repository.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/weekplan/week_plan_event.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/ui/view/week_plan/event/week_plan_event_widget.dart';
import 'package:guide7/util/custom_colors.dart';

/// View showing the week plan of the student.
class WeekPlanView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WeekPlanViewState();
}

/// State of the week plan view.
class _WeekPlanViewState extends State<WeekPlanView> {
  /// Week plan event loading future.
  Future<List<WeekPlanEvent>> _weekPlanEventFuture;

  @override
  void initState() {
    super.initState();
  }

  /// Reload the events.
  void _reloadEvents() {
    Repository repo = Repository();
    WeekPlanRepository weekPlanRepository = repo.getWeekPlanRepository();

    setState(() {
      _weekPlanEventFuture = weekPlanRepository.getEvents(
        fromServer: true,
        date: DateTime.now(),
      );
    });
  }

  @override
  Widget build(BuildContext context) => SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(),
            _buildContent(),
          ],
        ),
      );

  /// Build the views app bar.
  Widget _buildAppBar() => UIUtil.getSliverAppBar(
        title: AppLocalizations.of(context).weekPlan,
        actions: [
          IconButton(
            icon: Icon(Icons.refresh, color: CustomColors.slateGrey),
            tooltip: AppLocalizations.of(context).refresh,
            onPressed: () {
              _reloadEvents();
            },
          ),
        ],
      );

  /// Build the views content.
  Widget _buildContent() => FutureBuilder(
        future: _weekPlanEventFuture,
        builder: (BuildContext context, AsyncSnapshot<List<WeekPlanEvent>> snapshot) {
          Widget sliverList;

          if (snapshot.hasData) {
            List<WeekPlanEvent> events = List.of(snapshot.data); // Make sure appointments is a growable list.

            sliverList = SliverList(delegate: SliverChildBuilderDelegate(
              (BuildContext context, int index) {
                if (events.length > index) {
                  return WeekPlanEventWidget(
                    event: events[index],
                  );
                }

                return null;
              },
            ));
          } else if (snapshot.hasError) {
            sliverList = SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
                child: Text(AppLocalizations.of(context).weekPlanLoadError),
              ),
            );
          } else {
            sliverList = SliverToBoxAdapter(
              child: Center(
                child: Padding(
                  padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }

          return sliverList;
        },
      );
}
