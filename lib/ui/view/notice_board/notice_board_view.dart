import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/connect/login/zpa/response/zpa_login_response.dart';
import 'package:guide7/connect/login/zpa/zpa_login_repository.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/main.dart';
import 'package:guide7/ui/view/base_view.dart';

/// View showing the notice board.
class NoticeBoardView extends StatefulWidget implements BaseView {
  @override
  State<StatefulWidget> createState() => _NoticeBoardViewState();
}

/// State of the notice board view.
class _NoticeBoardViewState extends State<NoticeBoardView> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Text("Hallo Welt!"),
          RaisedButton(
            onPressed: _logout,
            child: Text("Test Logout"),
          )
        ],
      ),
    );
  }

  void _logout() async {
    // TODO Remove from notice board fragment -> belongs somewhere else

    Repository repo = Repository();

    ZPALoginRepository loginRepository = repo.getZPALoginRepository();

    if (loginRepository.isLoggedIn()) {
      await loginRepository.tryLogout(loginRepository.getLogin());
      await repo.getLocalCredentialsRepository().clearLocalCredentials();
    }

    App.router.navigateTo(context, AppRoutes.login, transition: TransitionType.fadeIn);
  }
}
