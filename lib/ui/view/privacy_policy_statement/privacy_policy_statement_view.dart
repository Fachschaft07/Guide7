import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/util/custom_colors.dart';

/// Privacy policy statement is displayed inside the view.
class PrivacyPolicyStatementView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _PrivacyPolicyStatementViewState();
}

/// State of the privacy policy statement view.
class _PrivacyPolicyStatementViewState extends State<PrivacyPolicyStatementView> {
  /// Future loading the privacy policy statement content.
  Future<String> _loadStatementFuture;

  @override
  Widget build(BuildContext context) {
    return UIUtil.getScaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(context),
            SliverToBoxAdapter(
              child: _buildContent(context),
            ),
          ],
        ),
      ),
    );
  }

  /// Build the application bar for the view.
  Widget _buildAppBar(BuildContext context) => UIUtil.getSliverAppBar(
        title: AppLocalizations.of(context).privacyPolicyStatement,
        leading: BackButton(color: CustomColors.slateGrey),
      );

  /// Build the privacy statement content.
  Widget _buildContent(BuildContext context) {
    if (_loadStatementFuture == null) {
      _loadStatementFuture = _getPrivacyPolicyStatementContent();
    }

    return FutureBuilder(
      future: _loadStatementFuture,
      builder: (BuildContext context, AsyncSnapshot<String> snapshot) {
        if (snapshot.hasData) {
          String content = snapshot.data;

          return Padding(
            padding: EdgeInsets.symmetric(
              vertical: 40.0,
              horizontal: 40.0,
            ),
            child: MarkdownBody(
              data: content,
              styleSheet: _getMarkdownStylesheet(context),
            ),
          );
        } else if (snapshot.hasError) {
          return Padding(
            padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
            child: Text(
              AppLocalizations.of(context).genericLoadError,
              style: TextStyle(fontFamily: "NotoSerifTC"),
            ),
          );
        } else {
          return Center(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
              child: CircularProgressIndicator(),
            ),
          );
        }
      },
    );
  }

  /// Assumes the given path is a text-file-asset.
  Future<String> _getPrivacyPolicyStatementContent() async {
    String languageCode = Localizations.localeOf(context).languageCode.substring(0, 2);
    if (languageCode == null || (languageCode != "de" && languageCode != "en")) {
      languageCode = "en";
    }

    return await rootBundle.loadString("res/docs/privacy_policy/privacy_policy_$languageCode.md");
  }

  /// Get the stylesheet to style the markdown content of the entry.
  MarkdownStyleSheet _getMarkdownStylesheet(BuildContext context) {
    ThemeData themeData = Theme.of(context);

    return MarkdownStyleSheet.fromTheme(themeData).copyWith(p: themeData.textTheme.body1.copyWith(fontFamily: "NotoSerifTC"));
  }
}
