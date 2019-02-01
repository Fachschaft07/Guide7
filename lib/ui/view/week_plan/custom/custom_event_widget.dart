import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/model/weekplan/custom/custom_event.dart';
import 'package:guide7/util/custom_colors.dart';

/// Widget used to display a custom event.
class CustomEventWidget extends StatelessWidget {
  /// Custom event to display.
  final CustomEvent event;

  /// Create widget.
  CustomEventWidget({
    @required this.event,
  });

  @override
  Widget build(BuildContext context) {
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

    return FlatButton(
      child: Column(
        children: children,
      ),
      onPressed: () {
        App.router.navigateTo(context, AppRoutes.customEventDetail.replaceFirst(":uuid", event.uuid), transition: TransitionType.native);
      },
    );
  }
}
