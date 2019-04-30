import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/weekplan/custom/custom_event.dart';
import 'package:guide7/storage/week_plan/custom/custom_week_plan_event_storage.dart';
import 'package:guide7/ui/common/line_separator.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/util/custom_colors.dart';

/// Detail view for custom events.
class CustomEventDetailView extends StatefulWidget {
  /// Uuid of event to display details for.
  final String uuid;

  /// Create detail view.
  CustomEventDetailView({
    @required this.uuid,
  });

  @override
  State<StatefulWidget> createState() => _CustomEventDetailViewState();
}

class _CustomEventDetailViewState extends State<CustomEventDetailView> {
  /// Future to load event with.
  Future<CustomEvent> _future;

  /// Whether the delete security question is shown.
  bool _isSecurityQuestion = false;

  @override
  void initState() {
    super.initState();

    _future = _fetchCustomEvent(widget.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return UIUtil.getScaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  /// Build the views app bar.
  Widget _buildAppBar() => UIUtil.getSliverAppBar(
        title: AppLocalizations.of(context).details,
        leading: BackButton(
          color: CustomColors.slateGrey,
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.edit, color: CustomColors.slateGrey),
            tooltip: AppLocalizations.of(context).edit,
            onPressed: () {
              _editEvent();
            },
          ),
        ],
      );

  /// Build the detail view content.
  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: FutureBuilder<CustomEvent>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<CustomEvent> snapshot) {
          if (snapshot.hasData) {
            CustomEvent event = snapshot.data;

            return Padding(
              padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 20.0),
              child: Column(
                children: _buildEventDetails(event),
              ),
            );
          } else if (snapshot.hasError) {
            return Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
              child: Text(
                AppLocalizations.of(context).genericLoadError,
                style: TextStyle(fontFamily: "NotoSerifTC"),
              ),
            );
          } else {
            return Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
                child: CircularProgressIndicator(),
              ),
            );
          }
        },
      ),
    );
  }

  /// Build event details.
  List<Widget> _buildEventDetails(CustomEvent event) {
    List<Widget> children = List<Widget>();

    // Append title.
    children.add(Row(
      children: <Widget>[
        Expanded(
          child: Text(
            event.title,
            style: TextStyle(
              fontFamily: "NotoSerifTC",
              fontWeight: FontWeight.bold,
            ),
          ),
        )
      ],
    ));

    if (event.description != null && event.description.isNotEmpty) {
      // Append description.
      children.add(Row(
        children: <Widget>[
          Expanded(
            child: Text(
              event.description,
              style: TextStyle(fontFamily: "NotoSerifTC"),
            ),
          )
        ],
      ));
    }

    if (event.location != null && event.location.isNotEmpty) {
      // Append location
      children.add(Padding(
        padding: EdgeInsets.only(top: 5.0),
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            Icon(
              Icons.room,
              color: CustomColors.lightCoral,
            ),
            Expanded(
              child: Text(event.location),
            )
          ],
        ),
      ));
    }

    children.add(Padding(
      padding: EdgeInsets.only(top: 10.0),
      child: LineSeparator(
        title: AppLocalizations.of(context).actions,
      ),
    ));

    children.add(Padding(
      padding: EdgeInsets.only(top: 20.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton.icon(
            icon: Icon(
              Icons.edit,
              color: Colors.white,
            ),
            label: Text(
              AppLocalizations.of(context).edit,
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              _editEvent();
            },
            color: CustomColors.slateGrey,
          ),
        ],
      ),
    ));

    children.add(Padding(
      padding: EdgeInsets.symmetric(vertical: 5.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          RaisedButton.icon(
            icon: Icon(
              !_isSecurityQuestion ? Icons.delete : Icons.delete_forever,
              color: Colors.white,
            ),
            label: Text(
              !_isSecurityQuestion ? AppLocalizations.of(context).deleteEvent : AppLocalizations.of(context).deleteEventSecurityQuestion,
              style: TextStyle(color: Colors.white),
            ),
            onPressed: () {
              _deleteEvent();
            },
            color: Colors.redAccent,
          ),
        ],
      ),
    ));

    return children;
  }

  /// Edit the event.
  void _editEvent() {
    App.router.navigateTo(context, AppRoutes.customEventDialog.replaceFirst(":uuid", widget.uuid), transition: TransitionType.native);
  }

  /// Delete the event.
  Future<void> _deleteEvent() async {
    if (_isSecurityQuestion) {
      // Really delete the event.
      CustomWeekPlanEventStorage storage = CustomWeekPlanEventStorage();
      await storage.clearEvent(widget.uuid);

      App.router.navigateTo(context, AppRoutes.weekPlan, transition: TransitionType.native, clearStack: true);
    } else {
      // Show the security message.
      setState(() {
        _isSecurityQuestion = true;
      });
    }
  }

  /// Fetch the event with the passed [uuid].
  Future<CustomEvent> _fetchCustomEvent(String uuid) {
    CustomWeekPlanEventStorage storage = CustomWeekPlanEventStorage();
    return storage.readEvent(uuid);
  }
}
