import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/replace_slot.dart';
import 'package:guide7/util/custom_colors.dart';

/// Widget displaying a ZPA week plan replace slot.
class ReplaceSlotWidget extends StatelessWidget {
  /// ZPA week plan replace slot to display.
  final ReplaceSlot slot;

  /// Create widget.
  ReplaceSlotWidget({
    @required this.slot,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 10.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: _buildChildren(context),
      ),
    );
  }

  /// Build child widgets to display.
  List<Widget> _buildChildren(BuildContext context) {
    List<Widget> children = List<Widget>();

    // Append description.
    children.add(Text(
      slot.description,
      style: TextStyle(fontFamily: "NotoSerifTC"),
    ));

    // Append rooms.
    children.add(Container(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: Icon(
              Icons.room,
              color: CustomColors.lightCoral,
            ),
          ),
          Text(slot.rooms.join(", ")),
        ],
      ),
    ));

    // Append teachers.
    children.add(Container(
      padding: EdgeInsets.only(top: 5),
      child: Row(
        children: <Widget>[
          Padding(
            padding: EdgeInsets.only(right: 5),
            child: Icon(
              Icons.person,
              color: CustomColors.slateGrey,
            ),
          ),
          Text(slot.teachers.join(", ")),
        ],
      ),
    ));

    return children;
  }
}
