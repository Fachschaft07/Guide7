import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/util/custom_colors.dart';

/// Navigation item of the applications floating action button.
class AppFloatingActionButtonItem extends StatefulWidget {
  /// Title of the item.
  final String title;

  /// Icon of the item.
  final IconData iconData;

  /// What to do when the item has been pressed.
  final VoidCallback onPressed;

  /// Create button item.
  AppFloatingActionButtonItem({
    @required this.title,
    @required this.iconData,
    @required this.onPressed,
  });

  @override
  State<StatefulWidget> createState() => _AppFloatingActionButtonItemState();
}

/// State of the application floating action button item.
class _AppFloatingActionButtonItemState extends State<AppFloatingActionButtonItem> {
  @override
  Widget build(BuildContext context) => Container(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              widget.iconData,
              color: Colors.white,
            ),
            Text(
              widget.title,
              style: TextStyle(
                fontFamily: "Roboto",
                color: Colors.white,
              ),
            ),
          ],
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0),
          color: CustomColors.slateGrey,
        ),
      );
}
