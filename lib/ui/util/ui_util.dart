import 'package:flutter/material.dart';

/// Utility class for easily getting default widgets.
class UIUtil {
  /// Get the application default sliver app bar.
  static SliverAppBar getSliverAppBar({
    @required String title,
    List<Widget> actions,
    Widget leading,
  }) =>
      SliverAppBar(
        title: Text(
          title,
          style: TextStyle(color: Colors.black),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        snap: true,
        floating: true,
        actions: actions,
        leading: leading,
      );

  /// Get the application default scaffold.
  static Scaffold getScaffold({
    @required Widget body,
    Widget bottomNavigationBar,
    Widget floatingActionButton,
  }) =>
      Scaffold(
        body: body,
        backgroundColor: Colors.white,
        bottomNavigationBar: bottomNavigationBar,
        floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
        floatingActionButton: floatingActionButton,
      );
}
