import 'dart:math';

import 'package:flutter/widgets.dart';

/// View showing important appointments for students.
class AppointmentView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppointmentViewState();
}

/// State of the appointment view.
class _AppointmentViewState extends State<AppointmentView> {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: Padding(
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
        ),
      );
}
