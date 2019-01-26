import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/weekplan/custom/custom_event.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/ui/view/week_plan/custom/custom_event_dialog.dart';
import 'package:guide7/util/custom_colors.dart';

/// View showing a dialog to create / edit custom events.
class CustomEventDialogView extends StatefulWidget {
  /// Event to edit or null if creating one.
  final CustomEvent toEdit;

  /// Create custom event dialog view.
  CustomEventDialogView({
    this.toEdit,
  });

  @override
  State<StatefulWidget> createState() => _CustomEventDialogViewState();
}

/// State of the custom event dialog view.
class _CustomEventDialogViewState extends State<CustomEventDialogView> {
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
      title: widget.toEdit == null ? AppLocalizations.of(context).createCustomEvent : AppLocalizations.of(context).editCustomEvent,
      leading: BackButton(
        color: CustomColors.slateGrey,
      ));

  /// Build the dialog content.
  Widget _buildContent() {
    return SliverToBoxAdapter(
      child: CustomEventDialog(
        toEdit: widget.toEdit,
        onSubmit: (event) {
          print("Event updated!");
          print("Title: ${event.title}");
          print("Description: ${event.description}");
          print("Location: ${event.location}");
          print("Start: ${event.start}");
          print("End: ${event.end}");
          print("Cycle: ${event.cycle}");
        },
      ),
    );
  }
}
