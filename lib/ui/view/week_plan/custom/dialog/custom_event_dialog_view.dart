import 'package:fluro/fluro.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/app-routes.dart';
import 'package:guide7/app.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/weekplan/custom/custom_event.dart';
import 'package:guide7/storage/week_plan/custom/custom_week_plan_event_storage.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/ui/view/week_plan/custom/dialog/custom_event_dialog.dart';
import 'package:guide7/util/custom_colors.dart';

/// View showing a dialog to create / edit custom events.
class CustomEventDialogView extends StatefulWidget {
  /// Uuid of event to edit or null if creating one.
  final String uuid;

  /// Create custom event dialog view.
  CustomEventDialogView({
    this.uuid,
  });

  @override
  State<StatefulWidget> createState() => _CustomEventDialogViewState();
}

/// State of the custom event dialog view.
class _CustomEventDialogViewState extends State<CustomEventDialogView> {
  /// Future loading event.
  Future<CustomEvent> _future;

  @override
  void initState() {
    super.initState();

    _future = _fetchCustomEvent(widget.uuid);
  }

  @override
  Widget build(BuildContext context) {
    return UIUtil.getScaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  /// Build the views app bar.
  Widget _buildAppBar() => UIUtil.getSliverAppBar(
      title: widget.uuid == null || widget.uuid.isEmpty ? AppLocalizations.of(context).createCustomEvent : AppLocalizations.of(context).editCustomEvent,
      leading: BackButton(
        color: CustomColors.slateGrey,
      ));

  /// Build the dialog content.
  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: FutureBuilder<CustomEvent>(
        future: _future,
        builder: (BuildContext context, AsyncSnapshot<CustomEvent> snapshot) {
          if (snapshot.hasData || widget.uuid == null || widget.uuid.isEmpty) {
            CustomEvent toEdit;
            if (snapshot.data is CustomEvent) {
              toEdit = snapshot.data;
            }

            return CustomEventDialog(
              toEdit: toEdit,
              onSubmit: (event) {
                _submitEvent(event);
              },
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
      ),
    );
  }

  /// Submit the passed [event].
  void _submitEvent(CustomEvent event) async {
    CustomWeekPlanEventStorage storage = CustomWeekPlanEventStorage();

    if (widget.uuid != null && widget.uuid.isNotEmpty) {
      // First delete from storage, then rewrite.
      await storage.clearEvent(widget.uuid);
    }

    await storage.writeEvent(event);

    // Navigate back to week plan view.
    App.router.navigateTo(context, AppRoutes.weekPlan, transition: TransitionType.native, clearStack: true);
  }

  /// Fetch the event with the passed [uuid].
  Future<CustomEvent> _fetchCustomEvent(String uuid) {
    if (uuid == null || uuid.isEmpty) {
      return Future.value(null);
    }

    CustomWeekPlanEventStorage storage = CustomWeekPlanEventStorage();
    return storage.readEvent(uuid);
  }
}
