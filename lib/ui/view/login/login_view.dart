import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/connect/login/zpa/response/zpa_login_response.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';
import 'package:guide7/model/login_info/login_info.dart';
import 'package:guide7/storage/login_info/login_info_storage.dart';
import 'package:guide7/ui/common/headline.dart';
import 'package:guide7/ui/common/line_separator.dart';
import 'package:guide7/ui/view/login/form/login_form.dart';
import 'package:guide7/util/custom_colors.dart';

/// View showing the login dialog.
class LoginView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

/// State of the login view.
class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            SliverToBoxAdapter(
              child: Column(
                children: <Widget>[
                  _buildHeader(),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 25.0,
                      horizontal: 40.0,
                    ),
                    child: LoginForm(
                      onLoginAttempt: _onLoginAttempt,
                      onSuccess: () {
                        _onLoginSuccess(false);
                      },
                    ),
                  ),
                  LineSeparator(
                    title: AppLocalizations.of(context).or,
                    padding: 30.0,
                  ),
                  Padding(
                    padding: EdgeInsets.symmetric(
                      vertical: 20.0,
                      horizontal: 40.0,
                    ),
                    child: FlatButton.icon(
                      onPressed: () {
                        _onLoginSuccess(true);
                      },
                      icon: Icon(
                        Icons.arrow_right,
                        color: CustomColors.slateGrey,
                      ),
                      label: Text(
                        AppLocalizations.of(context).skipLogin,
                        style: TextStyle(color: CustomColors.slateGrey),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the login header.
  Widget _buildHeader() => Padding(
        padding: EdgeInsets.only(top: 50.0, left: 25.0, right: 25.0, bottom: 25.0),
        child: Column(
          children: <Widget>[
            Headline(AppLocalizations.of(context).login),
            Padding(
              padding: EdgeInsets.only(top: 20.0, bottom: 20.0),
              child: Text(
                AppLocalizations.of(context).loginInfo,
                textAlign: TextAlign.center,
              ),
            ),
          ],
        ),
      );

  /// Attempt a login with the provided [username] and [password].
  Future<bool> _onLoginAttempt(String username, String password) async {
    Repository repo = Repository();

    UsernamePasswordCredentials credentials = UsernamePasswordCredentials(username: username, password: password);

    ZPALoginResponse response = await repo.getZPALoginRepository().tryLogin(credentials);

    bool success = response != null;

    if (success) {
      await repo.getLocalCredentialsRepository().storeLocalCredentials(credentials);
    }

    return success;
  }

  /// What to do when the login succeeded.
  Future<void> _onLoginSuccess(bool skipped) async {
    LoginInfoStorage loginInfoStorage = LoginInfoStorage();
    await loginInfoStorage.write(LoginInfo(
      skippedLogin: skipped,
    ));

    App.router.navigateTo(context, AppRoutes.main, transition: TransitionType.native, replace: true);
  }
}
