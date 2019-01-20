import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/regular_slot.dart';
import 'package:guide7/util/custom_colors.dart';

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

    // Append rooms and teachers.
    children.add(Row(
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
    ));

    return children;
  }
}
