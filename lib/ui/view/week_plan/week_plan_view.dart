import 'dart:math';

import 'package:flutter/widgets.dart';

/// View showing the week plan of the student.
class WeekPlanView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _WeekPlanViewState();
}

/// State of the week plan view.
class _WeekPlanViewState extends State<WeekPlanView> {
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
        ),
      );
}
