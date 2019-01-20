import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/util/custom_colors.dart';

/// Item of the settings view.
class SettingsItem extends StatelessWidget {
  /// Callback when the item has been tapped.
  final Function onTap;

  /// Icon to show for the item.
  final IconData icon;

  /// Title of the item.
  final String title;

  /// Optional description of the item.
  final String description;

  /// Optional additional widget shown after the item.
  final Widget after;

  /// Create settings item.
  SettingsItem({
    @required this.title,
    @required this.icon,
    this.description,
    this.onTap,
    this.after,
  });

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      onPressed: onTap != null ? onTap : () {},
      child: Row(
        children: _buildItemChildren(),
      ),
    );
  }

  /// Build the items children to show.
  List<Widget> _buildItemChildren() {
    List<Widget> children = <Widget>[
      CircleAvatar(
        child: Icon(
          icon,
          color: CustomColors.slateGrey,
        ),
      ),
      Expanded(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 15.0, vertical: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: _buildItemContent(),
          ),
        ),
      ),
    ];

    if (after != null) {
      children.add(after);
    }

    return children;
  }

  /// Build content of the item.
  List<Widget> _buildItemContent() {
    List<Widget> content = <Widget>[
      Text(
        title,
        textScaleFactor: 1.2,
      ),
    ];

    if (description != null) {
      content.add(Text(
        description,
        style: TextStyle(color: CustomColors.slateGrey),
        textScaleFactor: 0.9,
      ));
    }

    return content;
  }
}
