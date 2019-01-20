import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/ui/view/settings_view/settings_item/settings_item.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:guide7/util/debug_util.dart';

/// View where the user can modify settings.
class SettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsViewState();
}

/// State of the settings view.
class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) => UIUtil.getScaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              _buildAppBar(),
              _buildContent(),
            ],
          ),
        ),
      );

  /// Build the applications bar for the settings view.
  Widget _buildAppBar() => UIUtil.getSliverAppBar(
        title: AppLocalizations.of(context).settings,
        leading: BackButton(
          color: CustomColors.slateGrey,
        ),
      );

  /// Build the settings view content.
  Widget _buildContent() => SliverList(delegate: SliverChildListDelegate(_buildSettingsItems()));

  /// Build all settings items.
  List<Widget> _buildSettingsItems() {
    List<Widget> items = List<Widget>();

    items.add(_buildInfoItem());

    if (DebugUtil.isDebugMode) {
      // Add test bench item.
      items.add(_buildTestBenchItem());
    }

    return items;
  }

  /// Build app info settings item.
  Widget _buildInfoItem() {
    return SettingsItem(
      title: AppLocalizations.of(context).version,
      description: AppLocalizations.of(context).appVersion,
      icon: Icons.info,
    );
  }

  /// Build settings item for the test bench.
  Widget _buildTestBenchItem() {
    return SettingsItem(
      title: "Test Bench",
      description: "Tools to help debug the app",
      icon: Icons.bug_report,
      onTap: () {
        _openTestBench();
      },
    );
  }

  /// Go to test bench view.
  void _openTestBench() {
    App.router.navigateTo(context, AppRoutes.testBench, transition: TransitionType.native);
  }
}
