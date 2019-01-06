import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/util/custom_colors.dart';

/// Privacy policy statement is displayed inside the view.
class PrivacyPolicyStatementView extends StatelessWidget {
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
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: 10.0,
        horizontal: 20.0,
      ),
      child: Text("Not yet implemented."), // TODO Implement privacy policy statement.
    );
  }
}
