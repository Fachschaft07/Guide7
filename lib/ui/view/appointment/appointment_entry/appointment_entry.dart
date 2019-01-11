import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/appointment/appointment.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:intl/intl.dart';

/// Widget showing an appointment.
class AppointmentEntry extends StatelessWidget {
  /// Appointment to display.
  final Appointment appointment;

  /// Create entry.
  AppointmentEntry({@required this.appointment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 30.0,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _getAppointmentChildren(context),
      ),
      decoration: BoxDecoration(border: Border(top: BorderSide(color: Theme.of(context).dividerColor))),
    );
  }

  /// Get widgets to display appointment info with.
  List<Widget> _getAppointmentChildren(BuildContext context) {
    DateFormat dateFormat = DateFormat.yMMMd(Localizations.localeOf(context).languageCode);

    List<Widget> children = [
      Padding(
        padding: EdgeInsets.only(bottom: 10.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              Icons.access_time,
              color: CustomColors.slateGrey,
            ),
            Expanded(
              child: Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text(
                  "${dateFormat.format(appointment.start)} ${AppLocalizations.of(context).to.toLowerCase()} ${dateFormat.format(appointment.end)}",
                  style: TextStyle(fontFamily: "Raleway"),
                ),
              ),
            ),
          ],
        ),
      ),
      Text(
        appointment.summary,
        style: TextStyle(
          fontWeight: FontWeight.bold,
          fontFamily: "NotoSerifTC",
        ),
      ),
    ];

    if (appointment.location != null && appointment.location.isNotEmpty) {
      children.add(Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Icon(
            Icons.location_on,
            color: CustomColors.slateGrey,
          ),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(top: 10.0),
              child: Text(appointment.location),
            ),
          ),
        ],
      ));
    }

    return children;
  }
}
