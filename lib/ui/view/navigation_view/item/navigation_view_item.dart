import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/util/custom_colors.dart';

/// Item in the navigation view.
class NavigationViewItem extends StatelessWidget {
  /// Text to show in the item.
  final String text;

  /// Icon to show for the item.
  final IconData icon;

  /// Whether it is the first item in list.
  final bool isFirst;

  /// What to do when item has been tapped.
  final Function onSelected;

  /// Create navigation view item.
  NavigationViewItem({
    @required this.text,
    @required this.icon,
    @required this.onSelected,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      child: FlatButton(
        padding: EdgeInsets.symmetric(
          horizontal: 30.0,
          vertical: 15.0,
        ),
        child: _getItemContent(text, icon),
        onPressed: onSelected,
      ),
      decoration: BoxDecoration(
        border: _getBorder(context),
      ), // Divider b
    );
  }

  /// Get content of the navigation item.
  Widget _getItemContent(String text, IconData icon) {
    return Row(
      children: <Widget>[
        Icon(
          icon,
          color: CustomColors.slateGrey,
        ),
        Padding(
          padding: EdgeInsets.only(
            left: 20.0,
          ),
          child: Text(
            text,
            style: TextStyle(
              color: Colors.black87,
              fontFamily: "Roboto",
            ),
            textScaleFactor: 1.1,
          ),
        ),
      ],
    );
  }

  Border _getBorder(BuildContext context) => isFirst
      ? Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
          top: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        )
      : Border(
          bottom: BorderSide(
            color: Theme.of(context).dividerColor,
          ),
        );
}
