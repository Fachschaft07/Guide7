import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/util/custom_colors.dart';

/// View showing important appointments for students.
class AppointmentView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppointmentViewState();
}

/// State of the appointment view.
class _AppointmentViewState extends State<AppointmentView> {
  @override
  Widget build(BuildContext context) => UIUtil.getScaffold(
        body: SafeArea(
            child: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(),
            SliverToBoxAdapter(
              child: _buildContent(),
            ),
          ],
        )),
      );

  /// Build the views app bar.
  Widget _buildAppBar() => UIUtil.getSliverAppBar(
      title: AppLocalizations.of(context).appointments,
      leading: BackButton(
        color: CustomColors.slateGrey,
      ));

  /// Build the views content.
  Widget _buildContent() {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 30.0,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text(
            "Hier sollten Termine zu sehen sein, doch das ist noch nicht entwickelt.",
            textAlign: TextAlign.center,
          ),
          Container(
            padding: EdgeInsets.all(10.0),
            child: Text(
              ":(",
              textScaleFactor: 4.0,
              style: TextStyle(
                fontFamily: "Roboto",
              ),
            ),
            transform: Matrix4.rotationZ(pi * 0.4),
          ),
        ],
      ),
    );
  }
}
