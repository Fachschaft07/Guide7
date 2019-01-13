import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/model/weekplan/zpa/slot/types/extra_slot.dart';
import 'package:guide7/util/custom_colors.dart';

/// Widget displaying a ZPA week plan extra slot.
class ExtraSlotWidget extends StatelessWidget {
  /// ZPA week plan extra slot to display.
  final ExtraSlot slot;

  /// Create widget.
  ExtraSlotWidget({
    @required this.slot,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: _buildChildren(context),
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

    return children;
  }
}
