import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/connect/login/zpa/response/zpa_login_response.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/main.dart';
import 'package:guide7/model/credentials/username_password_credentials.dart';
import 'package:guide7/ui/view/base_view.dart';
import 'package:guide7/ui/view/login/form/login_form.dart';

/// View showing the login dialog.
class LoginView extends StatefulWidget implements BaseView {
  @override
  State<StatefulWidget> createState() => _LoginViewState();
}

/// State of the login view.
class _LoginViewState extends State<LoginView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Anmeldung", textScaleFactor: 3.0),
          Padding(
            padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
            child: LoginForm(
              onLoginAttempt: _onLoginAttempt,
              onSuccess: _onLoginSuccess,
            ),
          )
        ],
      ),
    );
  }

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
  void _onLoginSuccess() {
    App.router.navigateTo(context, AppRoutes.notice_board, transition: TransitionType.inFromBottom);
  }
}
