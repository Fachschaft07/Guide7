import 'package:flutter/widgets.dart';

/// Item shown in the app bottom navigation bar.
class AppBottomNavigationBarItem {
  /// Icon to show.
  final IconData iconData;

  /// Title of the item.
  final String title;

  /// Create item.
  const AppBottomNavigationBarItem({@required this.iconData, @required this.title});
}
