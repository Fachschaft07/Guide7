import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/ui/util/ui_util.dart';

/// View showing the week plan of the student.
class WeekPlanView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WeekPlanViewState();
}

/// State of the week plan view.
class _WeekPlanViewState extends State<WeekPlanView> {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(),
            SliverToBoxAdapter(
              child: _buildContent(),
            ),
          ],
        ),
      );

  /// Build the views app bar.
  Widget _buildAppBar() => UIUtil.getSliverAppBar(title: AppLocalizations.of(context).weekPlan);

  /// Build the views content.
  Widget _buildContent() => Padding(
        padding: EdgeInsets.symmetric(
          vertical: 10.0,
          horizontal: 30.0,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              "Hier sollte der Wochenplan zu sehen sein, doch ist dieser noch nicht entwickelt.",
              textAlign: TextAlign.center,
            ),
            Container(
              padding: EdgeInsets.all(10.0),
              child: Text(
                "<(^-^)> #Mist",
                textScaleFactor: 4.0,
                style: TextStyle(
                  fontFamily: "Roboto",
                ),
              ),
              transform: Matrix4.rotationZ(pi * 0.1),
            ),
          ],
        ),
      );
}
