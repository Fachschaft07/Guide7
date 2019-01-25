import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/single_slot.dart';
import 'package:guide7/util/custom_colors.dart';

/// Widget displaying a ZPA week plan single slot.
class SingleSlotWidget extends StatelessWidget {
  /// ZPA week plan single slot to display.
  final SingleSlot slot;

  /// Create widget.
  SingleSlotWidget({
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

    // Append description.
    children.add(Row(
      children: <Widget>[
        Expanded(
          child: Text(
            slot.description,
            style: TextStyle(fontFamily: "NotoSerifTC"),
          ),
        )
      ],
    ));

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
}
