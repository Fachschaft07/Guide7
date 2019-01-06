import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/connect/login/zpa/zpa_login_repository.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/ui/view/navigation_view/item/navigation_view_item.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:guide7/util/zpa.dart';

/// View containing additional navigation options.
class NavigationView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _NavigationViewState();
}

/// State of the navigation view.
class _NavigationViewState extends State<NavigationView> {
  @override
  Widget build(BuildContext context) => SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(),
            SliverList(
              delegate: SliverChildListDelegate(
                [
                  NavigationViewItem(
                    text: AppLocalizations.of(context).appointments,
                    icon: Icons.timer,
                    onSelected: () {
                      App.router.navigateTo(context, AppRoutes.appointments, transition: TransitionType.native);
                    },
                    isFirst: true,
                  ),
                  NavigationViewItem(
                    text: AppLocalizations.of(context).roomSearch,
                    icon: Icons.location_searching,
                    onSelected: () {
                      App.router.navigateTo(context, AppRoutes.roomSearch, transition: TransitionType.native);
                    },
                  ),
                  NavigationViewItem(
                    text: AppLocalizations.of(context).privacyPolicyStatement,
                    icon: Icons.fingerprint,
                    onSelected: () {
                      App.router.navigateTo(context, AppRoutes.privacyPolicyStatement, transition: TransitionType.native);
                    },
                  ),
                  _getLoginLogoutItem(),
                ],
              ),
            ),
          ],
        ),
      );

  /// Build the views application bar.
  Widget _buildAppBar() => UIUtil.getSliverAppBar(title: AppLocalizations.of(context).navigationViewTitle, actions: [
        IconButton(
          icon: Icon(Icons.settings, color: CustomColors.slateGrey),
          tooltip: AppLocalizations.of(context).settings,
          onPressed: () {
            App.router.navigateTo(
              context,
              AppRoutes.settings,
              transition: TransitionType.native,
            );
          },
        ),
      ]);

  /// Logout from the app.
  void _logout() async {
    Repository repo = Repository();

    ZPALoginRepository loginRepository = repo.getZPALoginRepository();

    if (loginRepository.isLoggedIn()) {
      await loginRepository.tryLogout(loginRepository.getLogin());
      await repo.getLocalCredentialsRepository().clearLocalCredentials();
    }

    App.router.navigateTo(context, AppRoutes.login, transition: TransitionType.native, replace: true);
  }

  /// Go to login view.
  void _login() {
    App.router.navigateTo(context, AppRoutes.login, transition: TransitionType.native, replace: true);
  }

  /// Get the login or logout navigation item.
  Widget _getLoginLogoutItem() {
    return FutureBuilder(
      future: ZPA.isLoggedIn(),
      builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
        if (snapshot.hasData) {
          bool isLoggedIn = snapshot.data;

          if (isLoggedIn) {
            return NavigationViewItem(
              text: AppLocalizations.of(context).logOut,
              icon: Icons.lock,
              onSelected: () {
                _logout();
              },
            );
          } else {
            return NavigationViewItem(
              text: AppLocalizations.of(context).doLogin,
              icon: Icons.lock_open,
              onSelected: () {
                _login();
              },
            );
          }
        } else {
          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: 10.0,
              horizontal: 20.0,
            ),
            child: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }
}
