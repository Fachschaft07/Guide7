import 'dart:async';

import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/preferences/preferences.dart';
import 'package:guide7/storage/preferences/preferences_storage.dart';
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
  /// Preferences of the app.
  Preferences _preferences;

  @override
  void initState() {
    super.initState();

    _loadPreferences();
  }

  /// Load the apps preferences.
  void _loadPreferences() async {
    Preferences prefs = await PreferencesStorage().read();

    setState(() {
      _preferences = prefs;
    });
  }

  /// Save the apps preferences.
  Future<void> _savePreferences() async {
    await PreferencesStorage().write(_preferences);
  }

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

    items.add(_buildModifyMealPlanInfoItem());

    if (_preferences != null) {
      items.add(_buildNoticeBoardNotificationSwitchItem());
      items.add(_buildWeekPlanNotificationSwitchItem());
      items.add(_buildAppointmentNotificationSwitchItem());
    }

    items.add(_buildInfoItem());

    if (DebugUtil.isDebugMode) {
      // Add test bench item.
      items.add(_buildTestBenchItem());
    }

    return items;
  }

  /// Build item to toggle the notice board notifications.
  Widget _buildNoticeBoardNotificationSwitchItem() {
    return SettingsItem(
      title: AppLocalizations.of(context).showNoticeBoardNotifications,
      description: AppLocalizations.of(context).showNoticeBoardNotificationsDescription,
      icon: Icons.announcement,
      onTap: () async {
        _preferences.showNoticeBoardNotifications = !_preferences.showNoticeBoardNotifications;

        await _savePreferences();

        setState(() {});
      },
      after: Switch(
        value: _preferences.showNoticeBoardNotifications,
        onChanged: (newValue) {
          _preferences.showNoticeBoardNotifications = newValue;
        },
      ),
    );
  }

  /// Build item to toggle the week plan notifications.
  Widget _buildWeekPlanNotificationSwitchItem() {
    return SettingsItem(
      title: AppLocalizations.of(context).showWeekPlanNotifications,
      description: AppLocalizations.of(context).showWeekPlanNotificationsDescription,
      icon: Icons.timeline,
      onTap: () async {
        _preferences.showWeekPlanNotifications = !_preferences.showWeekPlanNotifications;

        await _savePreferences();

        setState(() {});
      },
      after: Switch(
        value: _preferences.showWeekPlanNotifications,
        onChanged: (newValue) {
          _preferences.showWeekPlanNotifications = newValue;
        },
      ),
    );
  }

  /// Build item to toggle the appointment notifications.
  Widget _buildAppointmentNotificationSwitchItem() {
    return SettingsItem(
      title: AppLocalizations.of(context).showAppointmentNotifications,
      description: AppLocalizations.of(context).showAppointmentNotificationsDescription,
      icon: Icons.timer,
      onTap: () async {
        _preferences.showAppointmentNotifications = !_preferences.showAppointmentNotifications;

        await _savePreferences();

        setState(() {});
      },
      after: Switch(
        value: _preferences.showAppointmentNotifications,
        onChanged: (newValue) {
          _preferences.showAppointmentNotifications = newValue;
        },
      ),
    );
  }

  /// Build item to adjust the meal plan info.
  Widget _buildModifyMealPlanInfoItem() {
    return SettingsItem(
      title: AppLocalizations.of(context).modifyMealPlanSettings,
      description: AppLocalizations.of(context).modifyMealPlanSettingsDescription,
      icon: Icons.fastfood,
      onTap: () {
        App.router.navigateTo(context, AppRoutes.mealPlanSetup, transition: TransitionType.native);
      },
    );
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
