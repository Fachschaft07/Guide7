import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/connect/appointment/appointment_repository.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/appointment/appointment.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/ui/view/appointment/appointment_entry/appointment_entry.dart';
import 'package:guide7/util/custom_colors.dart';

/// View showing important appointments for students.
class AppointmentView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _AppointmentViewState();
}

/// State of the appointment view.
class _AppointmentViewState extends State<AppointmentView> {
  /// Future loading the appointments.
  Future<List<Appointment>> _appointmentFuture;

  @override
  void initState() {
    super.initState();

    _appointmentFuture = _loadAppointments(
      fromCache: true,
    );
  }

  @override
  Widget build(BuildContext context) => UIUtil.getScaffold(
        body: SafeArea(
          child: _buildContent(),
        ),
      );

  /// Build the views content.
  Widget _buildContent() {
    return FutureBuilder(
      future: _appointmentFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Appointment>> snapshot) {
        Widget sliverList;

        if (snapshot.hasData) {
          List<Appointment> entries = List.of(snapshot.data); // Make sure appointments is a growable list.

          _transformAppointments(entries);

          sliverList = SliverList(delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (entries.length > index) {
                return AppointmentEntry(
                  appointment: entries[index],
                );
              }

              return null;
            },
          ));
        } else if (snapshot.hasError) {
          sliverList = SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
              child: Text(
                AppLocalizations.of(context).appointmentLoadError,
                style: TextStyle(fontFamily: "NotoSerifTC"),
              ),
            ),
          );
        } else {
          sliverList = SliverToBoxAdapter(
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
                child: CircularProgressIndicator(),
              ),
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _loadAppointments(fromCache: false),
          child: CustomScrollView(
            slivers: <Widget>[
              _buildAppBar(),
              sliverList,
            ],
          ),
        );
      },
    );
  }

  /// Build the views app bar.
  Widget _buildAppBar() => UIUtil.getSliverAppBar(
      title: AppLocalizations.of(context).appointments,
      leading: BackButton(
        color: CustomColors.slateGrey,
      ));

  /// Load appointments.
  Future<List<Appointment>> _loadAppointments({
    bool fromCache = true,
  }) async {
    Repository repo = Repository();
    AppointmentRepository appointmentRepository = repo.getAppointmentRepository();

    return await appointmentRepository.loadAppointments(fromServer: !fromCache);
  }

  /// Transform the passed appointments list.
  void _transformAppointments(List<Appointment> appointments) {
    DateTime now = DateTime.now();

    // Show only appointments that are not already useless.
    appointments.removeWhere((appointment) => appointment.end.isBefore(now));

    // Sort by start date!
    appointments.sort((appointment1, appointment2) => appointment1.start.compareTo(appointment2.start));
  }
}
