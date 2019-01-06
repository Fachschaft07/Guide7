import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/util/custom_colors.dart';

/// View where the user can modify settings.
class SettingsView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _SettingsViewState();
}

class _SettingsViewState extends State<SettingsView> {
  @override
  Widget build(BuildContext context) => Scaffold(
        body: SafeArea(
          child: CustomScrollView(
            slivers: <Widget>[
              _buildAppBar(),
              SliverToBoxAdapter(
                child: _buildContent(),
              ),
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
  Widget _buildContent() => Padding(
        padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
        child: Text("Not yet implemented"),
      );
}
