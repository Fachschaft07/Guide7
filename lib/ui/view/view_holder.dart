import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/ui/navigation/bottom_bar/app_bottom_navigation_bar.dart';
import 'package:guide7/ui/navigation/bottom_bar/item/app_bottom_navigation_bar_item.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/ui/view/navigation_view/navigation_view.dart';
import 'package:guide7/ui/view/notice_board/notice_board_view.dart';
import 'package:guide7/ui/view/week_plan/week_plan_view.dart';
import 'package:guide7/util/custom_colors.dart';

/// View which includes a bottom navigation bar and switches out the actual views for the app.
class ViewHolder extends StatefulWidget {
  /// Index of the initially selected view.
  final int viewIndex;

  /// Create view holder holding the apps views.
  ViewHolder({
    Key key,
    @required this.viewIndex,
  }) : super(key: key);

  @override
  State<StatefulWidget> createState() => _ViewHolderState();
}

/// State of the app view holder.
class _ViewHolderState extends State<ViewHolder> {
  /// Controller of the view holder used to exchange views.
  PageController _controller;

  /// Index of the currently shown. page.
  int _currentViewIndex = 0;

  @override
  void initState() {
    super.initState();

    _currentViewIndex = widget.viewIndex;
    _controller = PageController(initialPage: widget.viewIndex);
  }

  /// What to do in case another item in the bottom navigation bar has been selected.
  void _selectPage(int index) {
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
    return UIUtil.getScaffold(
      body: PageView(
        controller: _controller,
        children: _getBottomNavigationBarViews(),
        onPageChanged: (pageIndex) {
          setState(() {
            _currentViewIndex = pageIndex;
          });
        },
      ),
      bottomNavigationBar: AppBottomNavigationBar(
        items: [
          AppBottomNavigationBarItem(iconData: Icons.announcement, title: AppLocalizations.of(context).noticeBoard),
          AppBottomNavigationBarItem(iconData: Icons.timeline, title: AppLocalizations.of(context).weekPlan),
          AppBottomNavigationBarItem(iconData: Icons.menu, title: AppLocalizations.of(context).navigationViewItemTitle),
        ],
        selectedItemIndex: _currentViewIndex,
        onItemSelected: _selectPage,
        shape: CircularNotchedRectangle(),
      ),
      floatingActionButton: _getFloatingActionButton(_currentViewIndex),
    );
  }

  /// Get all views visible in the bottom navigation bar.
  List<Widget> _getBottomNavigationBarViews() => [
        NoticeBoardView(),
        WeekPlanView(),
        NavigationView(),
      ];

  /// Get the floating action button for the passed view index.
  Widget _getFloatingActionButton(int index) {
    switch (index) {
      case 1: // Week plan view
        return FloatingActionButton(
          onPressed: () {
            App.router.navigateTo(context, AppRoutes.customEventDialog, transition: TransitionType.native);
          },
          child: Icon(Icons.add),
          backgroundColor: CustomColors.slateGrey,
        );

      default:
        return null;
    }
  }
}
