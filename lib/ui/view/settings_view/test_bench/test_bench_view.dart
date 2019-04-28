import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/connect/impl/mock_repository.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/storage/appointment/appointment_storage.dart';
import 'package:guide7/storage/hm_person/hm_person_storage.dart';
import 'package:guide7/storage/meal_plan/info/meal_plan_info_storage.dart';
import 'package:guide7/storage/meal_plan/meal_plan_storage.dart';
import 'package:guide7/storage/notice_board/notice_board_storage.dart';
import 'package:guide7/storage/week_plan/custom/custom_week_plan_event_storage.dart';
import 'package:guide7/storage/week_plan/zpa/zpa_week_plan_storage.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/ui/view/settings_view/settings_item/settings_item.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:guide7/util/notification/notification_manager.dart';
import 'package:guide7/util/scheduler/impl/background_fetch_scheduler.dart' show executeBackgroundTasks;

/// A test bench is used to help debugging / testing the app.
class TestBenchView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _TestBenchViewState();
}

/// State of the test bench view.
class _TestBenchViewState extends State<TestBenchView> {
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

  /// Build the applications bar for the test bench view.
  Widget _buildAppBar() => UIUtil.getSliverAppBar(
        title: "Test Bench",
        leading: BackButton(
          color: CustomColors.slateGrey,
        ),
      );

  /// Build the test bench view content.
  Widget _buildContent() => SliverList(delegate: SliverChildListDelegate(_buildTestBenchItems()));

  /// Build all test bench items.
  List<Widget> _buildTestBenchItems() {
    List<Widget> items = List<Widget>();

    items.add(SettingsItem(
      title: "Show notification",
      icon: Icons.notifications,
      description: "You can test whether notifications work properly with this!",
      onTap: () {
        NotificationManager().showNotification(
          title: "I am a notification!",
          content: "Lorem ipsum dolor sit amet, consetetur sadipscing elitr, sed diam nonumy eirmod tempor invidunt ut labore et dolore magna aliquyam",
        );
      },
    ));

    items.add(SettingsItem(
      title: "Run Background Tasks",
      icon: Icons.flip_to_back,
      description: "Run all background tasks defined in file 'tasks.dart'",
      onTap: () {
        _runBackgroundTasks();
      },
    ));

    items.add(SettingsItem(
      title: "Use mock repositories",
      icon: Icons.wifi_lock,
      description: "Mock repositories will be used until the next app launch",
      onTap: () {
        Repository.setRepositoryImplementation(MockRepository());
      },
    ));

    items.add(SettingsItem(
      title: "Clear storages",
      icon: Icons.clear_all,
      description: "Clear all stored data",
      onTap: () {
        _clearAllData();
      },
    ));

    return items;
  }

  /// Run all background tasks.
  void _runBackgroundTasks() {
    executeBackgroundTasks();
  }

  /// Clear all stored data.
  void _clearAllData() async {
    await NoticeBoardStorage().clear();

    await ZPAWeekPlanStorage().clear();
    await CustomWeekPlanEventStorage().clear();

    await AppointmentStorage().clear();

    await HMPersonStorage().clear();

    await MealPlanInfoStorage().clear();

    await MealPlanStorage().clear();
  }
}
