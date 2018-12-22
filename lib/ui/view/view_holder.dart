import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/ui/navigation/bottom_bar/app_bottom_navigation_bar.dart';
import 'package:guide7/ui/navigation/bottom_bar/item/app_bottom_navigation_bar_item.dart';
import 'package:guide7/ui/view/appointment/appointment_view.dart';
import 'package:guide7/ui/view/notice_board/notice_board_view.dart';
import 'package:guide7/ui/view/week_plan/week_plan_view.dart';

/// View which includes a bottom navigation bar and switches out the actual views for the app.
class ViewHolder extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _ViewHolderState();
}

/// State of the app view holder.
class _ViewHolderState extends State<ViewHolder> {
  /// Controller of the view holder used to exchange views.
  PageController _controller = PageController();

  /// Index of the currently shown. page.
  int _currentViewIndex = 0;

  /// What to do in case another item in the bottom navigation bar has been selected.
  void _onBottomNavigationItemChange(int index) {
    _controller.animateToPage(
      index,
      duration: Duration(milliseconds: 200),
      curve: Curves.ease,
    );

    /// Let the widget rebuild.
    setState(() {
      _currentViewIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _controller,
        children: _getNavigationBarViews(),
        physics: NeverScrollableScrollPhysics(),
      ),
      backgroundColor: Colors.white,
      bottomNavigationBar: AppBottomNavigationBar(
        items: [
          AppBottomNavigationBarItem(iconData: Icons.announcement, title: "Schwarzes Brett"),
          AppBottomNavigationBarItem(iconData: Icons.timeline, title: "Wochenplan"),
          AppBottomNavigationBarItem(iconData: Icons.timer, title: "Termine"),
        ],
        initiallySelectedItemIndex: _currentViewIndex,
        onItemSelected: _onBottomNavigationItemChange,
        shape: CircularNotchedRectangle(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        child: Icon(Icons.menu),
        elevation: 2.0,
      ),
    );
  }

  /// Get all available views in the navigation bar of the app.
  List<Widget> _getNavigationBarViews() {
    return <Widget>[
      NoticeBoardView(),
      WeekPlanView(),
      AppointmentView(),
    ];
  }
}
