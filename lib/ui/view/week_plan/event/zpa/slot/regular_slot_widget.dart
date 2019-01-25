import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/weekplan/zpa/slot/change/plan_change.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/regular_slot.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:intl/intl.dart';

/// Widget displaying a ZPA week plan regular slot.
class RegularSlotWidget extends StatelessWidget {
  /// ZPA week plan regular slot to display.
  final RegularSlot slot;

  /// Create widget.
  RegularSlotWidget({
    @required this.slot,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _buildChildren(context),
    );
  }

  /// Build child widgets to display.
  List<Widget> _buildChildren(BuildContext context) {
    List<Widget> children = List<Widget>();

    // Append modules.
    for (final module in slot.modules) {
      children.add(Row(
        children: <Widget>[
          Expanded(
            child: Text(
              module,
              style: TextStyle(
                fontFamily: "NotoSerifTC",
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ));
    }

    // Append descriptions.
    for (final description in slot.descriptions) {
      children.add(Row(children: <Widget>[
        Expanded(
          child: Text(
            description,
            style: TextStyle(fontFamily: "NotoSerifTC"),
          ),
        ),
      ]));
    }

    // Append plan change (if any)
    if (slot.hasPlanChange) {
      children.add(Row(
        children: <Widget>[
          Expanded(
            child: _buildPlanChange(slot.planChange, context),
          ),
        ],
      ));
    }

    // Append rooms and teachers.
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
            child: Text(slot.rooms.join(", ")),
          ),
          Icon(
            Icons.person,
            color: CustomColors.slateGrey,
          ),
          Expanded(
            child: Text(slot.teachers.join(", ")),
          ),
        ],
      ),
    ));

    return children;
  }

  /// Build the plan change representation for the passed [change].
  Widget _buildPlanChange(PlanChange change, BuildContext context) {
    DateFormat dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);
    AppLocalizations localizations = AppLocalizations.of(context);

    List<Widget> widgets = List<Widget>();

    String changeResult;
    if (change.cancelled) {
      changeResult = localizations.cancelled;
    } else if (change.moved) {
      changeResult = localizations.moved;
      if (change.alternateStartDate != null) {
        changeResult += " ${localizations.changeTo} ${dateFormat.format(change.alternateStartDate)}";
      }

      if (change.alternateRooms != null && change.alternateRooms.isNotEmpty) {
        changeResult += " ${localizations.changeAt} ${change.alternateRooms.join(",")}";
      }
    } else if (change.roomChanged) {
      changeResult = "${localizations.roomChanged} ${localizations.changeTo} ${change.alternateRooms.join(", ")}";
    }

    widgets.add(Row(
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(right: 5),
          child: Icon(
            Icons.info,
            color: Colors.white,
          ),
        ),
        Expanded(
          child: Text(
            changeResult,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        )
      ],
    ));

    return Container(
      margin: EdgeInsets.only(top: 5.0),
      padding: EdgeInsets.symmetric(vertical: 5.0, horizontal: 5.0),
      decoration: BoxDecoration(
        color: CustomColors.lightCoral,
        borderRadius: BorderRadius.circular(
          10.0,
        ),
      ),
      child: Column(
        children: widgets,
      ),
    );
  }
}
