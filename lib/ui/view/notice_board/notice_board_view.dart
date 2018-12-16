import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/connect/login/zpa/response/zpa_login_response.dart';
import 'package:guide7/connect/login/zpa/zpa_login_repository.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/main.dart';
import 'package:guide7/model/notice_board/notice_board_entry.dart';
import 'package:guide7/ui/view/base_view.dart';
import 'package:guide7/ui/view/notice_board/entry/notice_board_entry_widget.dart';

/// View showing the notice board.
class NoticeBoardView extends StatefulWidget implements BaseView {
  @override
  State<StatefulWidget> createState() => _NoticeBoardViewState();
}

/// State of the notice board view.
class _NoticeBoardViewState extends State<NoticeBoardView> {
  /// Future which will provide notice board entries once finished.
  Future<List<NoticeBoardEntry>> _fetchEntries;

  @override
  void initState() {
    super.initState();

    _getEntries();
  }

  /// Refresh the view.
  void _getEntries({bool fromCache = true}) {
    setState(() {
      _fetchEntries = _reloadEntries(fromCache: fromCache);
    });
  }

  /// Reload notice board entries.
  Future<List<NoticeBoardEntry>> _reloadEntries({bool fromCache = true}) async {
    var repository = Repository();
    var noticeBoardRepo = repository.getNoticeBoardRepository();

    if (fromCache && await noticeBoardRepo.hasCachedEntries()) {
      return await noticeBoardRepo.getCachedEntries();
    } else {
      return await noticeBoardRepo.loadEntries();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            Center(
              child: Text(
                "Schwarzes Brett",
                textScaleFactor: 3.0,
              ),
            ),
            Row(
              children: <Widget>[
                RaisedButton(
                  onPressed: _logout,
                  child: Text("Test Abmelden"),
                ),
                RaisedButton(
                  onPressed: () => _getEntries(fromCache: false),
                  child: Text("Neu laden"),
                ),
              ],
            ),
            Expanded(
              child: FutureBuilder<List<NoticeBoardEntry>>(
                future: _fetchEntries,
                builder: (BuildContext context, AsyncSnapshot snapshot) {
                  if (snapshot.hasData) {
                    return ListView.builder(
                      itemCount: snapshot.data.length,
                      itemBuilder: (BuildContext ctx, int index) => NoticeBoardEntryWidget(entry: snapshot.data[index]),
                    );
                  } else if (snapshot.hasError) {
                    return Text("Beim Laden der Einträge ist ein Fehler aufgetreten.");
                  }

                  return CircularProgressIndicator();
                },
              ),
            ),
          ],
        ),
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
