import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/connect/login/zpa/zpa_login_repository.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/ui/navigation/app_floating_action_button/app_floating_action_button.dart';
import 'package:guide7/ui/navigation/app_floating_action_button/item/app_floating_action_button_item.dart';
import 'package:guide7/ui/navigation/bottom_bar/app_bottom_navigation_bar.dart';
import 'package:guide7/ui/navigation/bottom_bar/item/app_bottom_navigation_bar_item.dart';
import 'package:guide7/ui/view/appointment/appointment_view.dart';
import 'package:guide7/ui/view/notice_board/notice_board_view.dart';
import 'package:guide7/ui/view/week_plan/week_plan_view.dart';
import 'package:guide7/util/notification/notification_manager.dart';
import 'package:guide7/util/notification/payload_handler/notice_board_payload_handler.dart';

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
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
      floatingActionButton: AppFloatingActionButton(
        items: [
          AppFloatingActionButtonItem(
            title: "Abmelden",
            onPressed: () => _logout(),
            iconData: Icons.exit_to_app,
          ),
        ],
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

  /// Logout from the app.
  void _logout() async {
    Repository repo = Repository();

    ZPALoginRepository loginRepository = repo.getZPALoginRepository();

    if (loginRepository.isLoggedIn()) {
      await loginRepository.tryLogout(loginRepository.getLogin());
      await repo.getLocalCredentialsRepository().clearLocalCredentials();
    }

    App.router.navigateTo(context, AppRoutes.login, transition: TransitionType.fadeIn);
  }
}
