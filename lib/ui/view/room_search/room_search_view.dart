import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:guide7/connect/repository.dart';
import 'package:guide7/localization/app_localizations.dart';
import 'package:guide7/model/room/room.dart';
import 'package:guide7/ui/util/ui_util.dart';
import 'package:guide7/util/custom_colors.dart';
import 'package:intl/intl.dart';

/// View for the room search.
class RoomSearchView extends StatefulWidget {
  @override
  State<StatefulWidget> createState() => _RoomSearchViewState();
}

/// State of the room search view.
class _RoomSearchViewState extends State<RoomSearchView> {
  /// Currently selected date.
  DateTime _selectedDate = DateTime.now();

  /// Currently selected start time.
  TimeOfDay _selectedStartTime = TimeOfDay.now();

  /// Currently selected end time.
  TimeOfDay _selectedEndTime = TimeOfDay.now().replacing(hour: TimeOfDay.now().hour + 1);

  /// Future to load rooms with.
  Future<List<Room>> _roomFuture;

  @override
  void initState() {
    super.initState();

    _loadRooms();
  }

  @override
  Widget build(BuildContext context) {
    return UIUtil.getScaffold(
      body: SafeArea(
        child: CustomScrollView(
          slivers: <Widget>[
            _buildAppBar(),
            _buildDateTimeControls(),
            _buildContent(),
          ],
        ),
      ),
    );
  }

  /// Build the views app bar.
  Widget _buildAppBar() => UIUtil.getSliverAppBar(
      title: AppLocalizations.of(context).roomSearch,
      leading: BackButton(
        color: CustomColors.slateGrey,
      ));

  /// Build the views date time controls.
  Widget _buildDateTimeControls() {
    DateFormat dateFormat = DateFormat.yMd(Localizations.localeOf(context).languageCode);
    DateFormat timeFormat = DateFormat.jm(Localizations.localeOf(context).languageCode);

    return SliverToBoxAdapter(
      child: Container(
        padding: EdgeInsets.only(bottom: 20.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: <Widget>[
            _buildControlView(
              AppLocalizations.of(context).day,
              dateFormat.format(_selectedDate),
              () async {
                DateTime result = await _selectDate();

                if (result != null) {
                  setState(() {
                    _selectedDate = result;
                    _loadRooms();
                  });
                }
              },
            ),
            _buildControlView(
              AppLocalizations.of(context).from,
              timeFormat.format(DateTime(1, 1, 1, _selectedStartTime.hour, _selectedStartTime.minute)),
              () async {
                TimeOfDay result = await _selectTime();

                if (result != null) {
                  setState(() {
                    _selectedStartTime = result;
                    _loadRooms();
                  });
                }
              },
            ),
            _buildControlView(
              AppLocalizations.of(context).to,
              timeFormat.format(DateTime(1, 1, 1, _selectedEndTime.hour, _selectedEndTime.minute)),
              () async {
                TimeOfDay result = await _selectTime();

                if (result != null) {
                  setState(() {
                    _selectedEndTime = result;
                    _loadRooms();
                  });
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Build views content.
  Widget _buildContent() {
    return FutureBuilder(
      future: _roomFuture,
      builder: (BuildContext context, AsyncSnapshot<List<Room>> snapshot) {
        Widget sliverList;

        if (snapshot.hasData && snapshot.connectionState == ConnectionState.done) {
          List<Room> entries = snapshot.data;

          sliverList = SliverList(delegate: SliverChildBuilderDelegate(
            (BuildContext context, int index) {
              if (entries.length > index) {
                return _buildRoomView(entries[index]);
              }

              return null;
            },
          ));
        } else if (snapshot.hasError && snapshot.connectionState == ConnectionState.done) {
          sliverList = SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 30.0),
              child: Text(
                AppLocalizations.of(context).roomSearchError,
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

        return sliverList;
      },
    );
  }

  /// Build view for the passed [room].
  Widget _buildRoomView(Room room) {
    return Container(
      padding: EdgeInsets.symmetric(
        vertical: 15.0,
        horizontal: 30.0,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                Icons.room,
                color: CustomColors.lightCoral,
              ),
              Padding(
                child: Text(
                  room.roomNumber,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                padding: EdgeInsets.only(left: 10.0),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              Icon(
                Icons.event_seat,
                color: CustomColors.slateGrey,
              ),
              Padding(
                padding: EdgeInsets.only(left: 10.0),
                child: Text("${AppLocalizations.of(context).seatCount}: ${room.seatCount}"),
              ),
            ],
          ),
        ],
      ),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Theme.of(context).dividerColor),
        ),
      ),
    );
  }

  /// Build controls view.
  Widget _buildControlView(String title, String value, Function onPressed) {
    return RaisedButton(
      elevation: 0,
      padding: EdgeInsets.symmetric(
        horizontal: 15.0,
        vertical: 10.0,
      ),
      onPressed: () {
        onPressed();
      },
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10000.0)),
      color: Color.fromRGBO(245, 245, 245, 1.0),
      child: Column(
        children: [
          Text(
            value,
            style: TextStyle(fontFamily: "Roboto"),
          ),
          Padding(
            padding: EdgeInsets.only(
              top: 5.0,
            ),
            child: Text(
              title,
              style: TextStyle(
                fontFamily: "Roboto",
                color: CustomColors.slateGrey,
              ),
              textScaleFactor: 0.8,
            ),
          ),
        ],
      ),
    );
  }

  /// Select a date.
  Future<DateTime> _selectDate() async {
    return await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now().subtract(Duration(days: 1)),
      lastDate: DateTime(DateTime.now().year + 1),
    );
  }

  /// Select time.
  Future<TimeOfDay> _selectTime() async {
    return await showTimePicker(
      context: context,
      initialTime: TimeOfDay.now(),
    );
  }

  /// Load free rooms.
  void _loadRooms() {
    Repository repo = Repository();
    final freeRoomsRepo = repo.getFreeRoomsRepository();

    _roomFuture = freeRoomsRepo.getFreeRooms(_selectedDate, _selectedStartTime, _selectedEndTime);
  }
}
