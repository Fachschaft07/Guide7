import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/ui/navigation/bottom_bar/item/app_bottom_navigation_bar_item.dart';
import 'package:guide7/util/custom_colors.dart';

/// Bottom navigation bar of the application.
class AppBottomNavigationBar extends StatefulWidget {
  /// Items to show in the navigation bar.
  final List<AppBottomNavigationBarItem> items;

  /// Callback on what to do when another tab has been selected.
  final ValueChanged<int> onItemSelected;

  /// Height of the bar.
  final double height;

  /// Size of the icons.
  final double iconSize;

  /// Background color of the bar.
  final Color backgroundColor;

  /// Text color of the bar items.
  final Color color;

  /// Text color of selected bar items.
  final Color selectedColor;

  /// Notch shape in the bar.
  final NotchedShape shape;

  /// Index of the initially selected item.
  final int selectedItemIndex;

  /// Create app navigation bar.
  AppBottomNavigationBar({
    @required this.items,
    @required this.onItemSelected,
    this.height = 50.0,
    this.iconSize = 25.0,
    this.backgroundColor = Colors.white,
    this.color = Colors.black54,
    this.selectedColor = CustomColors.lightCoral,
    this.shape,
    this.selectedItemIndex = 0,
  });

  @override
  State<StatefulWidget> createState() => _AppBottomNavigationBarState();
}

/// State of the applications bottom navigation bar.
class _AppBottomNavigationBarState extends State<AppBottomNavigationBar> {
  @override
  void initState() {
    super.initState();
  }

  /// Change the currently selected item.
  void _changeSelectedItem(int index) {
    widget.onItemSelected(index);
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> items = List.generate(
      widget.items.length,
      (int index) => _buildItem(
            item: widget.items[index],
            index: index,
            onPressed: _changeSelectedItem,
          ),
    );

    return BottomAppBar(
      shape: widget.shape,
      color: widget.backgroundColor,
      child: Row(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: items,
      ),
    );
  }

  /// Build the navigation item widget on the navigation bar.
  Widget _buildItem({
    AppBottomNavigationBarItem item,
    int index,
    ValueChanged<int> onPressed,
  }) {
    Color color = widget.selectedItemIndex == index ? widget.selectedColor : widget.color;

    return Expanded(
      child: SizedBox(
        height: widget.height,
        child: Material(
          type: MaterialType.transparency,
          child: InkWell(
            onTap: () => onPressed(index),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(item.iconData, color: color, size: widget.iconSize),
                Text(
                  item.title,
                  style: TextStyle(
                    color: color,
                    fontFamily: "Roboto",
                  ),
                  textScaleFactor: 0.7,
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
